GAMES = [
  'with Starr\'s Chest',
  'with Osber',
  'watching Starrlett',
  'Overwatch',
  'Secret Hitler'
]

STREAMING_TEXT = 'with Starrlett'
STREAMING_URL = 'https://twitch.tv/starrlett20'

class Status
  def initialize logger, scheduler, bot
    @streaming = false
    @bot = bot
    @logger = logger
    @current_game = nil

    interval = "#{110 + Random.rand(20)}s"
    @logger.debug "Status update interval is '#{interval}'."
    scheduler.every interval, self

    call
  end

  def call
    @logger.debug 'Status update called.'

    unless @streaming
      newGame = GAMES.sample

      if @current_game != newGame
        @current_game = newGame

        @logger.info "Setting new game to '#{@current_game}'."
        @bot.game= @current_game
      end
    end
  end

  def streaming state
    @streaming = state

    if @streaming
      @logger.info "Setting status to streaming."
      @bot.stream STREAMING_TEXT, STREAMING_URL
    else
      call
    end
  end
end
