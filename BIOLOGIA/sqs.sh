#!/bin/bash
##################################################################################################
# Author: Anderson Buitron Papamija
# Descripcion: Este script se encarga de configurar el proyecto scrapyrt para que se adapte al sistema
# de colas SQS definido por Bancolombia
# 
##################################################################################################

thepython="python3"
path_secproyecto_windows=$1

if [ -z "$path_secproyecto_windows" ]; then
    path_rute_script=$(pwd)
    path_secproyecto_windows=$(wslupath $path_rute_script 2> /dev/null)
else
    path_rute_script=$(wslpath "$path_secproyecto_windows")
fi
echo "path_rute_script: $path_rute_script"

##################################################################################################
# verificar si existe el directorio externalSources
##################################################################################################

if [ ! -d "./externalSources" ]; then
    echo "No existe el directorio externalSources"
    exit 1
fi


##################################################################################################
# variables de entorno
##################################################################################################

nombre_cola="nu0030001-fuentes-externas-dev-procuraduria.fifo"
urlcola="https://sqs.us-east-1.amazonaws.com/698662101601/$nombre_cola"
urlcolaAns="https://sqs.us-east-1.amazonaws.com/698662101601/queueEntregaaCSV.fifo"
access_key_id="AKIA2FK4BUJQ35FHF25R"
secret_access_key="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"
AWS_REGION="us-east-1" # us-east-1

path_rute_script=$(pwd)

# aui ruta de scrapy-project

ruta_padre_proy_scrapy=$(find ./externalSources/ -name 'scrapy.cfg' -print0 | sed 's|/scrapy.cfg.*||g' )
echo "ruta ruta_padre_proy_scrapy: " $ruta_padre_proy_scrapy

##################################################################################################
# obtener la codificacion del archivo "requirements.txt"
##################################################################################################
codificacion=$(file -b --mime-encoding requirements.txt)
# verificar si el archivo "requirements.txt" esta en utf-8 o ascii
if [ "$codificacion" = "utf-8" ] || [ "$codificacion" = "ascii" ] || [ "$codificacion" = "us-ascii" ]; then
    echo "El archivo requirements.txt esta en utf-8 o ascii"
else
    echo "El archivo requirements.txt no esta en utf-8 o ascii"
    echo "Se procedera a codificar el archivo requirements.txt"
    
    # convertir archivo requirements en formato UTF-8
    iconv -f $codificacion -t 'UTF-8' requirements.txt -o requirements.txt

fi


##################################################################################################
# verificar que libreria boto3 este en el archivo requirements.txt
##################################################################################################
if ! grep -q "boto3" requirements.txt; then
    echo "boto3 no esta en el requirements.txt, agregando..."
    # Agregar ibrerias adicionales al archivo requirements.txt
        echo "
boto3==1.20.27 
datetime==4.3" >> ./requirements.txt
    # inicializar entorno python mediante script de powershell

    # eliminar archivos a reemplazar en instalacion
    rm -f ./venv/Lib/site-packages/scrapyrt/conf/default_settings.py
    rm -f ./venv/Lib/site-packages/scrapyrt/resources.py

    # instalar librerias
    powershell.exe -File ".\instalar_dev.ps1"
fi

