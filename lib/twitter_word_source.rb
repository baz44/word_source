require 'yaml'

class TwitterWordSource < WordSource

  def initialize(search_term)
    client = create_client
    words = []
    client.search(search_term, :result_type => "recent").take(10).collect do |tweet|
      words << tweet.text.split(" ")
    end
    super(words.flatten)
  end

  private

  def create_client
    twitter_config = YAML.load_file(File.expand_path("./config/twitter.yml"))["twitter"]
    Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter_config["consumer_key"]
      config.consumer_secret     = twitter_config["consumer_secret"]
      config.access_token        = twitter_config["access_token"]
      config.access_token_secret = twitter_config["access_token_secret"]
    end
  end
end
