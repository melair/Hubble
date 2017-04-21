require 'logger'
require 'discordrb'
require 'rufus-scheduler'
require 'dotenv'

require_relative 'lib/status'
require_relative 'lib/twitch'
require_relative 'lib/patreon'
require_relative 'lib/birthday'
require_relative 'lib/admin'
require_relative 'lib/quote'

Dotenv.load

logger = Logger.new(STDOUT)

logger.info "Starting Hubble..."
bot = Discordrb::Commands::CommandBot.new token: ENV['DISCORD_TOKEN'], prefix: '!'
logger.info "Connecting to Discord async."
bot.run :async

logger.info "Starting scheduler and registering modules."
scheduler = Rufus::Scheduler.new

status = Status.new logger, scheduler, bot
twitch = Twitch.new logger, scheduler, bot, status
patreon = Patreon.new logger, bot
birthday = Birthday.new logger, scheduler, bot
admin = Admin.new logger, bot
quote = Quote.new logger, scheduler, bot

logger.info "Main thread now waiting on scheduler."
scheduler.join
