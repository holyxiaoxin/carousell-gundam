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

search_count = 30
CAROUSELL_URI = URI("https://carousell.com/ui/iso/api;path=%2Fproducts%2Fsearch%2F;query=%7B%22count%22%3A#{search_count}%2C%22start%22%3A0%2C%22sort%22%3A%22recent%22%2C%22query%22%3A%22gundam%22%7D")

response = HTTParty.get(CAROUSELL_URI)
response = JSON.parse(response.body)
results = response['result']['products']

post_data = {gundams: []}

results.each do |p|
  gundam_data = {
    title: p['title'],
    carousell_id: p['id'],
    description: p['description'],
    time_created: p['time_created'],
    location_address: p['location_address'],
    location_name: p['location_name']
  }
  post_data[:gundams].push(gundam_data)
end

rails_app_uri = URI('http://localhost:3000/gundams')

response = HTTParty.post(rails_app_uri, {body: post_data})
response = JSON.parse(response.body) if response.code == '200'

puts response.code
puts response if response.code == 200
