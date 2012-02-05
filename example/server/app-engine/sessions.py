from __future__ import with_statement

import logging
from google.appengine.ext.webapp import util

from google.appengine.api import files
from google.appengine.ext import webapp
from google.appengine.ext import blobstore

# The audio is captured and stored in a database.
# Enable the Datastore Admin and configure the DB.
class WamiHandler(webapp.RequestHandler):
    blob_key = ""

    def get(self):
        blob_reader = blobstore.BlobReader(WamiHandler.blob_key)
        data = blob_reader.read()
        logging.info("server-to-client: " + str(len(data)) + 
                     " bytes at key " + str(WamiHandler.blob_key))
        self.response.headers['Content-Type'] = blob_info.content_type
        self.response.out.write(data);

    def post(self):
        type = self.request.headers['Content-Type']
        file_name = files.blobstore.create(mime_type=type)
        logging.info(file_name)
        with files.open(file_name, 'a') as f:
            f.write(self.request.body)
        files.finalize(file_name)
        
        WamiHandler.blob_key = files.blobstore.get_blob_key(file_name)
        logging.info("client-to-server: type(" + type + 
                     ") key("  + str(WamiHandler.blob_key) + ")")


def main():
    application = webapp.WSGIApplication([('/', WamiHandler)],
                                         debug=True)
    util.run_wsgi_app(application)
    
if __name__ == '__main__':
    main()
