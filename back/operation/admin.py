from django.contrib import admin
from operation.models import Operation, OperationImage, OperationResult,Report

admin.site.register(Operation)  
admin.site.register(OperationImage)
admin.site.register(OperationResult)
admin.site.register(Report)
