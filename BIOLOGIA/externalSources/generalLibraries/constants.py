#!/usr/bin/python
import os

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
        self.__OK = 0
        self.__FAIL = 1
        self.__ERROR = -1
        self.__NODATA = 100
        self.__INFOPROJECTS = "DATA"
        self.__INFOID = "ID"

    @property
    def OK(self):
        """
        It allows to indicate that the process was carried out correctly 
        without errors.
        """
        return self.__OK

    @property
    def FAIL(self):
        """
        It allows to indicate when a logical validation is not fulfilled,
        it is not a program error but if a prerequisite for any specific
        action/validation.
        """
        return self.__FAIL

    @property
    def ERROR(self):
        """
        It indicates that there were internal coding errors,
        normally captured by means of an exception.
        """
        return self.__ERROR

    @property
    def NODATA(self):
        """
        It allows to indicate when an operation is carried out and does not bring records,
        it is not an error of the program, but if a prerequisite for any process that 
        requires information to perform some action.
        """
        return self.__NODATA
    
    @property
    def INFOPROJECTS(self):
        """
        
        """
        return self.__INFOPROJECTS
 
    @property
    def INFOID(self):
        """
        
        """
        return self.__INFOID