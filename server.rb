require 'webrick'
require 'open-uri'
require 'json'
require 'uri'
require 'erb'
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
  open("http://www.speakvolumes.eu/testsynth.php?content=#{URI.escape(msg)}&voice=irina&demo=1").read.strip
end

root = File.expand_path '.'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root

ab = AliceBot.new
lang = :bg
haljs = ERB.new File.read('hal.js')

if ARGV.size == 2 && ARGV[0] == '--lang' && ARGV[1].match(/^[a-z]{2}$/i)
  lang = ARGV[1]
end

server.mount_proc '/hal.js' do |req, res|
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = haljs.result binding
end

server.mount_proc '/hal' do |req, res|
  q = req.query['q']
  q = translate(lang, :en, q)
  ans = wolfram_alpha(q) || duckduckgo(q) || ab.talk(q) || "no data"
  ans = translate(:en, lang, ans)
  res['Pragma'] = res['Cache-Control'] = 'no-cache'
  res.body = { answer: ans, audio: speak(ans) }.to_json
end

trap 'INT' do server.shutdown end

server.start

