$locationdir = $MyInvocation.MyCommand.Path
$dir = Split-Path $locationdir

Push-Location $dir

python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements_dev.txt
xcopy .\resources.py .\venv\Lib\site-packages\scrapyrt\  /Y
xcopy .\default_settings.py .\venv\Lib\site-packages\scrapyrt\conf\  /Y

Get-Location
