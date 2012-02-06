from __future__ import with_statement

import cgi
import logging
from google.appengine.ext.webapp import util

from google.appengine.api import files
from google.appengine.ext import webapp
from google.appengine.ext import blobstore
from google.appengine.ext import db

class DataModel(db.Model):
  url = db.StringProperty(required=True)
  blob = blobstore.BlobReferenceProperty(required=True)

# All this does is list the URLs from which you can download the audio
# that has been uploaded to your blobstore.  If you serve this up, you
# should probably ensure that only admin's can login (a simple feat in
# app.yaml).
class ListHandler(webapp.RequestHandler):
    def get(self):
        query = db.GqlQuery("SELECT * "
                            "FROM DataModel ")
        for model in query:
            self.response.out.write('%s<br />' % model.url)

def main():
    application = webapp.WSGIApplication([('/list', ListHandler)],
                                         debug=True)
    util.run_wsgi_app(application)
    
if __name__ == '__main__':
    main()
