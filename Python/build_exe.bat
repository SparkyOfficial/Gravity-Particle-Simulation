@echo off
echo Building Python Gravity Simulation Executable...
pyinstaller --onefile gravity_simulation.py
echo Build complete. Executable is in the dist folder.
pause