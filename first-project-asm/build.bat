@echo off

color 0C

:: Assembling
rgbasm -E -o main.o main.asm
if %ERRORLEVEL% NEQ 0 (
    echo:
    echo Failed to Assemble
    exit /b %errorlevel%
)

:: Link .o files together into a ROM
rgblink -n game.sym -o game.gb main.o
if %ERRORLEVEL% NEQ 0 (
    echo:
    echo Failed to Link
    exit /b %errorlevel%
)

:: Fix the checksum of the ROM
rgbfix -v -p 0 game.gb
if %ERRORLEVEL% NEQ 0 (
    echo:
    echo Failed to Fix
    exit /b %errorlevel%
)

color 0A
echo Assemble succes, Loading ROM...

:: Loading the ROM for testing
"%BGB%\bgb" game.gb