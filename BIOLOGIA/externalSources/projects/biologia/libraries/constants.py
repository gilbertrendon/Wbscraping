#!/usr/bin/python

__author__ = "Ultracom"
__license__ = "Users authorized by Bancolombia"
__credits__ = "Ultracom-Bancolombia"
__version__ = "1.0"
__maintainer__ = "Ultracom-Bancolombia"


class Constants:
    """
    Class that allows to manage the constant variables of the program, 
    is carried out as a class and using the hint @properties to ensure
    that the value is not modified during the time of execution.
    """



    def __init__(self):

        self.__JSONRESULT = '''{{"estado":"{estado}"}}'''
        
        self.__JSONFORMUSER = '''{{"cedula":"{cedula}"}}'''

        self.__INFORBIOLOGIA = "respuesta"

        self.__JSONTERMS = '''{{"ctl00$MainContent$RadioButtonList1": "{acceptRadioButton}",
            "ctl00$MainContent$btnEnviar": "{submitButton}"}}'''

        self.__AFFILIATIONXPATH = '''(//tr[td[div[div[text()="{}"]]]]//following-sibling::tr[@valign="top" and td[@colspan="9" or @colspan="8"]])[1]//table//tr[@valign="top"]'''

        
        self.__AFFILIATIONSECTIONS = ["INFORMACIÓN BASICA", "AFILIACIÓN A SALUD",
            "AFILIACIÓN A PENSIONES", "AFILIACIÓN A RIESGOS LABORALES",
            "AFILIACIÓN A COMPENSACIÓN FAMILIAR", "AFILIACIÓN A CESANTIAS",
            "PENSIONADOS", "VINCULACIÓN A PROGRAMAS DE  ASISTENCIA SOCIAL"]

        


    def JSONRESULT(self):
        """
        Allows to create a base json that contains the validation information
        of the forms for the pages that are scraped.
        """
        return self.__JSONRESULT
    
    @property
    def JSONFORMUSER(self):
        """
        Allows to create a base json that contains the validation information
        of the forms for the pages that are scraped.
        """
        return self.__JSONFORMUSER

    @property
    def INFORBIOLOGIA(self):
        """
        Allows to create a base json that contains the data of the user.
        """
        return self.__INFORBIOLOGIA

    @property
    def JSONTERMS(self):
        """
        Allows to create a base json that contains the information where ruaf
        terms and conditions are accepted.
        """
        return self.__JSONTERMS

    @property
    def AFFILIATIONXPATH(self):
        """
        Allows to return the xpath to query the table of a section.
        """
        return self.__AFFILIATIONXPATH

    @property
    def AFFILIATIONSECTIONS(self):
        """
        Allows to return an array containing the sections to be queried.
        """
        return self.__AFFILIATIONSECTIONS