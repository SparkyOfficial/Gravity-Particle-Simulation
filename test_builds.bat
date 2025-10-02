@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Gravity Particle Simulation - Build Test
echo ========================================

set BUILD_LOG=build_log.txt
echo Gravity Particle Simulation Build Log > %BUILD_LOG%
echo ======================================== >> %BUILD_LOG%
echo. >> %BUILD_LOG%

REM Test C++ Build
echo Testing C++ Build...
echo C++ Build: >> %BUILD_LOG%
cd C++
if exist gravity_simulation.exe del gravity_simulation.exe
echo   Compiling...
g++ -std=c++11 -O3 gravity_simulation.cpp -o gravity_simulation.exe >> %BUILD_LOG% 2>&1
if !errorlevel! neq 0 (
    echo   Compilation failed
    echo   Compilation failed >> %BUILD_LOG%
    cd ..
    goto :python_test
)

echo   Build successful
echo   Build successful >> %BUILD_LOG%
cd ..

:python_test
echo.
echo Testing Python Build...
echo Python Build: >> %BUILD_LOG%
cd Python
echo   Checking for pyinstaller...
python -c "import PyInstaller" > nul 2>&1
if !errorlevel! neq 0 (
    echo   PyInstaller not found. Installing...
    pip install pyinstaller >> %BUILD_LOG% 2>&1
    if !errorlevel! neq 0 (
        echo   Failed to install PyInstaller
        echo   Failed to install PyInstaller >> %BUILD_LOG%
        cd ..
        goto :java_test
    )
)

echo   Building executable...
pyinstaller --onefile gravity_simulation.py >> %BUILD_LOG% 2>&1
if !errorlevel! neq 0 (
    echo   Build failed
    echo   Build failed >> %BUILD_LOG%
    cd ..
    goto :java_test
)

echo   Build successful
echo   Build successful >> %BUILD_LOG%
cd ..

:java_test
echo.
echo Testing Java Build...
echo Java Build: >> %BUILD_LOG%
cd Java
if exist GravitySimulation.class del GravitySimulation.class 2>nul
if exist GravitySimulation.jar del GravitySimulation.jar 2>nul
echo   Compiling...
javac GravitySimulation.java >> %BUILD_LOG% 2>&1
if !errorlevel! neq 0 (
    echo   Compilation failed
    echo   Compilation failed >> %BUILD_LOG%
    cd ..
    goto :go_test
)

echo   Creating JAR...
jar cfe GravitySimulation.jar GravitySimulation *.class >> %BUILD_LOG% 2>&1
if !errorlevel! neq 0 (
    echo   JAR creation failed
    echo   JAR creation failed >> %BUILD_LOG%
    cd ..
    goto :go_test
)

echo   Build successful
echo   Build successful >> %BUILD_LOG%
cd ..

:go_test
echo.
echo Testing Go Build...
echo Go Build: >> %BUILD_LOG%
cd "Go (GoLang)"
if exist gravity_simulation_go.exe del gravity_simulation_go.exe 2>nul
echo   Building executable...
go build -o gravity_simulation_go.exe main.go >> %BUILD_LOG% 2>&1
if !errorlevel! neq 0 (
    echo   Build failed
    echo   Build failed >> %BUILD_LOG%
    cd ..
    goto :rust_test
)

echo   Build successful
echo   Build successful >> %BUILD_LOG%
cd ..

:rust_test
echo.
echo Testing Rust Build...
echo Rust Build: >> %BUILD_LOG%
cd Rust
echo   Building executable...
cargo build --release >> %BUILD_LOG% 2>&1
if !errorlevel! neq 0 (
    echo   Build failed
    echo   Build failed >> %BUILD_LOG%
    cd ..
    goto :cleanup
)

echo   Build successful
echo   Build successful >> %BUILD_LOG%
cd ..

:cleanup
echo.
echo ========================================
echo Build test completed!
echo Check %BUILD_LOG% for details
echo ========================================
pause