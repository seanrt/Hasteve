require 'rest-client'
require 'json'
require 'map'


token = ENV['SLACK_API_TOKEN']
baseURL = 'https://slack.com/api/users.list'
username = File.read('data/username')[0..-2]

response = JSON.parse((RestClient.get baseURL, {:params => {'token' => token}}), object_class: Map)
user = response['members'].find { |person| person['name'] == username}
File.write('data/userid', user['id'])
