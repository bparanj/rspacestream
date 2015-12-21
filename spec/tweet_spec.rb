require 'spec_helper'

describe Bird::Tweet do
  it 'create a Tweet object from json' do
    h = JSON.parse(File.read("spec/fixtures/stream.json"))

    tweet = Bird::Tweet.construct_from(h)  
      
    expect(tweet.username).to eq('hannah_vk_11')
    expect(tweet.datetime).to eq("Mon Dec 21 01:05:22 +0000 2015")
    expect(tweet.text).to eq('RT @itsMarioSelman: If this gets 1,000 RTs will you quit @realDonaldTrump')
  end

end



