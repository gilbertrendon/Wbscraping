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
    spider = "biologia"
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
