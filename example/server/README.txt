Each directory (or sub-directory of 'gae') contains an example server
in a particular language designed to handle audio incoming from the
Wami recorder.

The PHP example requires the configuration of a PHP-enabled
web-server, while the python server can be run on any machine with
python installed.

If you do not wish to host your own server, you can try out the Google
App Engine (GAE) examples.  The GAE python example stores data in a
"blobstore", for which Google provides a handy web-based management
console.

The Java example does the same, but provides some additional code for
resampling audio streams.  Since Flash can record in more sample rates
than it can play back, sometimes the audio must be sampled before
begin sent back to the client.
