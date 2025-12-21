@ECHO ON

cd /d "C:\Users\alyss\OneDrive\Documents\Positron Testing\clairakitty-stats\"

REM Activate the virtual environment
call .venv\Scripts\activate.bat

python ao3_stat_scrape.py


REM Deactivate the virtual environment (optional, but good practice if not exiting)
deactivate

REM Git commands
git add clairakitty_ao3_work_stats.csv
git commit -m "Auto-update AO3 stats - %date% %time%"
git push
if %errorlevel% neq 0 (
    echo Git push failed!
    exit /b %errorlevel%
)