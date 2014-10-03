require 'word_source'

class StringWordSource < WordSource
  def initialize(text)
    words = text.split(",")
    super(words)
  end
end
