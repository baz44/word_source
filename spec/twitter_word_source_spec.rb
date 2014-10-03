require 'twitter_word_source'
require 'twitter'

describe TwitterWordSource do
  before(:each) do
    twitter_client = double("twitter")
    twitter_search_result = []
    ["ruby on rails", "ruby stuff", "ruby is awesome"].each do |text|
      tweet = double(text)
      allow(tweet).to receive(:text) {text}
      twitter_search_result << tweet
    end

    allow(Twitter::REST::Client).to receive(:new) { twitter_client }
    allow(twitter_client).to receive(:search).with("ruby", {:result_type=>"recent"}) {twitter_search_result}
  end

  describe "#next_word" do
    it "should return the next word in the string if one exists" do
      word_source = TwitterWordSource.new("ruby")
      expect(word_source.next_word).to eql("ruby")
      expect(word_source.next_word).to eql("on")
      expect(word_source.next_word).to eql("rails")
    end

    it "should accept accept a callback and calls it when encountered" do
      @callback_called = 0
      word_source = TwitterWordSource.new("ruby")
      word_source.on_next_encounter("ruby") do
        @callback_called += 1
      end

      expect(word_source.next_word).to eql("ruby")
      expect(@callback_called).to eql(1)
    end

    it "should accept accept multiple callbacks and calls them when encountered" do
      @callback_called = 0
      word_source = TwitterWordSource.new("ruby")
      word_source.on_next_encounter("ruby") do
        @callback_called += 1
      end

      word_source.on_next_encounter("ruby") do
        @callback_called += 1
      end

      expect(word_source.next_word).to eql("ruby")
      expect(@callback_called).to eql(2)
    end
  end

  describe "#top_5_words" do
    it "should return the top 5 words that have been seen" do
      word_source = TwitterWordSource.new("ruby")
      expect(word_source.top_5_words).to eql([nil, nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_words).to eql(["ruby", nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_words).to eql(["on", "ruby", nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_words).to eql(["on", "rails", "ruby", nil, nil])
    end
  end

  describe "#top_5_consonants" do
    it "should return the top 5 consonants that have been seen" do
      word_source = TwitterWordSource.new("ruby")
      expect(word_source.top_5_consonants).to eql([nil, nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_consonants).to eql(["b", "r", "y", nil, nil])
      word_source.next_word
      expect(word_source.top_5_consonants).to eql(["b", "n", "r", "y", nil])
      word_source.next_word
      expect(word_source.top_5_consonants).to eql(["r", "b", "l", "n", "s"])
    end
  end

  describe "#count" do
    it "should return number of words that have been seen" do
      word_source = TwitterWordSource.new("ruby")
      expect(word_source.count).to eql(0)
      word_source.next_word
      expect(word_source.count).to eql(1)
      word_source.next_word
      expect(word_source.count).to eql(2)
      word_source.next_word
      expect(word_source.count).to eql(3)
    end
  end

  describe "#run" do
    it "should keep running till no more words are avilable to read" do
      word_source = TwitterWordSource.new("ruby")
      expect(word_source.count).to eql(0)
      expect(word_source.top_5_consonants).to eql([nil, nil, nil, nil, nil])
      expect(word_source.top_5_words).to eql([nil, nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.count).to eql(1)
      expect(word_source.top_5_consonants).to eql(["b", "r", "y", nil, nil])
      expect(word_source.top_5_words).to eql(["ruby", nil, nil, nil, nil])
      word_source.run
      expect(word_source.count).to eql(8)
      expect(word_source.top_5_consonants).to eql(["r", "s", "b", "y", "f"])
      expect(word_source.top_5_words).to eql(["ruby", "awesome", "is", "on", "rails"])
    end
  end
end
