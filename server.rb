require 'webrick'
require 'open-uri'
require 'json'
require 'uri'
require './alicebot.rb'

def translate(from, to, text)
  text = URI.escape(text)
  url = "https://translate.google.com/m?hl=bg&sl=#{from}&tl=#{to}&ie=UTF-8&prev=_m&q=#{text}"
  ua = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/45.0.2454.101 Chrome/45.0.2454.101 Safari/537.36'
  open(url, {'user-agent' => ua}).read.match(/<div dir="ltr" class="t0">([^<]+)<\/div>/)[1]
end

def wolfram_alpha(query)
  q = URI.escape(query)
  url = "http://m.wolframalpha.com/input/?i=#{q}&x=0&y=0"
  open(url).read.match(/^\s*Result.*$/).to_s[/alt="([^"]+)"/, 1]
end

def duckduckgo(query)
  q = URI.escape(query)
  url = "http://api.duckduckgo.com/?q=#{q}&format=json"
  JSON.parse(open(url).read)['Answer'][/>([^>]+)<\/a>$/, 1]
end

def speak(msg)
  url = open("http://www.speakvolumes.eu/testsynth.php?content=#{URI.escape(msg)}&voice=irina&demo=1").read.strip
  `curl -s '#{url}' -o espeak.ogg`
end

root = File.expand_path '.'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root

ab = AliceBot.new

server.mount_proc '/hal' do |req, res|
  q = req.query['q']
  q = translate(:bg, :en, q)
  ans = wolfram_alpha(q) || duckduckgo(q) || ab.talk(q) || "no data"
  ans = translate(:en, :bg, ans)
  res.body = ans
  speak(ans)
end

server.mount_proc '/espeak.ogg' do |req, res|
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = File.read 'espeak.ogg'
end

trap 'INT' do server.shutdown end

server.start

