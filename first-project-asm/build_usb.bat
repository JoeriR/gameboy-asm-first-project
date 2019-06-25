@echo off

:: Assembling
..\..\_Compilers\rgbds_win64\rgbasm -Ev -i src\ -o obj\main.o src\main.asm
::..\..\_Compilers\rgbds_win64\rgbasm -E -o obj\main.o src\main.asm
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo:
    echo Failed to Assemble
    exit /b %errorlevel%
)

:: Link .o files together into a ROM
:: -d enables DMG mode, which disables RAM banks and VRAM bank
..\..\_Compilers\rgbds_win64\rgblink -d -n game.sym -o game.gb obj\main.o
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo:
    echo Failed to Link
    exit /b %errorlevel%
)

:: Fix the checksum of the ROM
..\..\_Compilers\rgbds_win64\rgbfix -v -p 0 game.gb
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo:
    echo Failed to Fix
    exit /b %errorlevel%
)

color 0A
echo Assemble succes, Loading ROM...

:: Loading the ROM for testing
..\..\_Tools\BGB\bgb game.gb