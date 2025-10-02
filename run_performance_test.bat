@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Gravity Particle Simulation Performance Test
echo ========================================

set RESULTS_FILE=performance_results.txt
echo Gravity Particle Simulation Performance Results > %RESULTS_FILE%
echo ======================================== >> %RESULTS_FILE%
echo. >> %RESULTS_FILE%

REM Test C++ Implementation
echo Testing C++ Implementation...
echo C++ Implementation: >> %RESULTS_FILE%
cd C++
if exist gravity_simulation.exe del gravity_simulation.exe
echo   Compiling...
g++ -std=c++11 -O3 gravity_simulation.cpp -o gravity_simulation.exe
if !errorlevel! neq 0 (
    echo   Compilation failed
    echo   Compilation failed >> %RESULTS_FILE%
    cd ..
    goto :python_test
)

echo   Running performance test...
powershell "Measure-Command { .\gravity_simulation.exe } | Select-Object -ExpandProperty TotalMilliseconds" > temp_time.txt
set /p duration_ms=<temp_time.txt
for /f "tokens=* delims= " %%a in ("%duration_ms%") do set duration_ms=%%a

echo   Execution time: %duration_ms% milliseconds
echo   Execution time: %duration_ms% milliseconds >> %RESULTS_FILE%
cd ..

:python_test
echo.
echo Testing Python Implementation...
echo Python Implementation: >> %RESULTS_FILE%
cd Python
echo   Checking for pygame...
python -c "import pygame" > nul 2>&1
if !errorlevel! neq 0 (
    echo   Pygame not found. Installing...
    pip install pygame
    if !errorlevel! neq 0 (
        echo   Failed to install pygame
        echo   Failed to install pygame >> %RESULTS_FILE%
        cd ..
        goto :java_test
    )
)

echo   Running performance test...
powershell "Measure-Command { python gravity_simulation.py } | Select-Object -ExpandProperty TotalMilliseconds" > temp_time.txt
set /p duration_ms=<temp_time.txt
for /f "tokens=* delims= " %%a in ("%duration_ms%") do set duration_ms=%%a

echo   Execution time: %duration_ms% milliseconds
echo   Execution time: %duration_ms% milliseconds >> %RESULTS_FILE%
cd ..

:java_test
echo.
echo Testing Java Implementation...
echo Java Implementation: >> %RESULTS_FILE%
cd Java
if exist GravitySimulation.class del GravitySimulation.class
echo   Compiling...
javac GravitySimulation.java
if !errorlevel! neq 0 (
    echo   Compilation failed
    echo   Compilation failed >> %RESULTS_FILE%
    cd ..
    goto :go_test
)

echo   Running performance test...
powershell "Measure-Command { java GravitySimulation --auto-exit } | Select-Object -ExpandProperty TotalMilliseconds" > temp_time.txt
set /p duration_ms=<temp_time.txt
for /f "tokens=* delims= " %%a in ("%duration_ms%") do set duration_ms=%%a

echo   Execution time: %duration_ms% milliseconds
echo   Execution time: %duration_ms% milliseconds >> %RESULTS_FILE%
cd ..

:go_test
echo.
echo Testing Go Implementation...
echo Go Implementation: >> %RESULTS_FILE%
cd "Go (GoLang)"
echo   Building executable...
go build -o gravity_simulation_go.exe main.go
if !errorlevel! neq 0 (
    echo   Build failed
    echo   Build failed >> %RESULTS_FILE%
    cd ..
    goto :rust_test
)

echo   Running performance test...
powershell "Measure-Command { .\gravity_simulation_go.exe --auto-exit } | Select-Object -ExpandProperty TotalMilliseconds" > temp_time.txt
set /p duration_ms=<temp_time.txt
for /f "tokens=* delims= " %%a in ("%duration_ms%") do set duration_ms=%%a

echo   Execution time: %duration_ms% milliseconds
echo   Execution time: %duration_ms% milliseconds >> %RESULTS_FILE%
cd ..

:rust_test
echo.
echo Testing Rust Implementation...
echo Rust Implementation: >> %RESULTS_FILE%
cd Rust
echo   Building executable...
cargo build --release
if !errorlevel! neq 0 (
    echo   Build failed
    echo   Build failed >> %RESULTS_FILE%
    cd ..
    goto :cleanup
)

echo   Running performance test...
powershell "Measure-Command { .\target\release\gravity_simulation.exe --auto-exit } | Select-Object -ExpandProperty TotalMilliseconds" > temp_time.txt
set /p duration_ms=<temp_time.txt
for /f "tokens=* delims= " %%a in ("%duration_ms%") do set duration_ms=%%a

echo   Execution time: %duration_ms% milliseconds
echo   Execution time: %duration_ms% milliseconds >> %RESULTS_FILE%
cd ..

:cleanup
del temp_time.txt 2>nul

echo.
echo ========================================
echo Performance test completed!
echo Results saved to %RESULTS_FILE%
echo ========================================
pause