##################################################################################################
# obtener json archivo de pruebas REST-Project-1-readyapi-project.xml
##################################################################################################
json_completo=$($thepython -c '
import re

# abrir xml
f = open("./test/REST-Project-1-readyapi-project.xml", "r")
# unir todas las lineas del archivo
texto = f.read()

# cerrar archivo
f.close()

texto = texto.replace("\t", "")
texto = texto.replace("\n", "")
# extraer objeto json
patron = re.compile(r"\>\s*(\{[^<]*\})\s*\<")
jsonstring = patron.findall(texto)[0]
print(jsonstring)
')

# echo "json_parametros: " $json_completo


##################################################################################################
# obtener spider_name
##################################################################################################
nombre_spider=$($thepython -c "
json_completo = $json_completo
# extraer objeto json
nombre = json_completo['spider_name']
print(str(nombre))
")

echo "nombre_spider: " $nombre_spider

##################################################################################################
# crear cola si no existe
##################################################################################################
nombre_cola=$(./venv/Scripts/python.exe -c "
import boto3
sqs = boto3.resource('sqs', aws_access_key_id='$access_key_id', aws_secret_access_key='$secret_access_key', region_name='$AWS_REGION', verify=False)
queue = None
nombre_cola = 'nu0030001-fuentes-externas-dev-$nombre_spider.fifo'
try:
    queue = sqs.get_queue_by_name(QueueName=nombre_cola)
except:
    pass
if queue is None:
    # No existe la cola, se procedera a crearla
    queue = sqs.create_queue(
        QueueName=nombre_cola,
        Attributes={
            'FifoQueue':'true',
            'DeduplicationScope': 'messageGroup',
            'ContentBasedDeduplication': 'true'
        }
    )


# You can now access identifiers and attributes
print(nombre_cola, end='')

")

echo "nombre cola:" $nombre_cola
urlcola="https://sqs.us-east-1.amazonaws.com/698662101601/$nombre_cola"
# exit 


##################################################################################################
# obtener json de parametros
##################################################################################################
json_parametros=$($thepython -c "
json_completo=$json_completo
print(json_completo['jsonUserData'])

")

echo "json_parametros: " $json_parametros

##################################################################################################
# optener json de entrada para el archivo listener.py
##################################################################################################
jsontransformado=$($thepython -c '
import json

objjson = '"$json_parametros"'

objeto = {}
for (k,v) in objjson.items():
    if(k == "rowId"):
        continue
    else:
        objeto[k] = "\" + record[\""+k+"\"] +\""

jsontransformado = str(objeto)
jsontransformado = jsontransformado.replace("'\''", "\\\"")
print(jsontransformado)

')

echo "jsontransformado: " $jsontransformado

# ir a la carpeta de la ruta padre scrapy
cd $ruta_padre_proy_scrapy
nombreproyScrapy=$( ls -d */ | grep "scrapy") 
path_proyScrapy=$ruta_padre_proy_scrapy'/'$nombreproyScrapy
# quitar barra al final de la ruta path_proyScrapy
path_proyScrapy=$(echo $path_proyScrapy | sed 's/\/$//' | sed 's|^\.\/||')

echo "path_proyScrapy: " $path_proyScrapy
cd $path_rute_script

##################################################################################################
# Ajuste archivo Dockerfile
##################################################################################################

echo "Actualizando Dockerfile ... "

cat <<EOF > Dockerfile
FROM artifactory.apps.bancolombia.com/devops/python:3.7.9-slim-buster

USER root
COPY . .

ENV urlQueue=#{urlQueue}#
ENV urlQueueAns=#{queue_url_send}#

RUN pip install -r requirements.txt -i https://artifactory.apps.bancolombia.com/api/pypi/pypi-bancolombia/simple --trusted-host artifactory.bancolombia.corp

#Expose port
EXPOSE 8080

RUN rm -rf /usr/local/lib/python3.7/site-packages/scrapyrt/conf/default_settings.py
COPY ./default_settings.py /usr/local/lib/python3.7/site-packages/scrapyrt/conf

RUN rm -rf /usr/local/lib/python3.7/site-packages/scrapyrt/resources.py
COPY ./resources.py /usr/local/lib/python3.7/site-packages/scrapyrt

RUN mkdir -p /opt/externalSources
COPY externalSources/ /opt/externalSources
 
WORKDIR /opt/$path_proyScrapy

ENTRYPOINT scrapyrt -i 0.0.0.0 -p 8080 & python listener.py
EOF

##################################################################################################
# crear archivo enviar_mensaje_sqs_client.ps1
##################################################################################################

cat <<EOF > enviar_mensaje_sqs_client.ps1
# ejecutar desde cualquier ubicacion ya que tiene rutas absolutas
\$locationdir = \$MyInvocation.MyCommand.Path
\$dir = Split-Path \$locationdir

Push-Location \$dir

venv\Scripts\Activate.ps1

# $env:AWS_SQS_QUEUE_URL="$urlcola"
\$env:AWS_SQS_QUEUE="$nombre_cola"
\$env:AWS_ACCESS_KEY_ID="$access_key_id"
\$env:AWS_SECRET_ACCESS_KEY="$secret_access_key"
\$env:AWS_DEFAULT_REGION="us-east-1"

python ./sqs_client.py

Pop-Location
EOF

spiderupper=$(echo $nombre_spider | tr '[:lower:]' '[:upper:]')

##################################################################################################
# crear archivo sqs_client.py
##################################################################################################

cat <<EOF > sqs_client.py 
import boto3
import os

#Get the service resource
sqs = boto3.resource('sqs', region_name='us-east-1')

message = """
    {
        "filename": "$spiderupper/9256d81.csv",  
        "recordNumber": 27,  
        "source": "$spiderupper", 
        "retries": "3",  
        "partsNumber": 3,  
        "part": 2,  
        "rows": [{"row": $json_parametros, "scrapingResult": null}]
    }
"""

queue_name = os.environ["AWS_SQS_QUEUE"] 
messageGroupId = "0"

# Get the queue
queue = sqs.get_queue_by_name(QueueName=queue_name)
# limpiar cola
queue.purge()
# Create a new message
response = queue.send_message(MessageBody=message, MessageGroupId=messageGroupId)
# Get the message ID and MD5
print(response.get('MessageId'))
print(response.get('MD5OfMessageBody'))

EOF

##################################################################################################
# crear archivo para ejecutar proyecto con cola de mensajes ejecutar_dev_sqs
##################################################################################################

cat <<EOF > ejecutar_dev_sqs.ps1

# ejecutar desde cualquier ubicacion ya que tiene rutas absolutas
\$locationdir = \$MyInvocation.MyCommand.Path
\$dir = Split-Path \$locationdir

Push-Location \$dir

venv\Scripts\Activate.ps1

Set-Location $path_proyScrapy

\$env:urlQueue="$urlcola"
\$env:urlQueueAns="$urlcolaAns"

\$env:AWS_ACCESS_KEY_ID="$access_key_id"
\$env:AWS_SECRET_ACCESS_KEY="$secret_access_key"

python listener.py

Pop-Location

EOF

##################################################################################################
# crear archivo para simular cola de mensajes y enviar mensaje directo a listener.py
##################################################################################################

cat <<EOF > ejecutar_listener_local.py
# ejecutar este script en la carpeta del spider, donde se encuentra el archivo scrapy.cfg

import sys
import os
import json

sys.path.append(os.path.join(os.path.dirname(__file__), './$path_proyScrapy'))

from listener import Listener

mock_data = json.loads('{"filename":"$spiderupper/9256d81.csv","recordNumber":27,"source":"$spiderupper","retries":"1","partsNumber":"3","part":"2","rows":[{"row": $json_parametros,"scrapingResult":null}]}')

os.environ["urlQueue"]="$urlcola"
os.environ["urlQueueAns"]="$urlcolaAns"

spider = "$nombre_spider"
response = Listener().scrapping(mock_data, spider)

EOF

# ubicarse en la carpeta del proyecto scrapy
cd $path_proyScrapy

##################################################################################################
# crear archivo listener.py
##################################################################################################

cat <<EOF > listener.py 
import boto3
import subprocess
import json
import datetime
import logging
import os
import time

class Listener():


    def __init__(self):
        
        logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.StreamHandler()
        ])

        self.AWS_REGION="us-east-1" 
        self.queue_url = os.environ["urlQueue"] 
        self.queue_url_send = os.environ["urlQueueAns"]

        # Create SQS client
        self.sqs = boto3.client('sqs', region_name=self.AWS_REGION)
        self.messageGroupId = 0


    def buildJUserData(self, record):
        strForJson = ("jsonUserData=" + json.dumps(record))
        return strForJson

    def listenMessages(self):
        # Receive message from SQS queue    
        response = self.sqs.receive_message(
            QueueUrl=self.queue_url,
            AttributeNames=[
                'SentTimestamp'
            ],
            MaxNumberOfMessages=5,
            MessageAttributeNames=[
                'All'
            ],
            #VisibilityTimeout=200,
            #WaitTimeSeconds=20
        )
        return response

    def deleteMessage(self, receipt_handle, queue_url):
        # Delete received message from queue
        self.sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        return True


    def validateJson(self, message):
        try:
            data = json.loads(message['Body'])
        except Exception as e:
            logging.error("Error de estructura Json: " + str(e))                 
        return data


    def scrapping(self, data, spider):         
        
        for i, record in enumerate(data["rows"]):        
            
            try:
                strRequest = self.buildJUserData(record["row"])
            except Exception as e:
                logging.error("Error en parametros del Json: " + str(e))
                continue  
            logging.info(strRequest)
            retries = 0
            dataResult = ""

            while(dataResult=="" and retries<=int(data["retries"])):
                retries+=1            
                logging.info("Inicia raspado: "+ str(datetime.datetime.now()))
                try:
                    dataResult = subprocess.run(['scrapy', 'crawl', spider, '-a', strRequest], timeout=60, capture_output=True, text=True) #, shell=True)
                    dataResult = dataResult.stdout.replace("'",'"')
                except Exception as e:
                    logging.error("no pudo raspar el registro" + str(e))
            
            logging.info("Finaliza raspado: "+ str(datetime.datetime.now()) + " : " + str(dataResult))
            if dataResult == "":
                dataResult = "La consulta no fue exitosa"
                    
            data["rows"][i]["scrapingResult"] = dataResult

        return data

    # Send data to queue
    def sendMessage(self, data, queue_url_send, messageGroupId):
        response = self.sqs.send_message(QueueUrl=queue_url_send,
            MessageBody=json.dumps(data),
            MessageGroupId=str(messageGroupId))
        messageGroupId+=1

def main():
    listenerMain = Listener()
    spider = "$nombre_spider"
    while(True): 
        try:
            response = listenerMain.listenMessages()
        except Exception as e:
            logging.error("Error en la conexion SQS (url: "+listenerMain.queue_url+" ) - Error: " + str(e))
            time.sleep(60)
            continue
        
        if not 'Messages' in response:
            continue
        message = response['Messages'][0]
        receipt_handle = message['ReceiptHandle']
        data = listenerMain.validateJson(message)
        data = listenerMain.scrapping(data, spider)
        try:            
            listenerMain.deleteMessage(receipt_handle, listenerMain.queue_url)  
        except Exception as e:
            logging.error("Error eliminando el mensaje" + str(e))  
        listenerMain.sendMessage(data, listenerMain.queue_url_send, listenerMain.messageGroupId)
    
if __name__ == "__main__":
    main()   
EOF


cd "spiders"
# verificar que archivo tiene la subcadena "import scrapy"
archivo_spider=$(find . -name "*.py" -type f -exec grep -l  -E "(import scrapy|from scrapy)" {} \;)


# cambiar cadenas de texto "self.jsonUserData['rowId']" por "1" en archivo spider
sed -i 's/self.jsonUserData\["rowId"\]/1/g' $archivo_spider


##################################################################################################
# test de archivo listener_test.py
##################################################################################################

# path_proytest_scrapy_linx="$ruta_padre_proy_scrapy/tests"
# path_file_listener_test="$path_proytest_scrapy_linx/listener_test.py"
# echo "archivo path_file_listener_test: " $path_file_listener_test

#ubcicarse en la carpeta del padre de listener_test.py

cd ../..

#eliminar "/" de la ruta $nombreproyScrapy
echo "nombreproyScrapy: " $nombreproyScrapy
moduloProyScrapy=${nombreproyScrapy%/}

cat <<EOF > tests/listener_test.py

import pytest
import sys
import os
import random
import json

stepDir = os.path.dirname(sys.path[0])
dirRelativeParents = "."
sys.path.append(os.path.normpath(os.path.join(stepDir, dirRelativeParents)))
from ${moduloProyScrapy} import listener

os.environ["urlQueue"] = "https://sqs.us-east-1.amazonaws.com/698662101601/nu0030001-fuentes-externas-dev-unacola.fifo"
os.environ["urlQueueAns"] = "https://sqs.us-east-1.amazonaws.com/698662101601/queueEntregaaCSV.fifo"
os.environ["AWS_ACCESS_KEY_ID"] = "AKIA2FK4BUJQ35FHF30R"
os.environ["AWS_SECRET_ACCESS_KEY"] = "kgfBtXfFCIxYrDR67oMhJSe97o+WHYvyZaFbyReO"

class Test_Listener:

    listenerTest = listener.Listener()

    def test_buildJUserData(self):
        response_dummy = ("jsonUserData={\"identityNumber\": \"8105161\", \"identificationType\": \"1\", \"nameConsulted\": \"juan\"}")
        record_dummy =   {'identityNumber':'8105161', 'identificationType':'1', 'nameConsulted':'juan'}
        response = self.listenerTest.buildJUserData(record_dummy)
        assert response_dummy == (response)                  
        

    def test_listenMessages(self):
        self.listenerTest.sqs.delete_message = lambda QueueUrl, ReceiptHandle: True
        self.listenerTest.sqs.send_message = lambda QueueUrl, MessageBody, MessageGroupId : True
        self.listenerTest.sqs.receive_message = lambda QueueUrl,AttributeNames,MaxNumberOfMessages,MessageAttributeNames : {"Messages": [{"MessageId": "97", "Body": '\"hello\"'}]}

        groupId = random.randint(1, 100000)
        self.listenerTest.sendMessage("hello", self.listenerTest.queue_url, groupId)

        response = self.listenerTest.listenMessages()
        assert response["Messages"][0]["Body"] == '\"hello\"'

        responsedel = self.listenerTest.deleteMessage(response, self.listenerTest.queue_url)
        assert responsedel == True
        

    def test_validateJson(self):
        
        # validacion de json completa aceptada
        mock_message = {'Body': '{"source":"procuraduria","retries": "3","partsNumber": 3,"part": 2,"rows": [{"row":{"expeditionDate":"28/07/2003","identityNumber":"80858529","identificationType":"5|CC"},"scrapingResult": null}]}', }
        mock_response = self.listenerTest.validateJson(mock_message)
        assert mock_response["rows"][0]["row"]["identityNumber"] == "80858529"

        # Error de acceso a clave Body
        mock_message = {}
        try:
            mock_response = self.listenerTest.validateJson(mock_message)
        except Exception as e:
            assert isinstance(e, UnboundLocalError)
        assert mock_response["rows"][0]["row"]["identityNumber"] == "80858529"


    def test_scrapping(self):
        mock_data = json.loads('{"filename": "procuraduria/9256d81.csv",  "recordNumber": 27,  "source": "procuraduria", "retries": "3",  "partsNumber": 3,  "part": 2,  "rows": [{"row": {"identityNumber": "8105161323", "identificationType": "1", "nameConsulted":"juan"}, "scrapingResult": null}]}')
        response = self.listenerTest.scrapping(mock_data, "spider")

        assert len(response["rows"][0]["scrapingResult"]) != 0
        mock_data = {"rows": [{"row": object}]}
        response = self.listenerTest.scrapping(mock_data, "spider")

    # Mock para el clase Listener
    class ListenerMock():
        queue_url = "https://sqs.us-east-1.amazonaws.com/698662101601/nu0030001-fuentes-externas-dev-spiderSuperfinancieraTRM.fifo"
        queue_url_send = "https://sqs.us-east-1.amazonaws.com/698662101601/queueEntregaaCSV.fifo"
        messageGroupId = 23232

        def listenMessages(self):
            return {"Messages": [{"ReceiptHandle": "97", "Body": {'MessageId': '97', 'ReceiptHandle': 'A==', 'MD5OfBody': '954904f', 'Bodys': '{"filename": "PROCURADURIA/9256d81a.csv","recordNumber":27,"source":"falso","retries": "3","partsNumber": 3,"part": 2,"rows": [{"row":{"expeditionDate":"28/07/2003","identityNumber":"80858529","identificationType":"5|CC"},"scrapingResult": null}]}', 'Attributes': {'SentTimestamp': '1637362021976'}}}]}

        def deleteMessage(self, receipt_handle, queue_url):
            return True

        def validateJson(self, message):
            return True

        def scrapping(self, data, spider):
            return True

        def sendMessage(self, data, queue_url_send, messageGroupId):
            raise ValueError("Este es un error de salida")


    class ListenerMockDelError(ListenerMock):
        
        def deleteMessage(self, receipt_handle, queue_url):
            raise ValueError("Este es un error en deleteMessage")


    def test_main(self):

        # Test de main con listener escenario normal
        listener.Listener = self.ListenerMock
        try:
            listener.main()
        except Exception as e:
            assert isinstance(e, ValueError)

        # Test de main con listener con error en deleteMessage
        listener.Listener = self.ListenerMockDelError
        try:
            listener.main()
        except Exception as e:
            assert isinstance(e, ValueError)

EOF
