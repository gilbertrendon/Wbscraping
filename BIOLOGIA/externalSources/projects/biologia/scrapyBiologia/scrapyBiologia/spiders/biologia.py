# -*- coding: utf-8 -*-
import scrapy
import logging
import sys
import json
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '../../..'))
from libraries.constants import Constants as SpecificCons
 
sys.path.append(os.path.join(os.path.dirname(__file__), '../../../../..'))
from generalLibraries.constants import Constants as GeneralCons

class BiologiaSpider(scrapy.Spider):
    """
    This class allows to scrape the einforma page.
    eInforma is a brand of INFORMA COLOMBIA S.A, leader in the supply market of Commercial, Financial and Marketing Information of Colombian companies

    Returns the data of a person according to the initial parameters that are sent.

    To consult the data of a person using POST, the service must be started
    from scrapyrt like this: scrapyry -p 9081.

    Then, the data that is sent by POST must have the following structure:
        {
            "jsonUserData":"{\"identityNumber\":\"91527913\"}",
            "spider_name":"biologia",
            "start_requests": "True"
        }

    The json returned by the spider has the following structure:

        {
            "status": "ok",
            "items": [
                {
                    "DATA": {
                        "respuesta": [
                            {
                                "estado": "El CONSEJO PROFESIONAL DE BIOLOGÍA se permite informar que JORGE ENRIQUE AVENDAÑO CARREÑO identificado(a) con CC 91527913 se encuentra registrado(a) ante esta entidad y su matrícula profesional se encuentra ACTIVA."
                            }
                        ]
                    }
                }
            ]
    
     
    """

    specificCons = SpecificCons()
    generalCons = GeneralCons()
    name = "biologia"
    mainUrl = "https://consejoprofesionaldebiologia.gov.co/servicios/consulta-estado-matricula-profesional/"
    urlCons="https://consejoprofesionaldebiologia.gov.co/app/api.php/Consultar_Estado_Publico"
    startUrls = [mainUrl]
    jsonUserData = None
    __allowed = ("jsonUserData")

    def __init__(self, *args, **kwargs):
        logger = logging.getLogger('scrapy.spidermiddlewares.httperror')
        logger.setLevel(logging.ERROR)
        super(BiologiaSpider, self).__init__(*args, **kwargs)

        for k, v in kwargs.items():
            if( k in self.__class__.__allowed):
                setattr(self, k, v)
        self.jsonUserData = json.loads(self.jsonUserData)
        print(self.jsonUserData['identityNumber'])

    def start_requests(self):

        """
        Allows to consult the main page of ruaf. Returns the response of the page.
        """
        for url in self.startUrls:
            yield scrapy.Request(url=url,callback=self.parse)
        
    def parse(self,response): 
        
                
        jsonForm = json.loads(self.specificCons.JSONFORMUSER.format(
            cedula = self.jsonUserData["identityNumber"]
        ))
        yield scrapy.FormRequest(url=self.urlCons,formdata=jsonForm,callback=self.parseInfor,method="POST")
    
        
    def parseInfor(self,response):
        print("response parse infor=====>", response)
        result =  response.json();
        estado = result[0]['Estado']   
         
        
        infoResult = json.loads(self.specificCons.JSONRESULT().format(
            estado =  estado          
        ))
        infoResult = {self.specificCons.INFORBIOLOGIA: [infoResult]}
        finalOutput = { self.generalCons.INFOPROJECTS: infoResult}
        
        print(finalOutput)
        yield finalOutput