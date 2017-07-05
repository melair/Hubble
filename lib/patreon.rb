require 'redis'

STARRGAZERS_SNOWFLAKE_ID = 101806900919701504

BUTTHEART_SNOWFLAKE_ID = 230265155030614016
PATREON_SNOWFLAKE_ID = 177204395484774400

PATREON_LOW_ROLE_ID = 287533908533313536
PATREON_HIGH_ROLE_ID = 177204478246780938
TWITCH_SUBS_ROLE_ID = 330863224335499264

PATREON_WELCOME_ROLES = [ PATREON_HIGH_ROLE_ID, TWITCH_SUBS_ROLE_ID ]

class Patreon
  def initialize logger, bot
    @redis = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])
    @bot = bot
    @logger = logger

    @bot.member_join do |event|
      @logger.debug "Member join for '#{event.user.name}'."
      check_user_roles event.user
    end

    @bot.member_update do |event|
      @logger.debug "Member update for '#{event.user.name}'."
      check_user_roles event.user
    end

    @bot.member_leave do |event|
      @logger.debug "Member leave for '#{event.user.name}'."
      @redis.del "patron_#{event.user.id}"
    end

    debug_roles

    server = @bot.servers[STARRGAZERS_SNOWFLAKE_ID]
    @emoji = @bot.emoji(BUTTHEART_SNOWFLAKE_ID)

    server.members.each do |user|
      check_user_roles user
    end
  end

  private

  def check_user_roles user
    roles = user.roles.select { |role| PATREON_WELCOME_ROLES.include? role.id }

    has_role = roles.size > 0
    already_patron = is_already_patreon(user.id)

    @logger.debug "Checking '#{user.name}', now = #{has_role}, already = #{already_patron}."

    if already_patron.nil?
      @logger.info "No patron information for '#{user.name}', storing as '#{has_role}.'"
      set_patron user.id, has_role
    else
      if already_patron != has_role
        @logger.debug "Differing in patron information for '#{user.name}', storing as '#{has_role}'."
        set_patron user.id, has_role

        if has_role
          @logger.info "Announcing new patron membership for '#{user.name}'."
          announce_patron user, roles
        end
      end
    end
  end

  def announce_patron user, roles
    type = roles.include?(TWITCH_SUBS_ROLE_ID) ? "Twitch subscriber" : "Patreon"

    msg = @bot.send_message PATREON_SNOWFLAKE_ID, "Everyone @here, please welcome #{user.mention} as a #{type}!"
    msg.create_reaction @emoji
  end

  def is_already_patreon id
    raw = @redis.get "patron_#{id}"

    if raw.nil?
      nil
    else
      raw == "true"
    end
  end

  def set_patron id, value
    @redis.set "patron_#{id}", value ? "true" : "false"
  end

  def debug_roles
    server = @bot.servers[STARRGAZERS_SNOWFLAKE_ID]

    @logger.debug "Debugging roles for '#{server.name}'."

    server.roles.each do |role|
      @logger.debug "Role: #{role.id} => #{role.name}"
    end
  end
end
