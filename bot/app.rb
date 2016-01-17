require 'telegram/bot'
require 'httparty'
require 'json'
require 'time_ago_in_words'

token = ENV['CADAM_BOT_TOKEN']

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

          formatted_result = ""
          results = results.map.with_index do |r, index|
            formatted_result += "#{index+1}. \n[Title]: #{r['title']}\n"
            formatted_result += "[Price]: $#{r['price']}\n"
            formatted_result += "#{Time.parse(r['time_created']).ago_in_words}\n"
          end

          bot.api.send_message(chat_id: message.chat.id, text: formatted_result)
        end
      else
        # listening at messages
      end
    rescue
      puts 'something went wrong'
    end
  end
end
