window.onload = function () {
  var recognition = new webkitSpeechRecognition();
  recognition.continuous = false;
  recognition.interimResults = false;
  recognition.lang = 'bg-BG';

  var res = document.getElementById('res');
  var ans = document.getElementById('ans');
  var img = document.getElementById('img');
  var sep = document.getElementById('sep');
  var audio = document.getElementById('audio');

  audio.onended = () => recognition.start();
  img.onclick   = () => recognition.start();

  recognition.onstart = () => img.className = 'active';
  recognition.onend   = () => img.className = '';

  recognition.onresult = function(event) {
    res.textContent =
      event.results[event.results.length-1][0].transcript;
    var xhr = new XMLHttpRequest();
    xhr.onload = function (e) {
      json = JSON.parse(e.target.responseText);
      ans.textContent = json.answer;
      sep.style.visibility = 'visible';
      audio.src = json.audio;
      audio.load();
      audio.play();
    };
    xhr.open('GET',
      '/hal?q='
      + encodeURIComponent(res.textContent));
    xhr.send();
  };

  recognition.start();
};

