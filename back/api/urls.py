from django.urls import path, include
from rest_framework.routers import DefaultRouter
from operation.views import OperationViewSet, ReportViewSet, submit_report, update_report_status, get_dashboard_stats
from user.views import RegisterView, LoginView, user_detail_view, user_reports_view, update_user_view
from rest_framework_simplejwt.views import TokenVerifyView, TokenBlacklistView

# Create a router for viewsets
router = DefaultRouter()
router.register(r'operations', OperationViewSet, basename='operation')
router.register(r'reports', ReportViewSet, basename='report')

urlpatterns = [
    # User authentication endpoints
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('me/', user_detail_view, name='user-detail'),
    path('me/reports/', user_reports_view, name='user-reports'),
    path('me/update/', update_user_view, name='update-user'),

    # Report management endpoints
    path('reports/submit/', submit_report, name='submit-report'),
    path('reports/<int:report_id>/status/', update_report_status, name='update-report-status'),
    path('reports/stats/', get_dashboard_stats, name='reports-stats'),

    # Token management
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('logout/', TokenBlacklistView.as_view(), name='token_blacklist'),
] + router.urls
