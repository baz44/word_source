require 'file_word_source'

describe FileWordSource do
  describe "#next_word" do
    it "should return the next word in the string if one exists" do
      word_source = FileWordSource.new("./spec/support/Lorem_ipsum.txt")
      expect(word_source.next_word).to eql("Lorem")
      expect(word_source.next_word).to eql("ipsum")
      expect(word_source.next_word).to eql("dolor")
    end

    it "should accept accept a callback and calls it when encountered" do
      @callback_called = 0
      word_source = FileWordSource.new("./spec/support/Lorem_ipsum.txt")
      word_source.on_next_encounter("ipsum") do
        @callback_called += 1
      end

      expect(word_source.next_word).to eql("Lorem")
      expect(@callback_called).to eql(0)
      expect(word_source.next_word).to eql("ipsum")
      expect(@callback_called).to eql(1)
    end

    it "should accept accept multiple callbacks and calls them when encountered" do
      @callback_called = 0
      word_source = FileWordSource.new("./spec/support/Lorem_ipsum.txt")
      word_source.on_next_encounter("ipsum") do
        @callback_called += 1
      end

      word_source.on_next_encounter("ipsum") do
        @callback_called += 1
      end

      expect(word_source.next_word).to eql("Lorem")
      expect(@callback_called).to eql(0)
      expect(word_source.next_word).to eql("ipsum")
      expect(@callback_called).to eql(2)
    end
  end

  describe "#top_5_words" do
    it "should return the top 5 words that have been seen" do
      word_source = FileWordSource.new("./spec/support/Lorem_ipsum.txt")
      expect(word_source.top_5_words).to eql([nil, nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_words).to eql(["Lorem", nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_words).to eql(["Lorem", "ipsum", nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_words).to eql(["Lorem", "dolor", "ipsum", nil, nil])
    end
  end

  describe "#top_5_consonants" do
    it "should return the top 5 consonants that have been seen" do
      word_source = FileWordSource.new("./spec/support/Lorem_ipsum.txt")
      expect(word_source.top_5_consonants).to eql([nil, nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.top_5_consonants).to eql(["l", "m", "r", nil, nil])
      word_source.next_word
      expect(word_source.top_5_consonants).to eql(["m", "l", "p", "r", "s"])
      word_source.next_word
      expect(word_source.top_5_consonants).to eql(["l", "m", "r", "d", "p"])
    end
  end

  describe "#count" do
    it "should return number of words that have been seen" do
      word_source = FileWordSource.new("./spec/support/Lorem_ipsum.txt")
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
      word_source = FileWordSource.new("./spec/support/Lorem_ipsum.txt")
      expect(word_source.count).to eql(0)
      expect(word_source.top_5_consonants).to eql([nil, nil, nil, nil, nil])
      expect(word_source.top_5_words).to eql([nil, nil, nil, nil, nil])
      word_source.next_word
      expect(word_source.count).to eql(1)
      expect(word_source.top_5_consonants).to eql(["l", "m", "r", nil, nil])
      expect(word_source.top_5_words).to eql(["Lorem", nil, nil, nil, nil])
      word_source.run
      expect(word_source.count).to eql(4946)
      expect(word_source.top_5_consonants).to eql(["s", "t", "n", "l", "r"])
      expect(word_source.top_5_words).to eql(["sed", "vel", "vitae", "et", "in"])
    end
  end
end


