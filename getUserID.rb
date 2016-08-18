require 'rest-client'
require 'json'
require 'map'


token = ENV['SLACK_API_TOKEN']
baseURL = 'https://slack.com/api/users.list'
username = File.read('data/username')[0..-2]
userID = ''

response = JSON.parse((RestClient.get baseURL, {:params => {'token' => token}}), object_class: Map)
response['members'].each do |person|
	if person['name'] == username
		userID = person['id']
	end
end

File.write('data/id', userID)
