from rest_framework import serializers
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'phone_number', 'profile_image', 'is_worker']


class CreateUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'phone_number', 'password', 'profile_image']

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email is already in use.")
        return value

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("This username is already taken.")
        return value

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        refresh = RefreshToken.for_user(user)
        return {
            'user': user,
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(required=True, write_only=True)

    def validate(self, data):
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            raise serializers.ValidationError("Username and password are required.")
        
        user = authenticate(username=username, password=password)
        if not user:
            raise serializers.ValidationError("Invalid credentials.")

        refresh = RefreshToken.for_user(user)
        return {
            'user': user,
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }


class UserReportsSerializer(serializers.Serializer):
    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user', None)
        super().__init__(*args, **kwargs)

    def to_representation(self, instance):
        from operation.models import Report
        from operation.serializers import ReportSerializer
        
        reports = Report.objects.filter(user=self.user).order_by('-date')
        request = self.context.get('request')
        return ReportSerializer(reports, many=True, context={'request': request}).data


class UpdateUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email', 'phone_number', 'profile_image']

    def validate_email(self, value):
        # Allow current user to keep their email
        if self.instance and self.instance.email == value:
            return value
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email is already in use.")
        return value

    def validate_username(self, value):
        # Allow current user to keep their username
        if self.instance and self.instance.username == value:
            return value
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("This username is already taken.")
        return value 