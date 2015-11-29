require 'open-uri'
require 'net/http'

class AliceBot
  AURL = 'http://sheepridge.pandorabots.com/pandora/talk?botid=b69b8d517e345aba&skin=custom_input'
  AURI = URI(AURL)

  def initialize
    @botcust2 = open(AURL)
                .read
                .match(/name="botcust2" value="(\h+)"/)[1]
  end

  def talk(input)
    Net::HTTP.post_form(AURI, { 'botcust2' => @botcust2,
                                'input'    => input })
    .body[/<b>A\.L\.I\.C\.E\.:<\/b>\s*([^<]+)<br\/>/, 1]
  end
end

