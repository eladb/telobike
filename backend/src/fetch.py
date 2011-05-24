import logging
from google.appengine.api import urlfetch
import restapp

def get(url):
    logging.info('GET %s' % url)
    doc = urlfetch.fetch(url)
    if doc.status_code != 200:
        msg = 'HTTP GET returned %d: %s' % (doc.status_code, doc.content)
        logging.error(msg)
        raise restapp.errors.RequestError(msg)
    return doc.content 
    