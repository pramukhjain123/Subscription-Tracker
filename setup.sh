#!/bin/bash

echo "🚀 Setting up Subscription Tracker App"
echo "======================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

echo "✅ Flutter and Node.js are installed"

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Setup backend
echo "🔧 Setting up backend..."
cd subscription-backend

# Install backend dependencies
echo "📦 Installing backend dependencies..."
npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
MONGO_URI=mongodb://localhost:27017/subscription_tracker
PORT=5000
EOF
    echo "✅ Created .env file"
else
    echo "✅ .env file already exists"
fi

cd ..

echo ""
echo "🎉 Setup complete!"
echo ""
echo "To start the app:"
echo "1. Start MongoDB (if using local)"
echo "2. Start backend: cd subscription-backend && npm start"
echo "3. Start Flutter app: flutter run"
echo ""
echo "Happy coding! 🚀" 