window.onload = function () {
  var recognition = new webkitSpeechRecognition();
  recognition.continuous = true;
  recognition.interimResults = false;
  recognition.lang = 'bg-BG';
  var res = document.getElementById('res');
  var ans = document.getElementById('ans');
  var audio = document.getElementById('audio');
  recognition.onresult = function(event) {
    res.textContent =
      event.results[event.results.length-1][0].transcript;
    var xhr = new XMLHttpRequest();
    xhr.onload = function (e) {
      ans.textContent = e.target.responseText;
      audio.src = 'espeak.ogg';
      audio.load();
      audio.play();
    };
    xhr.open('GET',
      'http://localhost:8000/hal?q='
      + encodeURIComponent(res.textContent));
    xhr.send();
  };
  recognition.start();
};

