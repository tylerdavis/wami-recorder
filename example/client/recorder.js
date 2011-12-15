var Wami = window.Wami || {};

Wami.setup = function(id, callback) {
    if (Wami.startRecording) {
	// Wami's already defined
	callback();
	return;
    }

    /**
     * Set up the Flash for WAMI
     */
    function supportsTransparency() {
	// Detecting the OS is a big no-no in Javascript programming, but
	// I can't think of a better way to know if wmode is supported or
	// not... since not supporting it (like Flash on Ubuntu) is a bug.
	return (navigator.platform.indexOf("Linux") == -1);
    }
    
    /**
     * Attach all the audio methods to the Wami namespace in the callback.
     */
    Wami._callbacks = Wami._callbacks || {};
    Wami._callbacks["swfinit"] = function() {
	// Delegate all the methods to the recorder.
	var recorder = document.getElementById(id);

	function delegate(name) {
	    Wami[name] = function() {
		return recorder[name].apply(recorder, arguments);
	    }
	}

	delegate('startPlaying');
	delegate('stopPlaying');
	delegate('startRecording');
	delegate('stopRecording');
	delegate('startListening');
	delegate('stopListening');
	delegate('getRecordingActivity');
	delegate('getPlayingActivity');
	delegate('getSettings');
	delegate('showSettings');

	Wami.show = function() {
	    if (!supportsTransparency()) {
		recorder.style.visibility = "visible";
	    }
	}

	Wami.hide = function() {
	    // Hiding flash correctly in all the browsers is tricky. Please read:
	    // https://code.google.com/p/wami-recorder/wiki/HidingFlash
	    
	    if (!supportsTransparency()) {
		recorder.style.visibility = "hidden";
	    }
	}

	callback();
    }

    var flashVars = {
	visible : false,
	loadedCallback : "Wami._callbacks['swfinit']"
    }

    var params = {
	allowScriptAccess : "always"
    }
    
    if (supportsTransparency()) {
	params.wmode = "transparent";
    }
    
    if (console) {
	flashVars.console = true;
    }
    
    var version = '10.0.0';
    document.getElementById(id).innerHTML = "WAMI requires Flash "
    + version + " or greater<br />https://get.adobe.com/flashplayer/";
    
    // This is the minimum size due to the microphone security panel
    swfobject.embedSWF("Wami.swf", id, 214, 137, version, null, flashVars,
		       params);
    
    // Without this line, Firefox has a dotted outline of the flash
    swfobject.createCSS("#" + id, "outline:none");
}
