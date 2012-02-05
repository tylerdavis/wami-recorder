import logging

from google.appengine.ext import webapp
from google.appengine.ext.webapp import util

# This is a very simple example of how to recieve and serve audio
# using the Google App Engine (GAE).  The audio is captured and stored
# in a static global variable.  Note that this means, you might not
# even hear your own voice if someone recorded you before you had a
# chance to play back.  This is just for illustrative purposes.
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
