require 'rest-client'
require 'json'
require 'map'

channelChoice = 'general'
token = ENV['SLACK_API_TOKEN']
baseURL = 'https://slack.com/api/channels.list'

response = JSON.parse((RestClient.get baseURL, {:params => {'token' => token}}), object_class: Map)
channel = response['channels'].detect { |channel| channel['name'] == channelChoice }
File.write('data/channelid', channel['id'])
