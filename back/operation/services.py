from .models import Operation, OperationImage, OperationResult
from ultralytics import YOLO
import cv2
import os
import logging

logger = logging.getLogger(__name__)

# Constants
MODEL_PATH = os.path.join(os.path.dirname(__file__), '..', 'runs', 'detect', 'train8', 'weights', 'best.pt')
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'media', 'operation_images', 'output')

class_names = {
    0: "Longitudinal Crack (D00)",
    1: "Transverse Crack (D10)",
    2: "Alligator Crack (D20)",
    3: "Pothole (D40)",
    4: "Repaired Damage"
}

# Model cache for better performance
_yolo_model = None

def get_yolo_model():
    """Get cached YOLO model instance."""
    global _yolo_model
    if _yolo_model is None:
        _yolo_model = YOLO(MODEL_PATH)
    return _yolo_model

def create_operation_image(operation, image_file, longitude, latitude):
    """Create OperationImage database record."""
    return OperationImage.objects.create(
        operation=operation,
        original_image=image_file,
        longitude=longitude,
        latitude=latitude
    )

def process_yolo_detections(operation_image, results):
    """Process YOLO detection results and save to database."""
    detections = []
    
    for result in results:
        if result.boxes is not None:
            for box in result.boxes:
                class_id = int(box.cls)
                confidence = float(box.conf)
                bbox = box.xyxy.cpu().numpy()[0]

                # Map damage type and description
                damage_type = class_names.get(class_id, "Unknown Damage Type")
                description = f"Confidence: {confidence:.2f}"

                # Save result to database
                detection = OperationResult.objects.create(
                    operation_image=operation_image,
                    damage_description=description,
                    damage_type=damage_type
                )
                
                detections.append({
                    'detection': detection,
                    'bbox': bbox,
                    'confidence': confidence,
                    'damage_type': damage_type
                })
    
    return detections

def annotate_and_save_image(operation_image, result_img, detections):
    """Annotate image with detections and save to file."""
    try:
        # Annotate image with all detections
        for detection_data in detections:
            bbox = detection_data['bbox']
            confidence = detection_data['confidence']
            damage_type = detection_data['damage_type']
            
            x1, y1, x2, y2 = map(int, bbox)
            cv2.rectangle(result_img, (x1, y1), (x2, y2), (255, 0, 0), 2)
            label = f"{damage_type} ({confidence:.2f})"
            cv2.putText(
                result_img,
                label,
                (x1, y1 - 10),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (255, 0, 0),
                1,
                lineType=cv2.LINE_AA
            )

        # Save the annotated image
        os.makedirs(OUTPUT_DIR, exist_ok=True)
        output_image_path = os.path.join(OUTPUT_DIR, f"{operation_image.id}_labeled.jpg")
        cv2.imwrite(output_image_path, result_img)

        # Update the operated_image field
        operation_image.operated_image = f"operation_images/output/{operation_image.id}_labeled.jpg"
        operation_image.save()
        
        return True
    except Exception as e:
        logger.error(f"Error annotating image {operation_image.id}: {str(e)}")
        return False

def process_single_image(operation, image_file, longitude, latitude, model):
    """Process a single image through the YOLO pipeline."""
    try:
        # Create database record
        operation_image = create_operation_image(operation, image_file, longitude, latitude)
        
        # Run YOLO inference
        input_image_path = operation_image.original_image.path
        results = model(input_image_path)
        
        # Process detections and save to database
        detections = process_yolo_detections(operation_image, results)
        
        # Annotate and save image if there are detections
        if detections and results:
            annotate_and_save_image(operation_image, results[0].orig_img, detections)
        
        return True
    except Exception as e:
        logger.error(f"Error processing image for operation {operation.id}: {str(e)}")
        return False

def process_damage_detection(operation, images, longitude, latitude):
    """
    Process images for damage detection using YOLO model.
    """
    try:
        # Get cached YOLO model
        model = get_yolo_model()
        
        # Process each image
        success_count = 0
        for image_file in images:
            if process_single_image(operation, image_file, longitude, latitude, model):
                success_count += 1
        
        logger.info(f"Successfully processed {success_count}/{len(images)} images for operation {operation.id}")
        
    except Exception as e:
        logger.error(f"Error in damage detection process for operation {operation.id}: {str(e)}")
        # Continue without processing - the operation will still be created
