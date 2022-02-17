# ejecutar desde cualquier ubicacion ya que tiene rutas absolutas
$locationdir = $MyInvocation.MyCommand.Path
$dir = Split-Path $locationdir

Push-Location $dir

venv\Scripts\Activate.ps1

# :AWS_SQS_QUEUE_URL="https://sqs.us-east-1.amazonaws.com/698662101601/nu0030001-fuentes-externas-dev-biologia.fifo"
$env:AWS_SQS_QUEUE="nu0030001-fuentes-externas-dev-biologia.fifo"
$env:AWS_ACCESS_KEY_ID="AKIA2FK4BUJQ35FHF25R"
$env:AWS_SECRET_ACCESS_KEY="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"
$env:AWS_DEFAULT_REGION="us-east-1"

python ./sqs_client.py

Pop-Location
