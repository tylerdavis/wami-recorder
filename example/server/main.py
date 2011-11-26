from google.appengine.ext import webapp
from google.appengine.ext.webapp import util

# The audio is captured and stored in a static global variable.
# Session management could be implemented through URL parameters.
class WamiHandler(webapp.RequestHandler):
    audio = []

    def get(self):
        self.response.headers['Content-Type'] = 'audio/x-wav'
        self.response.out.write(WamiHandler.audio);

    def post(self):
        WamiHandler.audio = self.request.body

def main():
    application = webapp.WSGIApplication([('/', WamiHandler)],
                                         debug=True)
    util.run_wsgi_app(application)

if __name__ == '__main__':
    main()
