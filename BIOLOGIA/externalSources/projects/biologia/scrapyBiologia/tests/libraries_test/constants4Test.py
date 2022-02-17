
class Constants:
    __doc__ = '\n    Class that allows to manage the constant variables of the program,\n    is carried out as a class and using the hint @properties to ensure\n    that the value is not modified during the time of execution.\n    '

    def __init__(self):
        self._Constants__USERDATAJSON = '{{ "identityNumber":"{identityNumber}"}}'
        
        self._Constants__URL = 'https://consejoprofesionaldebiologia.gov.co/servicios/consulta-estado-matricula-profesional/'
    

    @property
    def USERDATAJSON(self):
        """
        Allows to create a base json that contains the basic information
        taken from service body request.
        """
        return self._Constants__USERDATAJSON

    
    @property
    def URL(self):
        """
        Allows to create a start url point to scrape the site.
        """
        return self._Constants__URL

