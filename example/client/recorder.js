/**
 * A few globals, since this is just an example:
 */

var recorder;
var recordButton, playButton;
var recordInterval, playInterval;

/**
 * Load the Wami.swf Flash app.
 */

function setupRecorder() {
    var params = {
        allowScriptAccess: "always",
	wmode: "transparent"
    };
    
    var flashVars = {
	visible : false,
        loadedCallback : "loadedRecorder"
    }
    
    // This is the minimum size due to the microphone security panel
    swfobject.embedSWF("Wami.swf", "wamiDiv", 214, 137, 
		       '10.0.0', null, flashVars, params);
}

function loadedRecorder() {
    recorder = document.getElementById("wamiDiv");
    checkSecurity();
}

function checkSecurity() {
    var settings = recorder.getSettings();
    if (settings.microphone.granted) {
	hideFlash();
	setupButtons();
    } else {
	// Show any Flash settings panel you want using the string constants defined here:
	// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/SecurityPanel.html
	recorder.showSettings("privacy",
			      "showFlash", 
			      "checkSecurity", 
			      "zoomError");
    }
}

function hideFlash() {
    recorder.style.visibility = "hidden";
}

function showFlash() {
    recorder.style.visibility = "visible";
}

function zoomError() {
    // The minimum size for the flash content is 214x137.  Browser's zoomed out too far won't show the panel.
    alert("Your browser may be zoomed too far out to show the Flash security settings panel.  Zoom in, and refresh.");
}

function setupButtons() {
    recordButton = new Wami.Button("recordDiv", Wami.Button.RECORD);
    recordButton.onstart = startRecording;
    recordButton.onstop = stopRecording;
    recordButton.setEnabled(true);

    playButton = new Wami.Button("playDiv", Wami.Button.PLAY);
    playButton.onstart = startPlaying;
    playButton.onstop = stopPlaying;
    playButton.setEnabled(false);
}

/**
 * These methods are called on clicks from the GUI.
 */

function startRecording() {
    recordButton.setActivity(0);
    playButton.setEnabled(false);
    recorder.startRecording("http://wami-recorder.appspot.com/",
			    "onRecordStart", "onRecordFinish", "onError");
}

function stopRecording() {
    recorder.stopRecording();
}

function startPlaying() {
    playButton.setActivity(0);
    recordButton.setEnabled(false);
    recorder.startPlaying("http://wami-recorder.appspot.com/",
			  "onPlayStart", "onPlayFinish", "onError");
}

function stopPlaying() {
    recorder.stopPlaying();
}

/**
 * Callbacks from the flash indicating certain events
 */ 

function onError(e) {
    alert(e);
}

function onRecordStart() {
    recordInterval = setInterval(function() {
        var level = recorder.getRecordingActivity();
        recordButton.setActivity(level);
    }, 200);
}

function onRecordFinish() {
    clearInterval(recordInterval);
    recordButton.setEnabled(true);
    playButton.setEnabled(true);
}

function onPlayStart() {
    playInterval = setInterval(function() {
        var level = recorder.getPlayingActivity();
	console.log("Here: " + level);
        playButton.setActivity(level);
    }, 200);    
}

function onPlayFinish() {
    clearInterval(playInterval);
    recordButton.setEnabled(true);
    playButton.setEnabled(true);
}







/**
 * This is the GUI code.  You can keep it, or make your own.
 */

