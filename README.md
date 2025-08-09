# Subscription Tracker App

A comprehensive Flutter application for tracking subscription services like Netflix, Amazon Prime, JioHotstar, etc. The app helps users manage their subscriptions, track usage, and get notifications for due dates and unused services. Now includes secure user authentication and session management.

## Features

### 🔐 Authentication System
- **Secure Login/Register**: Email and password authentication
- **Session Management**: Automatic login persistence using secure storage
- **Password Security**: SHA-256 hashed passwords for enhanced security
- **Logout Functionality**: Secure logout with session cleanup
- **Demo Credentials**: Use any email with password "password123" for testing

### 📱 Core Features
- **Subscription Management**: Add, edit, and delete subscriptions
- **Due Date Tracking**: Visual progress bars and countdown timers
- **Usage Monitoring**: Track hours used and calculate hourly rates
- **Smart Notifications**: Get alerts for due dates and unused subscriptions
- **Cancellation Support**: Easy subscription cancellation from the app

## Features

### 📱 Core Features
- **Subscription Management**: Add, edit, and delete subscriptions
- **Due Date Tracking**: Visual progress bars and countdown timers
- **Usage Monitoring**: Track hours used and calculate hourly rates
- **Smart Notifications**: Get alerts for due dates and unused subscriptions
- **Cancellation Support**: Easy subscription cancellation from the app

### 🔔 Notification System
- **Due Date Alerts**: Notifications when subscriptions are due within 7 days
- **Usage Alerts**: Warnings when subscriptions haven't been used for 7+ days
- **Smart Recommendations**: Suggests cancellation for unused subscriptions

### 📊 Analytics & Insights
- **Total Cost Overview**: Monthly subscription cost tracking
- **Usage Analytics**: Hourly rate calculations and usage patterns
- **Due Soon Dashboard**: Quick view of upcoming renewals
- **Overdue Tracking**: Monitor overdue subscriptions

## Tech Stack

### Frontend (Flutter)
- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **HTTP**: API communication
- **Shared Preferences**: Local data storage
- **Flutter Local Notifications**: Push notifications
- **Intl**: Date formatting and localization

### Backend (Node.js)
- **Express.js**: REST API server
- **MongoDB**: Database
- **Mongoose**: ODM for MongoDB
- **CORS**: Cross-origin resource sharing

## Project Structure

```
SUBS/
├── subscription-backend/          # Node.js backend
│   ├── models/
│   │   └── Subscription.js       # MongoDB schema
│   ├── routes/
│   │   └── subscriptions.js      # API endpoints
│   ├── utils/                    # Utility functions
│   └── server.js                 # Express server
└── lib/                          # Flutter frontend
    ├── models/
    │   └── subscription.dart     # Data model
    ├── providers/
    │   └── subscription_provider.dart  # State management
    ├── services/
    │   ├── api_service.dart      # API communication
    │   └── notification_service.dart    # Notifications
    ├── screens/
    │   ├── home_screen.dart      # Main dashboard
    │   └── add_subscription_screen.dart # Add subscription form
    ├── widgets/
    │   ├── subscription_card.dart # Subscription display
    │   ├── overview_card.dart    # Statistics cards
    │   └── add_subscription_button.dart # FAB
    └── main.dart                 # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Node.js (14.0.0 or higher)
- MongoDB (local or cloud)

### Authentication Setup
The app now includes a complete authentication system:

1. **Demo Login**: Use any email with password "password123"
2. **Registration**: Create new accounts with email and password
3. **Session Persistence**: Login state is automatically saved
4. **Secure Logout**: Logout clears all session data

### Login Credentials
- **Email**: any@example.com (or any valid email)
- **Password**: password123

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd subscription-backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Create environment file**:
   Create a `.env` file in the backend directory:
   ```
   MONGO_URI=mongodb://localhost:27017/subscription_tracker
   PORT=5000
   ```

4. **Start the server**:
   ```bash
   npm start
   ```

### Frontend Setup

1. **Navigate to project root**:
   ```bash
   cd SUBS
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## API Endpoints

### Subscriptions
- `GET /api/subscriptions` - Get all subscriptions
- `POST /api/subscriptions` - Add new subscription
- `DELETE /api/subscriptions/:id` - Delete subscription

## Usage Guide

### Adding Subscriptions
1. Tap the "Add Subscription" button
2. Enter subscription name (e.g., "Netflix", "Amazon Prime")
3. Set monthly price in rupees
4. Choose due date
5. Toggle auto-pay if applicable
6. Save the subscription

### Tracking Usage
1. Tap on any subscription card
2. Use the "Update Usage" button
3. Enter hours used this month
4. The app calculates hourly rate automatically

### Managing Subscriptions
- **Swipe left** on any subscription to reveal actions
- **Update Usage**: Track your usage hours
- **Delete**: Remove subscription from tracking
- **Cancel Sub**: Mark subscription for cancellation

### Notifications
- **Due Date Alerts**: Receive notifications 7 days before renewal
- **Usage Alerts**: Get warnings for unused subscriptions
- **Smart Recommendations**: App suggests cancellation for unused services

## Features in Detail

### Usage Tracking
- Manual entry of usage hours
- Automatic hourly rate calculation
- Usage history tracking
- Last used date monitoring

### Smart Notifications
- **Due Date Notifications**: Alert when subscription is due within 7 days
- **Usage Notifications**: Warn when subscription unused for 7+ days
- **Cancellation Suggestions**: Recommend cancellation for unused services

### Visual Indicators
- **Progress Bars**: Visual representation of billing cycle
- **Color Coding**: Green (active), Orange (due soon), Red (overdue)
- **Status Badges**: Clear subscription status indicators

### Data Management
- **Local Storage**: Offline data persistence
- **Cloud Sync**: Real-time backend synchronization
- **Error Handling**: Graceful error recovery

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please open an issue in the repository. 