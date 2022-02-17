
import pytest
import sys
import os
import random
import json

stepDir = os.path.dirname(sys.path[0])
dirRelativeParents = "."
sys.path.append(os.path.normpath(os.path.join(stepDir, dirRelativeParents)))
from scrapyBiologia import listener

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

