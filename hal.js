window.onload = function () {
  var recognition = new webkitSpeechRecognition();
  recognition.continuous = false;
  recognition.interimResults = false;
  recognition.lang = '<%= "#{lang.downcase}-#{lang.upcase}" %>';

  var res = document.getElementById('res');
  var ans = document.getElementById('ans');
  var img = document.getElementById('img');
  var sep = document.getElementById('sep');
  var audio = document.getElementById('audio');
  var typewriter = (node, text) => {
    node.textContent = '';
    var i = 0;
    var interval = setInterval(
      () => {
        if (node.textContent === text)
          clearInterval(interval);
        else
          node.textContent += text[i++];
      }, 16);
  };

  audio.onended = () => recognition.start();
  img.onclick   = () => recognition.start();

  recognition.onstart = () => img.className = 'active';
  recognition.onend   = () => img.className = '';

  recognition.onresult = function(event) {
    typewriter(res, event.results[event.results.length-1][0].transcript);
    var xhr = new XMLHttpRequest();
    xhr.onload = function (e) {
      json = JSON.parse(e.target.responseText);
      typewriter(ans, json.answer);
      sep.style.visibility = 'visible';
      sep.style.width = '100%';
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

