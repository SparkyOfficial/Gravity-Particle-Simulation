@echo off
echo Building Rust Gravity Simulation Executable...
cargo build --release
echo Build complete. Executable is in target\release folder.
pause