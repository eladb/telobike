# coding=utf-8
"""Handles the /serviceinfo endpoint"""

from google.appengine.ext import db
from utils import model as modelutils
from datetime import timedelta
import restapp

class City(db.Model):
    """Information about the rental service
    Key name is the city.
    """
    last_update = db.DateTimeProperty(auto_now=True, required=True)
    service_name = db.StringProperty()
    service_name_en = db.StringProperty()
    city_name = db.StringProperty()
    city_name_en = db.StringProperty()
    mail = db.EmailProperty()
    mail_tags = db.StringProperty()
    city_center = db.GeoPtProperty()
    disclaimer = db.StringProperty()
    info_url_he = db.LinkProperty()
    info_url = db.LinkProperty()
    
    @classmethod
    def populate(cls):
        existing = City.get_by_key_name('tlv')
        if not existing:
            tlv = City.get_or_insert(key_name = 'tlv')
            tlv.service_name = 'Tel-o-Fun'
            tlv.service_name_en = 'Tel-o-Fun'
            tlv.city_name = 'Tel-Aviv'
            tlv.city_name_en = 'Tel-Aviv'
            tlv.mail = 'info@fsm-tlv.co.il'
            tlv.mail_tags = '#malfunction'
            tlv.info_url = 'http://telobike.citylifeapps.com/static/en/tlv.html'
            tlv.info_url_he = 'http://telobike.citylifeapps.com/static/he/tlv.html'
            tlv.put()
            
        if not existing.info_url_he:
            existing.info_url_he = 'http://telobike.citylifeapps.com/static/he/tlv.html'
            existing.put()
    
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
