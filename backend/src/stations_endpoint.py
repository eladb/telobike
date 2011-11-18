"""Handles the /stations endpoint"""

import logging
from utils import model as modelutils
import restapp
from datetime import timedelta

from model import Station

class StationsEndpoint(restapp.Endpoint):
    root_url = '/stations'
    
    def _to_dict(self, stored_station):
        d = modelutils.to_dict(stored_station, 'sid')
        d['latitude'] = stored_station.location.lat
        d['longitude'] = stored_station.location.lon
        if not d.has_key('available_spaces'): d['available_spaces'] = 0
        if not d.has_key('available_bike'): d['available_bike'] = 0
        return d
    
    def get(self, ctx):
        s = Station.get_by_key_name(ctx.resource_path)
        if not s: raise restapp.errors.NotFoundError('station %s not found' % ctx.resource_path)
        ctx.cache_expires_in(timedelta(minutes = 5))
        return self._to_dict(s)
    
    def query(self, ctx):
        city = ctx.request.get('city')
        if not city or city == '': city = 'tlv'
        all_stations = Station.all().filter('city =', city)
        ctx.cache_expires_in(timedelta(minutes = 5))
        return [ self._to_dict(s) for s in all_stations];

import tlv
import paris
from google.appengine.ext import deferred
import refresh
from model import StationHistory

from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.api import urlfetch

class RefreshStationsRequestHandler(webapp.RequestHandler):
    def get(self):
        city = self.request.get('city')
        if not city or city == '': city = 'tlv'
        deferred.defer(refresh.deferred_read_stations, city)
        self.response.out.write('<p>Started refresh for city %s</p>' % city)

class RefreshStationStatusRequestHandler(webapp.RequestHandler):
    def get(self):
        self.post()
        self.response.out.write("<p>Station %s in city '%s' refreshed</p>" % (self.request.get('sid'), self.request.get('city')))
        
    def post(self):
        city = self.request.get('city')
        sid = self.request.get('sid')
        
        if not city or city == '' or not sid or sid == '':
            self.error(404)
            return
            
        logging.info('refresh station status. city = %s, sid = %s' % (city, sid))
        result = None
        
        if city == 'tlv': result = tlv.read_station(sid)
        if city == 'paris': result = paris.read_station(sid)
        
        if not result:
            logging.error('Empty result from reading station')
            return
        
        logging.info('result = %s' % result)
        
        stored_station = Station.get_by_key_name(sid)
        if not stored_station:
            logging.error('unable to find station with sid %s' % sid)
            self.error(500)
            return
        
        stored_station.available_bike = result['available_bike']
        stored_station.available_spaces = result['available_spaces']
        stored_station.name_en = result['name_en']
        stored_station.put()
        
        # append a copy of the stored station to station history        
        ##StationHistory.append(stored_station)
        

def main():
    application = webapp.WSGIApplication([('/stations/refresh-station', RefreshStationStatusRequestHandler), 
                                          ('/stations/refresh', RefreshStationsRequestHandler), 
                                          ('.*', StationsEndpoint.request_handler_class())], debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
