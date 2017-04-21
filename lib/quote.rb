require 'httparty'
require 'json'

class Quote 
  def initialize logger, scheduler, bot
    scheduler.every '1h', self
    @bot = bot
    @logger = logger

    @bot.command :quote do |event, num|
      if num == nil
        @quotes.sample["quote"]
      else
        @quotes[num.to_i - 1]["quote"]
      end
    end

    call
  end

  def call
    @logger.info "Polling osber.bt.gs for quotes..."
    response = HTTParty.get("http://osber.bt.gs/configs/starrlett20.json")
    @logger.debug "osber.bt.gs responded with a #{response.code}."

    raise "Osber API Error" if response.code < 200 || response.code > 299

    parsed = JSON.parse response.body

    @quotes = parsed["quotes"]

    @logger.info "Got #{@quotes.size} quotes from Osber."
  end
end
