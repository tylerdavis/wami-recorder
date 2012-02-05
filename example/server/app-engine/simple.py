import logging

from google.appengine.ext import webapp
from google.appengine.ext.webapp import util

# The audio is captured and stored in a static global variable.
# Session management could be implemented through URL parameters.
class WamiHandler(webapp.RequestHandler):
    type = ""
    data = []

    def get(self):
        self.response.headers['Content-Type'] = WamiHandler.type
        self.response.out.write(WamiHandler.data);
        logging.info("server-to-client: " + str(len(WamiHandler.data)) +
                     " bytes of type " + WamiHandler.type);

    def post(self):
        WamiHandler.type = self.request.headers['Content-Type']
        WamiHandler.data = self.request.body
        logging.info("client-to-server: " + str(len(WamiHandler.data)) +
                     " bytes of type " + WamiHandler.type);

def main():
    application = webapp.WSGIApplication([('/', WamiHandler)],
                                         debug=True)
    util.run_wsgi_app(application)

if __name__ == '__main__':
    main()
