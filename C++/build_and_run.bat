@echo off
echo Building Gravity Particle Simulation...
g++ -std=c++11 -O3 gravity_simulation.cpp -o gravity_simulation.exe
if %errorlevel% neq 0 (
    echo Compilation failed!
    pause
    exit /b %errorlevel%
)

echo Build successful! Running simulation...
gravity_simulation.exe
pause