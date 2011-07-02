# coding=utf-8

import urllib
#import urllib2
import re
import logging
from google.appengine.api import urlfetch
from BeautifulSoup import BeautifulSoup    
import restapp

def read_stations():
    base_url = 'http://www.tel-o-fun.co.il'
    url = '%s/%s' % (base_url, urllib.quote('תחנותתלאופן.aspx'))
    logging.info('reading: %s' % url)
    htmldoc = urlfetch.fetch(url)
    
    if htmldoc.status_code != 200:
        msg = 'Error downloading stations. %d: %s' % (htmldoc.status_code, htmldoc.content)
        logging.error(msg)
        raise restapp.errors.RequestError(msg) 

    soup = BeautifulSoup(htmldoc.content)
    result = soup.findAll('a', { 'class': 'bicycle_station' })

    for a in result:
        yield { 'longitude': str(a['x']), 'latitude': str(a['y']), 'name': unicode(a.contents[0]), 'sid': str(a['sid']) }

def read_station(sid):
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
    print '%s: bike: %s, park: %s' % (sid, avail_bike, avail_park)
    
    # grab the english name from the english endpoint
    en_url = 'http://www.tel-o-fun.co.il/DesktopModules/Locations/StationData.ashx?en=1&sid=%s' % sid
    en_htmldoc = urlfetch.fetch(en_url)
    name_en = None
    if en_htmldoc.status_code == 200:
        en_soup = BeautifulSoup(en_htmldoc.content)
        divs = en_soup.findAll('div')
        name_en = divs[2].text
        
    return { 'available_bike': int(avail_bike),
             'available_spaces': int(avail_park),
             'name_en': name_en } 
