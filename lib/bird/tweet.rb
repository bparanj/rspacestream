require 'json'

module Bird
  class Tweet
    attr_reader :username, :datetime, :text
    
    def initialize(username, datetime, text)
      @username, @datetime, @text = username, datetime, text
    end
    
    def self.construct_from(hash)
      new(hash['user']['screen_name'], hash['created_at'] ,hash['text'])
    end
  end
  
  
end