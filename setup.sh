#!/bin/bash

# Avito Real Estate Predictor - Setup Script
# ==========================================

echo "🏠 Avito Real Estate Predictor Setup"
echo "===================================="

# Check if Python is installed
if ! command -v python &> /dev/null; then
    echo "❌ Python is not installed. Please install Python 3.8+ first."
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Python $PYTHON_VERSION detected. Python $REQUIRED_VERSION+ is required."
    exit 1
fi

echo "✅ Python $PYTHON_VERSION detected"

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"

# Check if model files exist
if [ ! -f "models/best_model.pkl" ] || [ ! -f "models/scaler.pkl" ] || [ ! -f "models/metadata.json" ]; then
    echo "⚠️  Model files not found. Please ensure the following files exist:"
    echo "   - models/best_model.pkl"
    echo "   - models/scaler.pkl"
    echo "   - models/metadata.json"
    echo ""
    echo "Run the training pipeline first:"
    echo "cd notebooks && python script.py"
    exit 1
fi

echo "✅ Model files found"

# Create startup script
cat > start.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Avito Real Estate Predictor"
echo "========================================"

# Function to cleanup background processes
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    kill $(jobs -p) 2>/dev/null
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

# Start FastAPI backend
echo "🔧 Starting FastAPI backend..."
cd backend && python main.py &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 3

# Check if backend is running
if ! curl -s http://localhost:8000/health > /dev/null; then
    echo "❌ Backend failed to start"
    exit 1
fi

echo "✅ Backend running at http://localhost:8000"

# Start Streamlit frontend
echo "🌐 Starting Streamlit frontend..."
cd ../frontend && streamlit run app.py &
FRONTEND_PID=$!

echo "✅ Frontend running at http://localhost:8501"
echo ""
echo "🎉 Both servers are running!"
echo "   - API: http://localhost:8000"
echo "   - Web App: http://localhost:8501"
echo ""
echo "Press Ctrl+C to stop all servers"

# Wait for background processes
wait
EOF

chmod +x start.sh

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "To start the application:"
echo "1. Run: ./start.sh"
echo "2. Or manually:"
echo "   - Backend: cd backend && python main.py"
echo "   - Frontend: cd frontend && streamlit run app.py"
echo ""
echo "📖 Read the README.md for detailed instructions"