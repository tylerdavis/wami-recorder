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
        allowScriptAccess: "always"
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