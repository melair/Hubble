HUBBLE_CHANNEL_SNOWFLAKE_ID = 290939128319705108

class Admin
  def initialize logger, bot
    @bot = bot
    @logger = logger

    @bot.member_join do |event|
      @logger.debug "Member has joined '#{event.user.name}'."
      @bot.send_message HUBBLE_CHANNEL_SNOWFLAKE_ID, "#{event.user.mention} has joined!"
    end
  end
end
