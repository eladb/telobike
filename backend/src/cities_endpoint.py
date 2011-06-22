# coding=utf-8
"""Handles the /serviceinfo endpoint"""

from utils import model as modelutils
from datetime import timedelta
import restapp
from model import City
    
class CityEndpoint(restapp.Endpoint):
    root_url = '/cities'
    
    def _replace_en(self, dict, key):
        storage_key = key + '_en'
        json_key = key + '.en'
        if dict.has_key(storage_key):
            dict[json_key] = dict[storage_key]
            dict.pop(storage_key)
    
    def _to_dict(self, stored):
        d = modelutils.to_dict(stored, 'city')
        self._replace_en(d, 'service_name')
        self._replace_en(d, 'city_name')
        return d
    
    def get(self, ctx):
        city = ctx.resource_path
        s = City.get_by_key_name(ctx.resource_path)
        if not s: raise restapp.errors.NotFoundError('City %s not found' % city)
        ctx.cache_expires_in(timedelta(minutes = 5))
        return self._to_dict(s)

    def query(self, ctx):
        ctx.cache_expires_in(timedelta(minutes = 5))
        return [self._to_dict(city) for city in City.all()];

from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
          
def main():
    City.populate()
    application = webapp.WSGIApplication([('.*', CityEndpoint.request_handler_class())], debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
