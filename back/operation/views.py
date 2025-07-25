from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.shortcuts import get_object_or_404
from django.db.models import Count, Case, When
from django.contrib.auth import get_user_model
import logging

from .models import Operation, Report
from .serializers import OperationSerializer, ReportSerializer

User = get_user_model()
logger = logging.getLogger(__name__)

# Helper functions for common operations
def create_success_response(message, data=None, status_code=status.HTTP_200_OK):
    """Create standardized success response."""
    response_data = {'success': True, 'message': message}
    if data:
        response_data['data'] = data
    return Response(response_data, status=status_code)

def create_error_response(message, errors=None, status_code=status.HTTP_400_BAD_REQUEST):
    """Create standardized error response."""
    response_data = {'success': False, 'message': message}
    if errors:
        response_data['errors'] = errors
    return Response(response_data, status=status_code)

def check_worker_permission(user):
    """Check if user is a worker."""
    return user.is_worker

def get_optimized_queryset(base_queryset):
    """Get optimized queryset with proper select_related and prefetch_related."""
    return base_queryset.select_related('user', 'operation').prefetch_related('operation__images__results')

# ViewSets
class OperationViewSet(ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = OperationSerializer
    queryset = Operation.objects.all()

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

class ReportViewSet(ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = ReportSerializer
    queryset = Report.objects.all()
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['status']

    def get_queryset(self):
        """Return reports based on user type."""
        base_queryset = get_optimized_queryset(self.queryset)
        
        if check_worker_permission(self.request.user):
            return base_queryset  # Workers see all reports
        return base_queryset.filter(user=self.request.user)  # Users see only their own

    def _check_worker_permissions(self, request):
        """Check if user has worker permissions for updates."""
        if not check_worker_permission(request.user):
            return create_error_response(
                'Only workers can update report status',
                status_code=status.HTTP_403_FORBIDDEN
            )
        return None

    def update(self, request, *args, **kwargs):
        """Update report - workers only."""
        error_response = self._check_worker_permissions(request)
        if error_response:
            return error_response
        return super().update(request, *args, **kwargs)

    def partial_update(self, request, *args, **kwargs):
        """Partially update report - workers only."""
        error_response = self._check_worker_permissions(request)
        if error_response:
            return error_response
        return super().partial_update(request, *args, **kwargs)

# Function-based views
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def submit_report(request):
    """Submit a new report - users only."""
    # Check permissions
    if check_worker_permission(request.user):
        return create_error_response(
            'Workers cannot submit reports',
            status_code=status.HTTP_403_FORBIDDEN
        )
            
    # Validate and create report
    serializer = ReportSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        report = serializer.save()
        logger.info(f"New report #{report.id} submitted by {request.user.username}")
        return create_success_response(
            'Report submitted successfully',
            data=serializer.data,
            status_code=status.HTTP_201_CREATED
        )
    
    return create_error_response(
        'Failed to submit report',
        errors=serializer.errors
    )

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def update_report_status(request, report_id):
    """Update report status - workers only."""
    # Check permissions
    if not check_worker_permission(request.user):
        return create_error_response(
            'Only workers can update report status',
            status_code=status.HTTP_403_FORBIDDEN
        )
    
    # Get report
    report = get_object_or_404(Report, id=report_id)
    
    # Validate status
    new_status = request.data.get('status')
    if not new_status:
        return create_error_response('Status is required')
    
    valid_statuses = ['RECEIVED', 'PENDING', 'IN_PROGRESS', 'COMPLETED']
    if new_status not in valid_statuses:
        return create_error_response(f'Invalid status. Valid options: {valid_statuses}')
    
    # Update report
    old_status = report.status
    report.status = new_status
    report.save()
    
    logger.info(f"Report #{report.id} status updated from {old_status} to {new_status} by {request.user.username}")
    
    return create_success_response(
        f'Report status updated to {new_status}',
        data={
            'report_id': report.id,
            'old_status': old_status,
            'new_status': new_status
        }
    )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_dashboard_stats(request):
    """Get dashboard statistics - workers only."""
    # Check permissions
    if not check_worker_permission(request.user):
        return create_error_response(
            'Only workers can access dashboard stats',
            status_code=status.HTTP_403_FORBIDDEN
        )
        
    # Get statistics
    stats = Report.objects.aggregate(
        total_reports=Count('id'),
        received=Count(Case(When(status='RECEIVED', then=1))),
        pending=Count(Case(When(status='PENDING', then=1))),
        in_progress=Count(Case(When(status='IN_PROGRESS', then=1))),
        completed=Count(Case(When(status='COMPLETED', then=1)))
    )
    
    return create_success_response('Dashboard stats retrieved successfully', data=stats)
