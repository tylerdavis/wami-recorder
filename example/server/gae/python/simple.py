import logging

from google.appengine.ext import webapp
from google.appengine.ext.webapp import util

# This is just the simplest possible working example that will allow
# you to record to Google Apps Engine and play it back.  It does not
# have session tracking.  It just stores temporary data in a global
# variable.  You can use this to get you started with GAE without
# worrying about data storage.

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
