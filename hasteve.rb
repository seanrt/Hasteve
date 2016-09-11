require 'rest-client'
require 'json'
require 'map'

TARGET_USERNAME = 'sean.tohidi'
# TARGET_USERNAME = 'hasithvm'
TARGET_CHANNEL = 'general'
MESSAGE_COUNT = 1000
SLACK_API_TOKEN = ENV['SLACK_API_TOKEN']
SLACK_BASE_URL = 'https://slack.com/api/'

class Word
  def initialize(word)
    @word = word
    @totalFollowingWordCount = 0
    @frequency = 1
    @followingWords = Hash.new
  end

  def addFollowingWord(word)
    if @followingWords.key?(word)
      @followingWords[word].incrementFrequency()
    else
      @followingWords[word] = Word.new(word)
    end
    @totalFollowingWordCount += 1
  end

  def incrementFrequency()
    @frequency += 1
  end

  def getFollowingWords()
    return @followingWords
  end

  def getFrequency()
    return @frequency
  end

  def getTotalFollowingWordCount()
    return @totalFollowingWordCount\
  end

  def outputWords()
    puts(@word)
    @followingWords.each do |key, word|
      puts('    Key: '+key)
      puts('    Count: '+word.getFrequency().to_s)
      puts('    Following word count: '+word.getTotalFollowingWordCount().to_s)
      word.getFollowingWords().each do |key2, word2|
        puts('        Key: '+key2)
        puts('        Count: '+word2.getFrequency().to_s)
      end
    end
  end
end

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
  messagesText = ''
  messagesData = []
  puts('Gathering messages for '+TARGET_USERNAME+' in channel '+TARGET_CHANNEL)
  baseURL = SLACK_BASE_URL+'channels.history'
  response = JSON.parse((RestClient.get baseURL, {:params => {'token' => SLACK_API_TOKEN, 'channel' => channel, 'count' => MESSAGE_COUNT}}), object_class: Map)
  messages = response['messages'].find_all { |message| message['user'] == user and not message['text'].include? 'https://'}
  messages.each do |message|
    messagesText += message['text']+"\n"
    messagesData.push(message['text'])
  end
  File.write('data/messageData', messagesText)
  return messagesData
end

def buildMarkovChains(messagesData)
 listOfStartingWords = Word.new('')
 listOfWords = Word.new('')
 messagesData.each do |message|
   words = message.split(' ')
   words.each_with_index do |word, index|
     if index == 0
       listOfStartingWords.addFollowingWord(word)
       listOfWords.addFollowingWord(word)
       if words.count > 1
         listOfWords.getFollowingWords()[word].addFollowingWord(words[index+1])
       else
         listOfWords.getFollowingWords()[word].addFollowingWord('END_OF_THE_STRING')         
       end
     elsif index < words.count - 1
       listOfWords.addFollowingWord(word)
       listOfWords.getFollowingWords()[word].addFollowingWord(words[index+1])
     else
       listOfWords.addFollowingWord(word)
       listOfWords.getFollowingWords()[word].addFollowingWord('END_OF_THE_STRING')
     end
   end
 end
 listOfStartingWords.outputWords()
 listOfWords.outputWords()
 return listOfStartingWords,listOfWords
end

def generateMessage(listOfStartingWords,listOfWords)
end

def main()
  user = getUserID()
  channel = getChannelID()
  messagesData = gatherMessages(user, channel)
  startingWords,words = buildMarkovChains(messagesData)
end

main()
