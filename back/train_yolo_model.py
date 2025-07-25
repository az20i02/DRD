from ultralytics import YOLO

model = YOLO('runs/detect/train8/weights/last.pt')  # Load the last saved checkpoint
model.train(data='/Users/aziz/Desktop/GP/DRD/rdd2022.yaml', epochs=37, pretrained=True)
