from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    profile_image = models.ImageField(upload_to='profile_images/', blank=True, null=True)
    is_worker = models.BooleanField(default=False, help_text="Designates whether this user is a worker.")
    
    USERNAME_FIELD = 'username'  # Use username for authentication
    REQUIRED_FIELDS = ['email', 'phone_number']  # Required when creating superuser

    groups = models.ManyToManyField(
        'auth.Group',
        related_name='custom_user_groups',
        blank=True,
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='custom_user_permissions',
        blank=True,
    )

    def __str__(self):
        return f"{self.username} ({'Worker' if self.is_worker else 'User'})"

    class Meta:
        db_table = 'auth_user'
