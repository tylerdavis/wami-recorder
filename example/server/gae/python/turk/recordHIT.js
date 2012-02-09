var Wami = Wami || {};

Wami.RecordHIT = new function() {
	var _maindiv;
	var _baseurl;
	var _prompts;
	var _session_id;

	var _prompt_index = 0;
	var _prompts_recorded = 0;
	var _heard_last = false;

	var _script = latestScript();
	var path = _script.src.replace(/\/[^\/]*\.js$/, '/');

	var css = ""
			+ "div {"
			+ "	font-family: Arial, Helvetica, sans-serif;"
			+ "}"
			+ ""
			+ "#PhraseDiv {"
			+ "	width: 600px; "
			+ "	background-color: rgb(208, 208, 208);"
			+ "}"
			+ ""
			+ "#PrevTaskButton {"
			+ "	margin-right: 20px;"
			+ "}"
			+ ""
			+ "#NextTaskButton {"
			+ "	margin-left: 20px;"
			+ "}"
			+ ""
			+ "#InstructionsDiv {"
			+ "	display: none; "
			+ "	margin-bottom: 10px;"
			+ "}"
			+ ""
			+ "#InstructionsDiv.one {"
			+ "	color: green; "
			+ "}"
			+ ""
			+ "#InstructionsDiv.two {"
			+ "	color: blue; "
			+ "}"
			+ ""
			+ "#TaskDiv {	"
			+ "	font-size: 22px;"
			+ "}"
			+ ""
			+ "#ReadingDiv {"
			+ "	margin-bottom: 25px;"
			+ "	font-size: 18px;"
			+ "}"
			+ ""
			+ "#recordDiv {"
			+ "	float: left; "
			+ "	margin-left: 40px; "
			+ "	margin-top: 50px"
			+ "}"
			+ ""
			+ "#playDiv {"
			+ "	float: right; "
			+ "	margin-right: 40px; "
			+ "	margin-top: 50px;"
			+ "}"
			+ ""
			+ "#wrapper {"
			+ "	height: 137px; "
			+ "	width: 214px;"
			+ "}"
			+ ""
			+ ".button {"
			+ "	display: inline-block;"
			+ "	outline: none;"
			+ "	cursor: pointer;"
			+ "	text-align: center;"
			+ "	text-decoration: none;"
			+ "	font: 16px/100% Arial, Helvetica, sans-serif;"
			+ "	padding: .5em 2em .55em;"
			+ "}"
			+ ""
			+ ".button.enabled:active {"
			+ " position: relative;"
			+ " top: 1px;"
			+ "}"
			+ ""
			+ ".gray {"
			+ "	color: #e9e9e9;"
			+ "	border: solid 1px #555;"
			+ "	background: #6e6e6e;"
			+ "	background: -webkit-gradient(linear, left top, left bottom, from(#888), to(#575757));"
			+ "	background: -moz-linear-gradient(top, #888, #575757);"
			+ "	filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#888888', endColorstr='#575757');"
			+ "}"
			+ ""
			+ ".blue {"
			+ "	color: #d9eef7;"
			+ "	border: solid 1px #000654;"
			+ "	background: #2B3768;"
			+ "	background: -webkit-gradient(linear, left top, left bottom, from(#2B3768), to(#027CFF));"
			+ "	background: -moz-linear-gradient(top, #2B3768, #027CFF);"
			+ "	filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#2B3768', endColorstr='#027CFF');"
			+ "}"
			+ ""
			+ ".blue:hover {"
			+ "	background: #2B3768;"
			+ "	background: -webkit-gradient(linear, left top, left bottom, from(#027CFF), to(#2B3768));"
			+ "	background: -moz-linear-gradient(top, #027CFF, #2B3768);"
			+ "	filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#027CFF', endColorstr='#2B3768');"
			+ "}" + "";

	this.create = function(prompts, baseurl) {
		_maindiv = document.createElement("center");
		_script.parentNode.insertBefore(_maindiv, _script);
		_session_id = createSessionID();
		if (!baseurl) {
			baseurl = "";
		} else if (baseurl.indexOf("/", baseurl.length - 1) == 1) {
			baseurl += "/";
		}

		_prompts = prompts;
		_baseurl = baseurl;

		injectCSS(css);
		var swfobjecturl = "http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js";
		getScript(swfobjecturl, function() {
			getScript(baseurl + "recorder.js", function() {
				getScript(baseurl + "gui.js", function() {
					embedWami();
					setupPrompts();
				});
			});
		});
		return _session_id;
	}

	function injectCSS(css) {
		var style = document.createElement('style');
		var rules = document.createTextNode(css);

		style.type = 'text/css';
		if (style.styleSheet)
			style.styleSheet.cssText = rules.nodeValue;
		else
			style.appendChild(rules);

		document.body.appendChild(style);
	}

	function createSessionID() {
		return ("" + 1e10).replace(/[018]/g, function(a) {
			return (a ^ Math.random() * 16 >> a / 4).toString(16)
		});
	}

	function getScript(url, cb) {
		var newScript = document.createElement('script');
		newScript.type = 'text/javascript';
		newScript.src = url;
		newScript.onload = cb;
		document.body.appendChild(newScript);
	}

	function gup(name) {
		var regexS = "[\\?&]" + name + "=([^&#]*)";
		var regex = new RegExp(regexS);
		var tmpURL = window.location.href;
		var results = regex.exec(tmpURL);
		if (results == null) {
			return null;
		} else {
			return results[1];
		}
	}

	function createDiv(id, style) {
		var div = document.createElement("div");
		div.setAttribute('id', id);
		return div;
	}

	function latestScript() {
		var scripts = document.getElementsByTagName('script');
		return scripts[scripts.length - 1];
	}

	function embedWami() {
		var wrapperDiv = createDiv("wrapper");
		var recordDiv = createDiv("recordDiv");
		var playDiv = createDiv("playDiv");
		var wamiDiv = createDiv("wami");

		wrapperDiv.appendChild(recordDiv);
		wrapperDiv.appendChild(playDiv);
		wrapperDiv.appendChild(wamiDiv);
		_maindiv.appendChild(wrapperDiv);

		Wami.setup(Wami.RecordHIT.checkSecurity, "wami", _baseurl + "Wami.swf");
	}

	var recordButton, playButton;
	var recordInterval, playInterval;

	function setupButtons() {
		recordButton = new Wami.Button("recordDiv", Wami.Button.RECORD,
				_baseurl + "buttons.png");
		recordButton.onstart = startRecording;
		recordButton.onstop = stopRecording;
		recordButton.setEnabled(true);

		playButton = new Wami.Button("playDiv", Wami.Button.PLAY, _baseurl
				+ "buttons.png");
		playButton.onstart = startPlaying;
		playButton.onstop = stopPlaying;
		playButton.setEnabled(false);
	}

	this.checkSecurity = function() {
		var settings = Wami.getSettings();
		if (settings.microphone.granted) {
			Wami.startListening();
			window.onfocus = function() {
				Wami.startListening();
			};
			window.onblur = function() {
				Wami.stopListening();
			};
			Wami.hide();
			setupButtons();
		} else {
			Wami.showSecurity("privacy", "Wami.show",
					"Wami.RecordHIT.checkSecurity", "Wami.RecordHIT.zoomError");
		}
	}

	this.zoomError = function() {
		alert("Your browser may be zoomed too far out to show the Flash security settings panel.  Zoom in, and refresh.");
	}

	function getServerURL() {
		return "https://wami-recorder.appspot.com/?name=" + _session_id + "-"
				+ _prompt_index;
	}

	function startRecording() {
		recordButton.setActivity(0);
		playButton.setEnabled(false);
		Wami.startRecording(getServerURL(), "Wami.RecordHIT.onRecordStart",
				"Wami.RecordHIT.onRecordFinish", "Wami.RecordHIT.onError");
	}

	function stopRecording() {
		Wami.stopRecording();
		clearInterval(recordInterval);
		recordButton.setEnabled(true);
	}

	function startPlaying() {
		playButton.setActivity(0);
		recordButton.setEnabled(false);
		Wami.startPlaying(getServerURL(), "Wami.RecordHIT.onPlayStart",
				"Wami.RecordHIT.onPlayFinish", "Wami.RecordHIT.onError");
	}

	function stopPlaying() {
		Wami.stopPlaying();
	}

	this.onError = function(e) {
		alert(e);
	}

	this.onRecordStart = function() {
		recordInterval = setInterval(function() {
			if (recordButton.isActive()) {
				var level = Wami.getRecordingLevel();
				recordButton.setActivity(level);
			}
		}, 200);
	}

	this.onRecordFinish = function() {
		if (_prompt_index == _prompts_recorded) {
			// If we're not re-recording
			_prompts_recorded++;
			_heard_last = false;
		}
		playButton.setEnabled(true);
		updateView();
	}

	this.onPlayStart = function() {
		playInterval = setInterval(function() {
			if (playButton.isActive()) {
				var level = Wami.getPlayingLevel();
				playButton.setActivity(level);
			}
		}, 200);

		if (_prompt_index == _prompts_recorded - 1) {
			_heard_last = true;
		}

		// Delay a bit before updating the view.
		setTimeout(function() {
			updateView();
		}, 1000);
	}

	this.onPlayFinish = function() {
		clearInterval(playInterval);
		recordButton.setEnabled(true);
		playButton.setEnabled(true);
	}

	function createButton(id, value, callback) {
		var button = document.createElement('div');
		button.setAttribute('id', id);
		button.className = "button orange";
		button.innerHTML = value;
		button.onclick = function() {
			callback(button.className.indexOf("enabled") != -1);
		}
		return button;
	}

	function setupPrompts() {
		// Set the element that will get
		var hidden = document.createElement("input");
		hidden.type = "hidden";
		hidden.id = hidden.name = "session_id";
		hidden.value = _session_id;
		_maindiv.appendChild(hidden);

		var hitdiv = createDiv("hitwrapper");
		_maindiv.appendChild(hitdiv);

		hitdiv.appendChild(createDiv("TaskDiv"));
		hitdiv.appendChild(createDiv("InstructionsDiv"));
		var readingDiv = createDiv("ReadingDiv");
		var phraseDiv = createDiv("PhraseDiv");
		readingDiv.appendChild(phraseDiv);
		hitdiv.appendChild(readingDiv);
		phraseDiv.innerHTML = "<br /><span id='PhraseSpan' style='text-align: center'></span><br /><br />";

		var buttonDiv = createDiv("ButtonsDiv");
		buttonDiv.appendChild(createButton("PrevTaskButton", "Previous",
				function(enabled) {
					if (enabled)
						_prompt_index--;
					updateView();
				}));

		buttonDiv.appendChild(createButton("NextTaskButton", "Next    ",
				function(enabled) {
					if (enabled)
						_prompt_index++;
					updateView();
				}));

		hitdiv.appendChild(buttonDiv);

		updateView();
	}

	function showelement(id) {
		// safe function to show an element with a specified id

		if (document.getElementById) { // DOM3 = IE5, NS6
			var e = document.getElementById(id);
			if (e) {
				e.style.display = 'block';
			}
		} else {
			if (document.layers) { // Netscape 4
				if (document.id) {
					document.id.display = 'block';
				}
			} else { // IE 4
				if (document.all.id) {
					document.all.id.style.display = 'block';
				}
			}
		}
	}

	function hideelement(id) {
		// safe function to hide an element with a specified id
		if (document.getElementById) { // DOM3 = IE5, NS6
			var e = document.getElementById(id);
			if (e) {
				e.style.display = 'none';
			}
		} else {
			if (document.layers) { // Netscape 4
				if (document.id) {
					document.id.display = 'none';
				}
			} else { // IE 4
				if (document.all.id) {
					document.all.id.style.display = 'none';
				}
			}
		}
	}

	function setInstructions(instructions) {
		showelement("InstructionsDiv");
		var instructionsDiv = document.getElementById("InstructionsDiv");
		instructionsDiv.className = (instructionsDiv.className == "one") ? "two"
				: "one";
		instructionsDiv.innerHTML = instructions;
	}

	function updateView() {
		if (_prompt_index == _prompts.length) {
			setInstructions("You have finished all the tasks in this HIT, you can now click 'submit'.");
			hideelement("ReadingDiv");
			hideelement("TaskDiv");
			hideelement("ButtonsDiv");
			return;
		}

		var phraseSpan = document.getElementById("PhraseSpan");
		phraseSpan.innerHTML = _prompts[_prompt_index];

		var taskDiv = document.getElementById("TaskDiv");
		var promptNumber = _prompt_index + 1;
		taskDiv.innerHTML = "<H3>Task " + promptNumber + " of "
				+ _prompts.length + "</H3>";

		var enableReplay = (_prompt_index >= 0 && _prompt_index < _prompts_recorded);
		var enablePrevious = _prompt_index > 0;
		var enableNext = (_prompt_index < _prompts_recorded - 1)
				|| (_prompt_index == _prompts_recorded - 1 && _heard_last && _prompt_index < _prompts.length);

		var prevButton = document.getElementById("PrevTaskButton");
		var nextButton = document.getElementById("NextTaskButton");

		prevButton.disabled = !enablePrevious;
		prevButton.className = "button "
				+ (enablePrevious ? 'blue enabled' : 'gray disabled');

		nextButton.disabled = !enableNext;
		nextButton.className = "button "
				+ (enableNext ? 'blue enabled' : 'gray disabled');

		if (playButton) {
			playButton.setEnabled(enableReplay);
		}

		showelement("ReadingDiv");
		showelement("TaskDiv");
		showelement("ButtonsDiv");

		if (enableNext) {
			if (_prompt_index == _prompts.length - 1) {
				nextButton.value = "Finish";
				setInstructions("If you are satisfied with the audio, submit the HIT, otherwise re-record the audio");
			} else {
				nextButton.value = "Next";
				setInstructions("If you are satisfied with the audio, click 'Next Task', otherwise re-record the audio.");
			}
		} else {
			if (_prompt_index < _prompts_recorded) {
				setInstructions("Replay the audio and make sure that the sound quality is good and that your words are not cut-off.");
			} else {
				setInstructions("Please click the record button above, speak the words below, and then click again to stop.");
			}
		}
	}
}
