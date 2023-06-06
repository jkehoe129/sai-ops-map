@echo off

REM Move to your GitHub repository directory
cd C:\GitHub\sai-ops-map

REM Run git commands
gh repo clone jkehoe129/sai-ops-map
git add .
git commit -m "commit"
git push

pause
