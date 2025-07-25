from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from .models import User
from .serializers import (
    UserSerializer, 
    CreateUserSerializer, 
    UpdateUserSerializer, 
    LoginSerializer,
    UserReportsSerializer
)


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = CreateUserSerializer
    permission_classes = [AllowAny]  # Allow unauthenticated registration

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            result = serializer.save()
            return Response({
                'success': True,
                'message': 'User registered successfully.',
                'data': {
                    'access': result['access'],
                    'refresh': result['refresh'],
                    'user': UserSerializer(result['user']).data
                }
            }, status=status.HTTP_201_CREATED)
        return Response({
            'success': False,
            'message': 'Registration failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]  # Allow unauthenticated login

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            result = serializer.validated_data
            return Response({
                'success': True,
                'message': 'Login successful.',
                'data': {
                    'access': result['access'],
                    'refresh': result['refresh'],
                    'user': UserSerializer(result['user']).data
                }
            })
        return Response({
            'success': False,
            'message': 'Login failed.',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_detail_view(request):
    serializer = UserSerializer(request.user)
    return Response({
        'success': True,
        'data': serializer.data
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_reports_view(request):
    serializer = UserReportsSerializer(user=request.user, context={'request': request})
    return Response({
        'success': True,
        'data': serializer.to_representation(None)
    })


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_user_view(request):
    serializer = UpdateUserSerializer(request.user, data=request.data, partial=True)
    
    if serializer.is_valid():
        serializer.save()
        return Response({
            'success': True,
            'message': 'User updated successfully.',
            'data': serializer.data
        })
    
    return Response({
        'success': False,
        'message': 'Update failed.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)
