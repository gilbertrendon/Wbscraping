import sys, os
stepDir = os.path.dirname(os.path.realpath(os.path.join(os.getcwd(), os.path.expanduser(__file__))))
dirRelativeParentsSpider = '../../../..'
dirRelativeParentsSpiderTest = '../../..'
sys.path.append(os.path.normpath(os.path.join(stepDir, dirRelativeParentsSpider)))
sys.path.append(os.path.normpath(os.path.join(stepDir, dirRelativeParentsSpiderTest)))
from generalLibraries.constants import Constants

def test_constants():
    constants = Constants()
    assert constants != None

def test_ok():
    constants = Constants()
    assert constants.OK==0
    
def test_fail():
    constants = Constants()
    assert constants.FAIL==1

def test_eror():
    constants = Constants()
    assert constants.ERROR==-1

def test_no_data():
    constants = Constants()
    constants = Constants()
    assert constants.NODATA==100

def test_info():
    constants = Constants()
    assert constants.INFOPROJECTS=="DATA"

def test_info_id():
    constants = Constants()
    assert constants.INFOID == "ID"
