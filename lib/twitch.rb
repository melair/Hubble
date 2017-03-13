require 'httparty'
require 'json'

TWITCH_CHANNEL = 'starrlett20'
TWITCH_URL = 'https://twitch.tv/starrlett20'

DAMPENING_PERIOD = 900

ANNOUNCE_SNOWFLAKE_ID = 179016905993093120

class Twitch
  def initialize logger, scheduler, bot, status
    scheduler.every '1m', self
    @streaming = false
    @bot = bot
    @status = status
    @logger = logger
    @last_announcement = 0
  end

  def call
    game = check_twitch TWITCH_CHANNEL

    if @streaming
      if game.nil?
        @streaming = false
        @status.streaming false
      end
    else
      unless game.nil?
        @streaming = true
        @status.streaming true
        announce game
      end
    end
  end

  private

  def check_twitch channel
    @logger.info "Polling Twitch.tv for streams for '#{TWITCH_CHANNEL}'."
    response = HTTParty.get("https://api.twitch.tv/kraken/streams/#{TWITCH_CHANNEL}?client_id=#{ENV['TWITCH_TOKEN']}")
    @logger.debug "Twitch.tv responded with a #{response.code}."

    raise "Twitch API Error" if response.code < 200 || response.code > 299

    @logger.debug "Body: #{response.body}"
    parsed = JSON.parse response.body

    if parsed["stream"].nil?
      @logger.debug "'#{TWITCH_CHANNEL}' is not streaming."
      nil
    else
      val = parsed["stream"]["channel"]["status"]
      @logger.debug "'#{TWITCH_CHANNEL}' is streaming '#{val}'."
      val
    end
  end

  def announce game
    current_time = Time.now.to_i

    if ((current_time - @last_announcement) > DAMPENING_PERIOD)
      @last_announcement = current_time

      @announcement = []
      @announcement << "Starrlett is streaming at the moment! @here"
      @announcement << "Join her for '#{game}'!"
      @announcement << TWITCH_URL

      @bot.send_message ANNOUNCE_SNOWFLAKE_ID, @announcement.join("\n")
    end
  end
end
