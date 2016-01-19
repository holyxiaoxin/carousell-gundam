####### API ##############
# comments_count
# currency_symbol
# description
# id
# like_status
# likes_count
# location
# location_address
# location_name
# marketplace
# price
# price_formatted
# primary_photo
# primary_photo_url
# seller
# status
# time_created
# title
# user_state
# utc_last_liked
###########################

require 'httparty'
require 'json'
require 'telegram/bot'

class GundamJob
  def initialize
    @token = ENV['CADAM_BOT_TOKEN']
    @origin_path = ENV['CADAM_BOT_RAILS_URL']
    @search_count = 5
    @last_update = Time.now
  end

  def notify
    puts 'start: notify'
    gundams = []
    notified = []

    carousell_uri = URI("https://carousell.com/ui/iso/api;path=%2Fproducts%2Fsearch%2F;query=%7B%22count%22%3A#{@search_count}%2C%22start%22%3A0%2C%22sort%22%3A%22recent%22%2C%22query%22%3A%22gundam%22%7D")
    rails_endpoint_uri = URI("#{@origin_path}/watchlists/notify")

    response = HTTParty.get(carousell_uri)

    if response.code == 200
      response = JSON.parse(response.body)
      results = response['result']['products']

      gundams = results.map do |g|
        g if Time.parse(g['time_created']) > @last_update
      end
      gundams.compact!
    end

    response = HTTParty.get(rails_endpoint_uri)

    if response.code == 200
      response = JSON.parse(response.body)
      notified = response['notified']

      Telegram::Bot::Client.run(@token) do |bot|
        notified.each do |n|
          chat_id = n.keys.first
          gundams.each do |g|
            gundam = "[Title]: #{g['title']}\n"
            gundam += "[Price]: $#{g['price']}\n"
            gundam += "[URL]: https://carousell.com/p/#{g['id']}"

            puts chat_id
            puts gundams.inspect

            bot.api.send_message(chat_id: chat_id, text: gundam)
          end
        end
      end

      @last_update = Time.parse(gundams.first['time_created']) unless gundams.empty?
    end

    puts 'end: notify'
  end
end

# gundam_job = GundamJob.new
# gundam_job.notify
