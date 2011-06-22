import restapp
from model import StationHistory
from utils import model as modelutils

class HistoryEndpoint(restapp.Endpoint):
    root_url = '/history'
    
    def get(self, ctx):
        city = ctx.require('city')
        fetch = ctx.argument('fetch')

        sid = ctx.resource_path
        if not sid: raise restapp.errors.BadRequestError('station id expected in path')
        
        history = StationHistory.all().filter('city =', city).filter('sid =', sid).order('-last_update')
        if fetch: history = history.fetch(int(fetch))
        
        
        history_entries = [ modelutils.to_dict(h) for h in history ]
        
        name = 'unknown'
        if len(history_entries) > 0: name = history_entries[0]['name']
        
        return { 'sid': sid, 'city':city, 'name': name, 'history': history_entries }
    
    def query(self, ctx):
        city = ctx.require('city')
        all_stations = StationHistory.all().filter('city =', city)
        return [ modelutils.to_dict(s) for s in all_stations ]
    
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
          
def main():
    application = webapp.WSGIApplication([('.*', HistoryEndpoint.request_handler_class())], debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()

