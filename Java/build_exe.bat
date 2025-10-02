@echo off
echo Building Java Gravity Simulation Executable...
javac GravitySimulation.java
jar cfe GravitySimulation.jar GravitySimulation *.class
echo Build complete. JAR file created.
pause