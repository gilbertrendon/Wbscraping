
# ejecutar desde cualquier ubicacion ya que tiene rutas absolutas
$locationdir = $MyInvocation.MyCommand.Path
$dir = Split-Path $locationdir

Push-Location $dir

venv\Scripts\Activate.ps1

Set-Location externalSources/projects/biologia/scrapyBiologia/scrapyBiologia

$env:urlQueue="https://sqs.us-east-1.amazonaws.com/698662101601/nu0030001-fuentes-externas-dev-biologia.fifo"
$env:urlQueueAns="https://sqs.us-east-1.amazonaws.com/698662101601/queueEntregaaCSV.fifo"

$env:AWS_ACCESS_KEY_ID="AKIA2FK4BUJQ35FHF25R"
$env:AWS_SECRET_ACCESS_KEY="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"

python listener.py

Pop-Location

