import os
import scrapy
import pytest
import sys
import json
from urllib import parse
stepDir = os.path.dirname(sys.path[0])
sys.path.append(os.path.join(stepDir, 'libraries_test'))
from libraries_test.constants4Test import Constants as testSpecificCons
dirRelativeParents = '.'
sys.path.append(os.path.normpath(os.path.join(stepDir, dirRelativeParents)))
from scrapyBiologia.spiders.biologia import BiologiaSpider
from scrapy.http import Request, TextResponse, Response
# from requests.models import Response

class Test_BiologiaSpider:
    __doc__ = "\n    This class allows to test the 'Inpec' page spider: www.adres.gov.co/Compensacion/Consultas-y-estadisticas/CONSULTA-AFILIADOS-COMPENSADOS\n    "

    # Setup configurations
    testSpecificCons = testSpecificCons()
    testJsonForm = json.loads(testSpecificCons.USERDATAJSON.format(
      identityNumber = '91527913'))
    spider = BiologiaSpider(jsonUserData=(json.dumps(testJsonForm)))
    
    def mock_response(self, file_name=None, url=None, request=None):
        """Create a Scrapy fake HTTP response from a HTML file"""
        if not url:
            url = self.testSpecificCons.URL
        if not request:
            request_ = Request(url=url)
        else:
            request_ = Request(url=url, body=request)
            
        if file_name:
            if not file_name[0] == '/':
                responses_dir = os.path.dirname(os.path.realpath(__file__))
                file_path = os.path.join(responses_dir, "mockHtmlResponses", file_name)
            else:
                file_path = file_name
            file_content = open(file_path, 'r',encoding="utf8").read()
        else:
            file_content = ''
        response = TextResponse(url=url, request=request_, body=file_content,
                                encoding='utf-8')
        return response

    def test_start_requests(self):
        response_dummy = self.mock_response('biologia_start.html')
        response = TextResponse(str(next(self.spider.start_requests()).url))
        assert str(response_dummy) == str(response)

    def test_parse(self):
        response_dummy = self.mock_response('biologia_start.html')
        response = next(self.spider.parse(response_dummy))
        response = parse.parse_qs(response.body.decode('utf-8'))
        assert response['cedula'] != ""
        
        
      
   