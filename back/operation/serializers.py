from rest_framework import serializers
from .models import Operation, OperationImage, OperationResult, Report
from .services import process_damage_detection

class OperationResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = OperationResult
        fields = ['id', 'damage_description', 'damage_type']

class OperationImageSerializer(serializers.ModelSerializer):
    results = OperationResultSerializer(many=True, read_only=True)
    operated_image = serializers.SerializerMethodField()

    class Meta:
        model = OperationImage
        fields = ['id', 'longitude', 'latitude', 'original_image', 'operated_image', 'results']

    def get_operated_image(self, obj):
        request = self.context.get('request')
        if obj.operated_image and request:
            return request.build_absolute_uri(obj.operated_image.url)
        return None

class OperationSerializer(serializers.ModelSerializer):
    images = serializers.ListField(
        child=serializers.ImageField(),
        write_only=True
    )
    processed_results = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Operation
        fields = ['id', 'images', 'processed_results']

    def validate(self, data):
        """
        Ensure that longitude and latitude are provided in the request.
        """
        request = self.context.get('request')
        longitude = request.data.get('longitude')
        latitude = request.data.get('latitude')

        if not longitude or not latitude:
            raise serializers.ValidationError("Longitude and latitude are required.")
        
        self.context['longitude'] = float(longitude)
        self.context['latitude'] = float(latitude)
        return data

    def create(self, validated_data):
        images = validated_data.pop('images')
        longitude = self.context.get('longitude')
        latitude = self.context.get('latitude')

        # Create the operation
        operation = Operation.objects.create()

        # Process images using the service
        process_damage_detection(operation, images, longitude, latitude)

        return operation

    def get_processed_results(self, obj):
        """
        Return processed results for the operation.
        """
        images = obj.images.all()
        return OperationImageSerializer(images, many=True, context=self.context).data

class ReportSerializer(serializers.ModelSerializer):
    operation = OperationSerializer(read_only=True)  # used for display
    operation_id = serializers.IntegerField(write_only=True)  # used for POST
    user_info = serializers.SerializerMethodField(read_only=True)  # Add user information

    class Meta:
        model = Report
        fields = ['id', 'description', 'status', 'operation', 'operation_id', 'user_info', 'date']
        read_only_fields = ['user', 'date', 'status']

    def get_user_info(self, obj):
        """
        Return user information for the report.
        """
        return {
            'id': obj.user.id,
            'username': obj.user.username,
            'email': obj.user.email,
            'phone_number': obj.user.phone_number or '',
            'is_worker': obj.user.is_worker
        }

    def validate_operation_id(self, value):
        if Report.objects.filter(operation_id=value).exists():
            raise serializers.ValidationError("This operation is already associated with a report.")
        return value

    def create(self, validated_data):
        user = self.context['request'].user
        operation_id = validated_data.pop('operation_id')
        return Report.objects.create(user=user, operation_id=operation_id, **validated_data)
