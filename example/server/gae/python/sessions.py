from __future__ import with_statement

import logging
import cgi
from google.appengine.ext.webapp import util

from google.appengine.api import files
from google.appengine.ext import webapp
from google.appengine.ext import blobstore
from google.appengine.ext import db

class DataModel(db.Model):
  blob = blobstore.BlobReferenceProperty(required=True)

# The audio is captured and stored in a database.
# Enable the Datastore Admin and configure the DB.
class WamiHandler(webapp.RequestHandler):
    def get(self):
        model = DataModel.get_by_key_name(self.get_name())
        blob_info = blobstore.BlobInfo.get(model.blob.key())
        blob_reader = blobstore.BlobReader(model.blob.key())
        data = blob_reader.read()
        self.response.headers['Content-Type'] = blob_info.content_type
        self.response.out.write(data);
        logging.info("server-to-client: " + str(len(data)) + 
                     " bytes at key " + str(model.blob.key()))

    def post(self):
        type = self.request.headers['Content-Type']
        blob_file_name = files.blobstore.create(mime_type=type)
        logging.info(blob_file_name)
        with files.open(blob_file_name, 'a') as f:
            f.write(self.request.body)
        f.close()
        files.finalize(blob_file_name)
        
        blob_key = files.blobstore.get_blob_key(blob_file_name)
        model = DataModel(key_name=self.get_name(), blob=blob_key)
        db.put(model)
        logging.info("client-to-server: type(" + type + 
                     ") key("  + str(blob_key) + ")")

    def get_name(self):
        name = "output.wav"
        logging.info(self.request.query_string)
        params = cgi.parse_qs(self.request.query_string)
        if params and params['name']:
            name = params['name'][0];
        return name

def main():
    application = webapp.WSGIApplication([('/', WamiHandler)],
                                         debug=True)
    util.run_wsgi_app(application)
    
if __name__ == '__main__':
    main()
