@echo off
powershell -NoProfile -ExecutionPolicy unrestricted -Command "& '%ChocolateyToolsLocation%\EKOLOGIC\choco-dependencies.ps1'  %*"
