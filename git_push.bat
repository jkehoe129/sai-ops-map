@echo off

REM Move to your GitHub repository directory
cd C:\GitHub\sai-ops-map

REM Run git commands
git add .
git commit -m "commit"
git push

timeout /t 10 >nul
