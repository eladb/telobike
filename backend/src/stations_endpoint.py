"""Handles the /stations endpoint"""

import logging
from google.appengine.ext import db
from google.appengine.api import urlfetch
from utils import model as modelutils
from django.utils import simplejson as json
import restapp

import scrape

class Station(db.Model):
    """Represents a stations
    The key().name() is the station ID in the tel-o-fun system.
    """
    last_update = db.DateTimeProperty(auto_now=True, required=True)
    name = db.StringProperty()
    location = db.GeoPtProperty()
    available_bike = db.IntegerProperty()
    available_spaces = db.IntegerProperty()
    
class StationsEndpoint(restapp.Endpoint):
    def _to_dict(self, stored_station):
        d = modelutils.to_dict(stored_station, 'sid')
        d['latitude'] = stored_station.location.lat
        d['longitude'] = stored_station.location.lon
        d.pop('location')
        if not d.has_key('available_spaces'): d['available_spaces'] = 0
        if not d.has_key('available_bike'): d['available_bike'] = 0
        return d
    
    def alt_html(self, ctx, obj):
        super(StationsEndpoint, self).alt_html(ctx, {'stations':obj})
    
    def get(self, ctx):
        s = Station.get_by_key_name(ctx.resource_path)
        if not s:
            raise restapp.errors.NotFoundError('station %s not found' % ctx.resource_path)
        
        return self._to_dict(s)
    
    def query(self, ctx):
        all_stations = Station.all()
        return [ self._to_dict(s) for s in all_stations];

from restapp import apidocs

def get_apidocs():
    """Describes this API"""
    doc = apidocs.RequestDoc()
    doc.title = "Stations"
    doc.url = "/stations"
    doc.doc = "Stations information"
    
    u1 = apidocs.UsageDoc()
    u1.usage = '/stations/<i>station-id</i>'
    u1.args = [ apidocs.UsageArgument('alt=json', doc='output JSON format'),
                apidocs.UsageArgument('alt=html', doc='output HTML format') ]
    u1.doc = "Retrieves station information"
    u1.sample = '/station/312'
    
    u2 = apidocs.UsageDoc()
    u2.usage = '/stations'
    u2.args = [ apidocs.UsageArgument('alt=json', doc='output JSON format'),
                apidocs.UsageArgument('alt=html', doc='output HTML format') ]
    u2.doc = 'Retreives information about all stations'
    u2.sample = '/stations'
    
    doc.usage = u2 
    doc.usages = [u1, u2]
    return doc
            
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
class StationsRequestHandler(restapp.RequestHandler):
    def __init__(self):
        super(StationsRequestHandler, self).__init__('/stations', StationsEndpoint)

class RefreshStationsRequestHandler(webapp.RequestHandler):
    def get(self):
        stations = scrape.refresh()
        for station in stations:
            logging.info('storing station: %s' % station)
            stored_station = Station.get_or_insert(station['sid'])
            stored_station.name = station['name']
            stored_station.location = '%s,%s' % (station['latitude'], station['longitude'])
            stored_station.available_bike = int(station['available_bike'])
            stored_station.available_spaces = int(station['available_spaces'])
            stored_station.put()

def main():
    application = webapp.WSGIApplication([('/stations/refresh', RefreshStationsRequestHandler), ('.*', StationsRequestHandler)], debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
