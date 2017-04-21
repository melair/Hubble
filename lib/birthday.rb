PUBLIC_HUB_SNOWFLAKE_ID = 101806900919701504

class Birthday
  def initialize logger, scheduler, bot
    @bot = bot
    @logger = logger
    @announced_year = 0

    scheduler.every "1h", self

    call
  end

  def call
    if is_birthday
      @logger.info "Starrlett's birthday, announcing."
      @bot.send_message PUBLIC_HUB_SNOWFLAKE_ID, "Hey @everyone, it's Starrlett's birthday!"
    end
  end

  private

  def is_birthday
    now = Time.now

    if now.day == 7 && now.month == 11
      if @announced_year < now.year
        @announced_year = now.year
        return true
      end
    end

    false
  end
end
