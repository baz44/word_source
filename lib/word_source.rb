class WordSource

  CONSONANTS =  %w{b c d f g h j k l m n p q r s t v w x y z}

  def initialize(words)
    @words = words
    @current_word_position = 0
    @callbacks = Hash.new
  end

  def next_word
    current_word = @words[@current_word_position]
    @current_word_position += 1
    call_callback(current_word)
    return current_word
  end

  def top_5_words
    top_n_strings(words_seen, 5)
  end

  def top_5_consonants
    strings = words_seen.join("").split("").select {|letter| CONSONANTS.include?(letter)}
    top_n_strings(strings, 5)
  end

  def count
    words_seen.count
  end

  def run
    @words.each do |word|
      next_word
    end
  end

  def on_next_encounter(string, &callback)
    @callbacks[string] ||= []
    @callbacks[string] << callback
  end

  private

  def words_seen
    @current_word_position == 0 ? [] : @words.slice(0, @current_word_position)
  end

  def call_callback(word)
    @callbacks[word].map(&:call) if @callbacks[word]
  end

  def top_strings_with_count(strings)
    top_strings = Hash.new(0)
    strings.each {|string| top_strings[string] +=1 }
    top_strings.sort_by {|string, count| [-count, string]}
  end

  def top_n_strings(strings, n)
    top_strings = top_strings_with_count(strings)
    n.times.map do |item|
      top_strings[item] ? top_strings[item][0] : nil
    end
  end
end
