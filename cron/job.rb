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
    # Instance variables
    @token = ENV['CADAM_BOT_TOKEN']
    @search_count = 5
    @origin_path = 'http://localhost:3000'
  end

  def update
    puts 'start: update'
    carousell_uri = URI("https://carousell.com/ui/iso/api;path=%2Fproducts%2Fsearch%2F;query=%7B%22count%22%3A#{@search_count}%2C%22start%22%3A0%2C%22sort%22%3A%22recent%22%2C%22query%22%3A%22gundam%22%7D")

    response = HTTParty.get(carousell_uri)
    response = JSON.parse(response.body)
    results = response['result']['products']

    post_data = { gundams: [] }

    results.each do |p|
      gundam_data = {
        carousell_id: p['id'],
        title: p['title'],
        price: p['price'],
        description: p['description'],
        time_created: p['time_created'],
        location_address: p['location_address'],
        location_name: p['location_name']
      }
      post_data[:gundams].push(gundam_data)
    end

    rails_endpoint_uri = URI("#{@origin_path}/gundams")

    response = HTTParty.post(rails_endpoint_uri, { body: post_data })
    response = JSON.parse(response.body) if response.code == 200

    puts 'end: update'
  end

  def notify
    puts 'start: notify'
    rails_endpoint_uri = URI("#{@origin_path}/watchlists/notify")

    response = HTTParty.get(rails_endpoint_uri)

    if response.code == 200
      response = JSON.parse(response.body)

      notified = response['notified']

      Telegram::Bot::Client.run(@token) do |bot|
        notified.each do |n|
          chat_id = n.keys.first
          gundams = n[chat_id]

          gundams.each do |g|
            gundam = "[Title]: #{g['title']}\n"
            gundam += "[Price]: $#{g['price']}\n"
            gundam += "[URL]: https://carousell.com/p/#{g['carousell_id']}"

            bot.api.send_message(chat_id: chat_id, text: gundam)
          end
        end
      end
    end

    puts 'end: notify'
  end
end

# gundam_job = GundamJob.new
# gundam_job.update
# gundam_job.notify
