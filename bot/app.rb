# /setcommands
# recent - Retrieve 5 most recent listings. To retrieve more, use: /recent 15.
# watch - Subscribe to all gundam listings. To subscribe by tag, use: /watch art.
# watch_continued - To watch more than one tag, seperate by space, use: /watch exia burning.
# stop - Unsubscribe to all gundam listings.

require 'telegram/bot'
require 'httparty'
require 'json'
require 'time_ago_in_words'

token = ENV['CADAM_BOT_TOKEN']
RAILS_BASE_URL = ENV['CADAM_BOT_RAILS_URL']

class String
  def is_i?
    self.to_i.to_s == self
  end
end

Telegram::Bot::Client.run(token) do |bot|
  begin
    bot.listen do |message|
      if message.text.start_with?('/')
        command = message.text
        case command
        when /^\/recent/
          command = command.split(' ')[1..-1].join(' ')

          if(command.length == 0 || command.is_i? && command.to_i <= 20 && command.to_i > 0)
            search_count = command.length > 0 ? command : 5
            carousell_uri = URI("https://carousell.com/ui/iso/api;path=%2Fproducts%2Fsearch%2F;query=%7B%22count%22%3A#{search_count}%2C%22start%22%3A0%2C%22sort%22%3A%22recent%22%2C%22query%22%3A%22gundam%22%7D")

            response = HTTParty.get(carousell_uri)
            response = JSON.parse(response.body)
            results = response['result']['products']

            bot_reply = ""
            results.each_with_index do |r, index|
              bot_reply += "#{index+1}. \n[Title]: #{r['title']}\n"
              bot_reply += "[Price]: $#{r['price']}\n"
              bot_reply += "[URL]: https://carousell.com/p/#{r['id']}\n"
              bot_reply += "#{Time.parse(r['time_created']).ago_in_words}\n"
            end

            bot.api.send_message(chat_id: message.chat.id, text: bot_reply)
          else
            bot_reply = "Please enter a valid command.\n"
            bot_reply += "/recent <number>\n"
            bot_reply += "where <number> is 1 to 20."
            bot.api.send_message(chat_id: message.chat.id, text: bot_reply)
          end

        when /^\/watch/
          command = command.split(' ')[1..-1].join(' ')

          rails_app_uri = URI("#{RAILS_BASE_URL}/watchlists")
          post_data = { chat_id: message.chat.id, tags: [] }

          have_tags = command.length > 0
          if have_tags
            tags = command.split(' ')
            tags.each do |t|
              post_data[:tags].push(t)
            end
          end

          response = HTTParty.post(rails_app_uri, { body: post_data })
          response = JSON.parse(response.body) if response.code == 200

          if have_tags
            bot_reply = "You are now watching tags: [#{command}] carousell listings.\n"
          else
            bot_reply = "You are now watching all gundam carousell listings.\n"
          end
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
    end
  rescue => error
    puts 'something went wrong', error
    retry
  end
end
