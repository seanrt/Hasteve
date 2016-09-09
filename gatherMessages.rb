require 'rest-client'
require 'json'
require 'map'

MESSAGECOUNT = 1000

token = ENV['SLACK_API_TOKEN']
channelID = File.read('data/channelid')
userID = File.read('data/userid')
baseURL = 'https://slack.com/api/channels.history'

messageData = ''
response = JSON.parse((RestClient.get baseURL, {:params => {'token' => token, 'channel' => channelID, 'count' => MESSAGECOUNT}}), object_class: Map)
messages = response['messages'].find_all { |message| message['user'] == userID}
messages.each { |message| messageData += message['text']+"\n"}
File.write('data/messageData', messageData)
