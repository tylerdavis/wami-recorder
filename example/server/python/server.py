# Run from the commandline:
#
# python server.py
# POST audio to   http://localhost:9000
# GET audio from  http://localhost:9000

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

class WamiHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        f = open("/tmp/test.wav")
        self.send_response(200)
        self.send_header('content-type','audio/x-wav')
        self.end_headers()
        self.wfile.write(f.read())
        f.close()

    def do_POST(self):
        f = open("/tmp/test.wav", "wb")
        length = int(self.headers.getheader('content-length'))
        print "POST of length " + str(length)
        f.write(self.rfile.read(length))
        f.close();

def main():
    try:
        server = HTTPServer(('', 9000), WamiHandler)
        print 'Started server...'
        server.serve_forever()
    except KeyboardInterrupt:
        print 'Stopping server'
        server.socket.close()

if __name__ == '__main__':
    main()
