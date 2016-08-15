require 'rest-client'
require 'json'
require 'map'

token = ENV['SLACK_API_TOKEN']
baseURL = 'https://slack.com/api/users.list'

response = JSON.parse((RestClient.get baseURL, {:params => {'token' => token}}), object_class: Map)

response['members'].each do |person|
	if person['name'] == 'hasithvm'
		puts person['id']
	end
end