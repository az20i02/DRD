from django.db import models
from django.conf import settings


class Operation(models.Model):
    """
    Represents an operation performed as part of a report.
    """
    

    def __str__(self):
        return f"Operation ID {self.id}"


class OperationImage(models.Model):
    """
    Stores images associated with an operation.
    """
    operation = models.ForeignKey(
        Operation, 
        on_delete=models.CASCADE, 
        related_name="images"
    )
    longitude = models.DecimalField(decimal_places=10, max_digits=20)
    latitude = models.DecimalField(decimal_places=10, max_digits=20)
    original_image = models.ImageField(upload_to="operation_images/original/")
    operated_image = models.ImageField(upload_to="operation_images/operated/", blank=True, null=True)
    
    def __str__(self):
        return f"Images for Operation {self.operation.id}"


class OperationResult(models.Model):
    """
    Contains results of an operation including damage description and type.
    """
    operation_image = models.ForeignKey(
        OperationImage, 
        on_delete=models.CASCADE, 
        related_name="results"
    )
    damage_description = models.TextField()
    damage_type = models.CharField(max_length=100)

    def __str__(self):
        return f"Result for Operation {self.operation_image.operation.id}: {self.damage_type}"




class Report(models.Model):
    """
    Represents a report containing metadata about an operation.
    """
    REPORT_STATUS_CHOICES = [
        ('RECEIVED', 'Received'),
        ('PENDING', 'Pending'),
        ('IN_PROGRESS', 'In Progress'),
        ('COMPLETED', 'Completed'),
    ]

    operation = models.ForeignKey(
        Operation,
        on_delete=models.CASCADE,
        related_name="reports"
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name="reports"
    )
    description = models.TextField(blank=True, null=True)
    date = models.DateTimeField(auto_now_add=True)
    status = models.CharField(
        max_length=20,
        choices=REPORT_STATUS_CHOICES,
        default='RECEIVED'
    )

    def __str__(self):
        return f"Report by {self.user.username} on {self.date} - Status: {self.get_status_display()}"

# psql -h localhost -p 5433 -U postgres -d DRD
# docker exec -it drd-postgres-1 psql -U postgres -d DRD