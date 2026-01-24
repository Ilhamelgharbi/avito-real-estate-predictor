@echo off
REM Avito Real Estate Predictor - Windows Setup Script
REM ===================================================

echo 🏠 Avito Real Estate Predictor Setup
echo =====================================

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed. Please install Python 3.8+ first.
    pause
    exit /b 1
)

REM Check Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
set REQUIRED_VERSION=3.8

REM Simple version check (basic check)
echo ✅ Python detected

REM Install uv
echo 📦 Installing uv...
pip install uv

if errorlevel 1 (
    echo ❌ Failed to install uv
    pause
    exit /b 1
)

echo ✅ uv installed successfully

REM Install dependencies
echo 📦 Installing dependencies...
uv pip install -r requirements.txt

if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully

REM Check if model files exist
if not exist "models\best_model.pkl" (
    echo ⚠️  Model files not found. Please ensure the following files exist:
    echo    - models\best_model.pkl
    echo    - models\scaler.pkl
    echo    - models\metadata.json
    echo.
    echo Run the training pipeline first:
    echo cd notebooks ^&^& python script.py
    pause
    exit /b 1
)

if not exist "models\scaler.pkl" (
    echo ⚠️  Scaler file not found
    pause
    exit /b 1
)

if not exist "models\metadata.json" (
    echo ⚠️  Metadata file not found
    pause
    exit /b 1
)

echo ✅ Model files found

REM Create startup script
echo @echo off> start.bat
echo REM Avito Real Estate Predictor - Windows Startup>> start.bat
echo REM ==========================================>> start.bat
echo.>> start.bat
echo echo 🚀 Starting Avito Real Estate Predictor>> start.bat
echo echo =========================================>> start.bat
echo.>> start.bat
echo REM Start FastAPI backend>> start.bat
echo echo 🔧 Starting FastAPI backend...>> start.bat
echo cd backend>> start.bat
echo start "FastAPI Backend" cmd /c "python main.py">> start.bat
echo cd ..>> start.bat
echo.>> start.bat
echo timeout /t 3 /nobreak ^>nul>> start.bat
echo.>> start.bat
echo REM Start Streamlit frontend>> start.bat
echo echo 🌐 Starting Streamlit frontend...>> start.bat
echo cd frontend>> start.bat
echo start "Streamlit Frontend" cmd /c "streamlit run app.py">> start.bat
echo cd ..>> start.bat
echo.>> start.bat
echo echo ✅ Servers started!>> start.bat
echo echo    - API: http://localhost:8000>> start.bat
echo echo    - Web App: http://localhost:8501>> start.bat
echo echo.>> start.bat
echo echo Press any key to exit...>> start.bat
echo pause ^>nul>> start.bat

echo.
echo 🎉 Setup completed successfully!
echo.
echo To start the application:
echo 1. Run: start.bat
echo 2. Or manually:
echo    - Backend: cd backend ^& python main.py
echo    - Frontend: cd frontend ^& streamlit run app.py
echo.
echo 📖 Read the README.md for detailed instructions
echo.
pause