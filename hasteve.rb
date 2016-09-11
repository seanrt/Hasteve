require 'rest-client'
require 'json'
require 'map'

TARGET_USERNAME = 'sean.tohidi'
# TARGET_USERNAME = 'hasithvm'
TARGET_CHANNEL = 'general'
MESSAGE_COUNT = 1000
SLACK_API_TOKEN = ENV['SLACK_API_TOKEN']
SLACK_BASE_URL = 'https://slack.com/api/'

def getUserID()
  puts('Getting user ID for user '+TARGET_USERNAME)
  baseURL = SLACK_BASE_URL+'users.list'
  response = JSON.parse((RestClient.get baseURL, {:params => {'token' => SLACK_API_TOKEN}}), object_class: Map)
  user = response['members'].find { |person| person['name'] == TARGET_USERNAME}
  File.write('data/userid', user['id'])
  return user['id']
end

def getChannelID()
  puts('Getting channel ID for channel '+TARGET_CHANNEL)
  baseURL = SLACK_BASE_URL+'channels.list'
  response = JSON.parse((RestClient.get baseURL, {:params => {'token' => SLACK_API_TOKEN}}), object_class: Map)
  channel = response['channels'].detect { |channel| channel['name'] == TARGET_CHANNEL }
  File.write('data/channelid', channel['id'])
  return channel['id']
end

def gatherMessages(user, channel)
  puts('Gathering messages for '+TARGET_USERNAME+' in channel '+TARGET_CHANNEL)
  baseURL = SLACK_BASE_URL+'channels.history'
  messageData = ''
  response = JSON.parse((RestClient.get baseURL, {:params => {'token' => SLACK_API_TOKEN, 'channel' => channel, 'count' => MESSAGE_COUNT}}), object_class: Map)
  messages = response['messages'].find_all { |message| message['user'] == user}
  messages.each { |message| messageData += message['text']+"\n"}
  File.write('data/messageData', messageData)
  return messageData
end

def main()
  user = getUserID()
  channel = getChannelID()
  messages = gatherMessages(user, channel)
  puts(messages)
end

main()
