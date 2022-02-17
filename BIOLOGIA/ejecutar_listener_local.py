# ejecutar este script en la carpeta del spider, donde se encuentra el archivo scrapy.cfg

import sys
import os
import json

sys.path.append(os.path.join(os.path.dirname(__file__), './externalSources/projects/biologia/scrapyBiologia/scrapyBiologia'))

from listener import Listener

mock_data = json.loads('{"filename":"BIOLOGIA/9256d81.csv","recordNumber":27,"source":"BIOLOGIA","retries":"1","partsNumber":"3","part":"2","rows":[{"row": {"identityNumber":"91527913"},"scrapingResult":null}]}')

os.environ["urlQueue"]="https://sqs.us-east-1.amazonaws.com/698662101601/nu0030001-fuentes-externas-dev-biologia.fifo"
os.environ["urlQueueAns"]="https://sqs.us-east-1.amazonaws.com/698662101601/queueEntregaaCSV.fifo"

spider = "biologia"
response = Listener().scrapping(mock_data, spider)

