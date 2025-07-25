# DRD (Damaged Road Detection)

<p align="center">
  <img src="assets/images/logo.png" alt="DRD Logo" width="200"/>
</p>

## Table of Contents
- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Solution](#solution)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Installation](#installation)
- [User Workflows](#user-workflows)
- [AI Model Details](#ai-model-details)
- [Project Structure](#project-structure)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [License](#license)

## Overview
DRD (Damaged Road Detection) is an innovative mobile application that revolutionizes road damage reporting and management through AI-powered detection and a streamlined communication system between citizens and road maintenance workers.

## Problem Statement
Road damage is a critical infrastructure issue affecting:
- Public safety
- Vehicle maintenance costs
- Transportation efficiency
- Resource allocation for repairs

Traditional reporting methods are often:
- Slow and inefficient
- Lack accurate documentation
- Have poor communication channels
- Result in delayed repairs

## Solution
DRD provides a comprehensive solution by:
- Automating damage detection using AI
- Streamlining the reporting process
- Connecting citizens directly with maintenance workers
- Providing real-time status updates
- Enabling efficient resource allocation

## Technology Stack

### Frontend (Mobile Application)
- **Framework**: Flutter
- **Language**: Dart
- **Key Packages**:
  - Firebase Integration
  - REST API Client
  - Image Processing
  - Real-time Notifications

### Backend (API Server)
- **Framework**: Django REST Framework
- **Language**: Python
- **Database**: Default Django Database
- **Key Components**:
  - JWT Authentication
  - Custom User Management
  - Media File Handling
  - Push Notification Service

### Machine Learning
- **Model**: YOLOv8
- **Training Dataset**: Road Damage Dataset
  - 3,321 labeled images
  - 6,999 annotated objects
  - 4 damage classes:
    1. Potholes (2,657 instances)
    2. Lateral Cracks (2,156 instances)
    3. Longitudinal Cracks (1,222 instances)
    4. Alligator Cracks (964 instances)

## Features

### Core Features
1. **Automated Damage Detection**
   - Real-time classification
   - Multiple damage type detection
   - High accuracy recognition

2. **Location Services**
   - Precise GPS tracking
   - Interactive map interface
   - Route optimization

3. **Real-time Notifications**
   - Status updates
   - New report alerts
   - Completion notifications

4. **Report Management**
   - Detailed documentation
   - Progress tracking
   - Historical data analysis

5. **User Management**
   - Role-based access
   - Secure authentication
   - Profile management

## Installation

### Prerequisites
- Flutter SDK
- Python 3.8+
- Django
- PostgreSQL
- Firebase account

### Frontend Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/DRD.git

# Navigate to project directory
cd DRD

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Setup
```bash
# Navigate to backend directory
cd back

# Create virtual environment
python -m venv env

# Activate virtual environment
source env/bin/activate  # Linux/Mac
env\\Scripts\\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Start server
python manage.py runserver
```

## User Workflows

### Citizen User Flow
1. **Registration & Login**
   - Create account
   - Verify account
   - Login

2. **Report Damage**
   - Take photo
   - AI detection
   - Add details
   - Submit report

3. **Track Reports**
   - View history
   - Check status
   - Receive updates

### Worker User Flow
1. **Worker Authentication**
   - Secure login
   - Access dashboard

2. **Manage Reports**
   - View assignments
   - Access details
   - Update status
   - Document repairs

3. **Task Management**
   - Prioritize repairs
   - Update progress
   - Complete tasks

## AI Model Details

### Dataset Information
- Source: [Road Damage Dataset](https://datasetninja.com/road-damage)
- Size: 3,321 images
- Annotations: 6,999 objects
- Classes: 4 damage types

### Training Process
1. **Dataset Preparation**
   - Image preprocessing
   - Annotation formatting
   - Train/validation split

2. **Model Architecture**
   - YOLOv8 implementation
   - Custom modifications
   - Mobile optimization

3. **Training Parameters**
   - Transfer learning
   - Data augmentation
   - Performance optimization

## Project Structure
```
DRD/
├── lib/                 # Flutter frontend code
│   ├── API/            # API integration
│   ├── models/         # Data models
│   ├── screens/        # UI screens
│   └── shared/         # Shared components
├── back/               # Django backend
│   ├── api/           # REST API endpoints
│   ├── models/        # Database models
│   └── services/      # Business logic
└── assets/            # Static resources
```

## Future Enhancements

### Planned Features
1. **AI Improvements**
   - Continuous training
   - New damage types
   - Severity assessment

2. **Platform Extensions**
   - Web dashboard
   - Analytics tools
   - City service integration

3. **User Experience**
   - Offline mode
   - Advanced filters
   - Community features

## Contributing
We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- Road Damage Dataset from [Dataset Ninja](https://datasetninja.com/road-damage)
- All contributors and supporters of the project
