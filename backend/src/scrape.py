# coding=utf-8

import urllib
#import urllib2
import re
import logging
from google.appengine.api import urlfetch
from BeautifulSoup import BeautifulSoup    

def read_stations():
    base_url = 'http://tel-o-fun.co.il'
    url = '%s/%s' % (base_url, urllib.quote('תחנותתלאופן.aspx'))
    logging.info('reading: %s' % url)
    htmldoc = urlfetch.fetch(url)
    soup = BeautifulSoup(htmldoc.content)
    result = soup.findAll('a', { 'class': 'bicycle_station' })
    
    stations = []
    
    for a in result:
        station = { 'longitude': str(a['x']), 'latitude': str(a['y']), 'name': unicode(a.contents[0]), 'available_bike': -1, 'available_spaces': -1, 'sid': str(a['sid']) }
        stations.append(station)    
    return stations

def fill_station_availability(station):
    sid = station['sid']
    url = 'http://www.tel-o-fun.co.il/DesktopModules/Locations/StationData.ashx?sid=%s' % sid
    logging.info('reading: %s' % url)
    htmldoc = urlfetch.fetch(url)
    soup = BeautifulSoup(htmldoc.content)
    
    div = soup.findAll('div', text = re.compile(u'אופניים זמינים'))
    if not div or len(div) < 1:
        logging.error('unable to find available bike in station data for sid %s' % sid)
    
    avail_bike = div[0].replace(u'אופניים זמינים', '').replace(':', '').replace(' ', '')
    
    div = soup.findAll('div', text = re.compile(u'עמודי עגינה פנויים'))
    if not div or len(div) < 1:
        logging.error('unable to find available parking spots in station data for sid %s' % sid)

    avail_park = div[0].replace(u'עמודי עגינה פנויים', '').replace(':', '').replace(' ', '')

    station['available_bike'] = avail_bike
    station['available_spaces'] = avail_park

    print '%s: bike: %s, park: %s' % (sid, avail_bike, avail_park)

def refresh():
    stations = read_stations()
    for s in stations:
        fill_station_availability(s)
    return stations