var Wami = window.Wami || {};
Wami.Button = function(guiID, type) {
    var self = this;

    // Get the background button image position
    // Index: 1) normal 2) pressed 3) mouse-over
    function background(index) {
	if (index == 1) return "-56px 0px";
	if (index == 2) return "0px 0px";
	if (index == 3) return "-112px 0";
	alert("Background not found: " + index);
    }

    // Get the type of meter and its state
    // Index: 1) enabled 2) meter 3) disabled
    function meter(index, offset) {
	var top = 5;
	if (offset) top += offset;
	if (self.type == Wami.Button.RECORD) {
	    if (index == 1) return "-169px " + top + "px";
	    if (index == 2) return "-189px " + top + "px";
	    if (index == 3) return "-249px " + top + "px";
	} else {
	    if (index == 1) return "-269px " + top + "px";
	    if (index == 2) return "-298px " + top + "px";
	    if (index == 3) return "-327px " + top + "px";
	}
	alert("Meter not found: " + self.type + " " + index);
    }

    function silhouetteWidth() {
	if (self.type == Wami.Button.RECORD) {
	    return "20px";
	} else {
	    return "29px";
	}
    }

    function mouseHandler(e) {
	var rightclick;
	if (!e) var e = window.event;
	if (e.which) rightclick = (e.which == 3);
	else if (e.button) rightclick = (e.button == 2);

	console.log("click");
	if (!rightclick) {
	    if (self.active && self.onstop) {
		self.active = false;
		self.onstop();
	    } else if (!self.active && self.onstart) {
		self.active = true;
		self.onstart();		
	    }
	}
    }

    function init(guiID, type) {
	self.type = type;
	if (!self.type) {
	    self.type = Wami.Button.record;
	}
	
	var div = document.createElement("div");
	div.style.position = 'relative';

	var elem = document.getElementById(guiID);
	if (elem) {
	    elem.appendChild(div);
	} else {
	    alert('Could not find element on page named ' + guiID);
	}
	
	self.guidiv = document.createElement("div");
	self.guidiv.style.width = '56px';
	self.guidiv.style.height = '63px';
	self.guidiv.style.cursor = 'pointer';
	self.guidiv.style.background = "url(buttons.png) no-repeat";
	self.guidiv.style.backgroundPosition = background(1);
	div.appendChild(self.guidiv);
	
	self.meterDiv = document.createElement("div");
	self.meterDiv.style.width = silhouetteWidth();
	self.meterDiv.style.height = '63px';
	self.meterDiv.style.margin = 'auto';
	self.meterDiv.style.cursor = 'pointer';
	self.meterDiv.style.background = "url(buttons.png) no-repeat";
	self.meterDiv.style.backgroundPosition = meter(2);
	self.guidiv.appendChild(self.meterDiv);
	
	self.coverDiv = document.createElement("div");
	self.coverDiv.style.width = silhouetteWidth();
	self.coverDiv.style.height = '63px';
	self.coverDiv.style.margin = 'auto';
	self.coverDiv.style.cursor = 'pointer';
	self.coverDiv.style.background = "url(buttons.png) no-repeat";
	self.coverDiv.style.backgroundPosition = meter(1);
	self.meterDiv.appendChild(self.coverDiv);
	
	self.active = false;
	self.guidiv.onmousedown = mouseHandler;
    }

    self.setActivity = function(level) {
	self.guidiv.onmouseout = function () {};
	self.guidiv.onmouseover = function () {};
	self.guidiv.style.backgroundPosition = background(2);
	self.coverDiv.style.backgroundPosition = meter(1, 5);
	self.meterDiv.style.backgroundPosition = meter(2, 5);
	
	var totalHeight = 31;
	var maxHeight = 9;

	// When volume goes up, the black image loses height, 
	// creating the perception of the colored one increasing.
	var height = (maxHeight + totalHeight - Math.floor(level / 100 * totalHeight));
	self.coverDiv.style.height = height + "px";
    }

    self.setEnabled = function(enable) {
	var guidiv = self.guidiv;
	self.active = false;
	if (enable) {
	    self.coverDiv.style.backgroundPosition = meter(1);
	    self.meterDiv.style.backgroundPosition = meter(1);
	    guidiv.style.backgroundPosition = background(1);
	    guidiv.onmousedown = mouseHandler;
	    guidiv.onmouseover = function () {
		guidiv.style.backgroundPosition = background(3);
	    };
	    guidiv.onmouseout = function () {
		guidiv.style.backgroundPosition = background(1);
	    };
	} else {
	    self.coverDiv.style.backgroundPosition = meter(3);
	    self.meterDiv.style.backgroundPosition = meter(3);
	    guidiv.style.backgroundPosition = background(1);
	    guidiv.onmousedown = null;
	    guidiv.onmouseout = function () {};
	    guidiv.onmouseover = function () {};
	}
    }

    init(guiID, type);
}

// The types of buttons we can show:
Wami.Button.RECORD = "record";
Wami.Button.PLAY = "play";
