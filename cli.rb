#!/usr/bin/env ruby

require 'zlib'
require 'timeout'
require 'net/http'
require 'simple_oauth'
require 'json'

require_relative "lib/bird/tweet"

raise 'Consumer Key not set' unless ENV.has_key?('CONSUMER_KEY')
raise 'Consumer Secret not set' unless ENV.has_key?('CONSUMER_SECRET')
raise 'Access token not set' unless ENV.has_key?('ACCESS_TOKEN')
raise 'Access token secret not set' unless ENV.has_key?('ACCESS_TOKEN_SECRET')

stream_file = File.new('streamer.json', 'w')

begin
  Timeout.timeout(4) do
    uri = URI.parse('https://stream.twitter.com:443/1.1/statuses/sample.json')
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Accept'] = '*/*'
      request['Connection'] = 'Keep-Alive'
      request['User-Agent'] = 'Ruby Client'

      full_uri = 'https://stream.twitter.com/1.1/statuses/sample.json'
      oauth_params =
        {
                :consumer_key     => ENV['CONSUMER_KEY'],
                :consumer_secret  => ENV['CONSUMER_SECRET'],
                :token            => ENV['ACCESS_TOKEN'],
                :token_secret     => ENV['ACCESS_TOKEN_SECRET']
        }
      h = SimpleOAuth::Header.new('get', full_uri, {}, oauth_params)
        # p h.to_s

      request['Authorization'] = h.to_s

      http.request(request) do |response|
        response.read_body do |chunk|
          print '.'
          stream_file.write(chunk)
        end
      end
    end
  end
rescue Zlib::BufError => e
  puts "Got enough tweets"
ensure
  stream_file.close
end

print ''

File.open('streamer.json', 'r') do |f|    
  f.each_line do |line|
    begin
      h = JSON.parse(line)
      
      unless h.has_key?('delete')
        tweet = Bird::Tweet.construct_from(h)
        
        puts "*" * 80
        puts "User name : #{tweet.username}"
        puts "Datetime : #{tweet.datetime}"
        puts "Tweet : #{tweet.text}"
      end
    rescue NoMethodError => e
      next
    rescue JSON::ParserError => e
      next
    end        
  end 
end