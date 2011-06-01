from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

class IndexRequestHandler(webapp.RequestHandler):
    def get(self):
        self.redirect('http://itunes.apple.com/us/app/tel-o-bike-tel-aviv-bicycle/id436915919?mt=8')

def main():
    application = webapp.WSGIApplication([('/', IndexRequestHandler)], debug=True)
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
