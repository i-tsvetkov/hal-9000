require 'webrick'
require 'open-uri'
require 'json'

def tr(from, to, text)
  text = URI.escape(text)
  url = "https://translate.google.com/m?hl=bg&sl=#{from}&tl=#{to}&ie=UTF-8&prev=_m&q=#{text}"
  ua = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/45.0.2454.101 Chrome/45.0.2454.101 Safari/537.36'
  open(url, {'user-agent' => ua}).read.match(/<div dir="ltr" class="t0">([^<]+)<\/div>/)[1]
end

def wa(q)
  q = URI.escape(q)
  url = "http://m.wolframalpha.com/input/?i=#{q}&x=0&y=0"
  open(url).read.match(/^\s*Result.*$/).to_s[/alt="([^"]+)"/, 1]
end

def ddg(q)
  q = URI.escape(q)
  url = "http://api.duckduckgo.com/?q=#{q}&format=json"
  JSON.parse(open(url).read)['Answer'][/>([^>]+)<\/a>$/, 1]
end

def cb(q)
  `python cleverbot.py '#{q}'`
end

def speak(msg)
  `espeak -v bg -p 35 -s 140 '#{msg}'`
end

root = File.expand_path '.'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root

ab = AliceBot.new

server.mount_proc '/hal' do |req, res|
  q = req.query['q']
  q = tr(:bg, :en, q)
  ans = wa(q) || ddg(q) || ab.talk(q) || cb(q) || "no data"
  ans = tr(:en, :bg, ans)
  res.body = ans
  speak(ans)
end

trap 'INT' do server.shutdown end
server.start

