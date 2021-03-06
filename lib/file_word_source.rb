require 'word_source'

class FileWordSource < WordSource
  def initialize(file_path)
    file = File.open(file_path, "r")
    words = file.read.split(",").map(&:chomp)
    super(words)
  end
end
