# /setcommands
# recent - Retrieve 5 most recent listings. To retrieve more use: /recent 15.
# watch - Subscribe to all gundam listings.
# stop - Unsubscribe to all gundam listings.

require 'telegram/bot'
require 'httparty'
require 'json'
require 'time_ago_in_words'

token = ENV['CADAM_BOT_TOKEN']
RAILS_BASE_URL = ENV['CADAM_BOT_RAILS_URL']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    begin
      if message.text.start_with?('/')
        command = message.text
        case command
        when /^\/recent/
          command = command.split(' ')[1..-1].join(' ')
          search_count = command.length > 0 ? command : 5
          caoursell_uri = URI("https://carousell.com/ui/iso/api;path=%2Fproducts%2Fsearch%2F;query=%7B%22count%22%3A#{search_count}%2C%22start%22%3A0%2C%22sort%22%3A%22recent%22%2C%22query%22%3A%22gundam%22%7D")

          response = HTTParty.get(caoursell_uri)
          response = JSON.parse(response.body)
          results = response['result']['products']

          bot_reply = ""
          results = results.map.with_index do |r, index|
            bot_reply += "#{index+1}. \n[Title]: #{r['title']}\n"
            bot_reply += "[Price]: $#{r['price']}\n"
            bot_reply += "#{Time.parse(r['time_created']).ago_in_words}\n"
          end

          bot.api.send_message(chat_id: message.chat.id, text: bot_reply)

        when /^\/watch/
          rails_app_uri = URI("#{RAILS_BASE_URL}/watchlists")

          post_data = { chat_id: message.chat.id }

          response = HTTParty.post(rails_app_uri, { body: post_data })
          response = JSON.parse(response.body) if response.code == 200

          bot_reply = "You are now watching all gundam carousell listings.\n"
          bot_reply += 'Showing recent listings...'

          bot.api.send_message(chat_id: message.chat.id, text: bot_reply)

        when '/stop'
          rails_app_uri = URI("#{RAILS_BASE_URL}/watchlists/#{message.chat.id}")
          response = HTTParty.delete(rails_app_uri)
          response = JSON.parse(response.body) if response.code == 200

          bot_reply = 'You have stopped watching.'

          bot.api.send_message(chat_id: message.chat.id, text: bot_reply)
        end
      else
        # listening at messages
      end
    rescue
      puts 'something went wrong'
    end
  end
end
