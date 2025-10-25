@ECHO ON

cd /d "C:\Users\alyss\OneDrive\Documents\Positron Testing\clairakitty-stats\"

REM Activate the virtual environment
call .venv\Scripts\activate.bat

python ao3_stat_scrape.py

pause 

REM Deactivate the virtual environment (optional, but good practice if not exiting)
deactivate
