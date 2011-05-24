# coding=utf-8
from BeautifulSoup import BeautifulSoup    
import logging
import fetch

def read_stations():
    url = 'http://en.velib.paris.fr/service/carto'
    soup = BeautifulSoup(fetch.get(url))
    result = soup.findAll('marker')
    for r in result:
        station = { 'longitude': r['lng'], 'latitude': r['lat'], 'name': r['name'], 'sid': r['number'], 'address': r['fulladdress'] }
        logging.info(station)
        yield station
        
def read_station(sid):
    url = 'http://en.velib.paris.fr/service/stationdetails/%s' % sid
    soup = BeautifulSoup(fetch.get(url))
    result = {}
    
    # if not found, return None
    if len(soup.find('available').contents) == 0: return None
    
    result['available_bike'] = int(soup.find('available').contents[0])
    result['available_spaces'] = int(soup.find('free').contents[0])
    logging.info('sid=%s, result=%s' % (sid, result))
    return result
