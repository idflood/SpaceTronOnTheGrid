define (require) ->
  class Timer
    constructor: () ->
      # Use an array for the time for easier d3.js integration (used as data for timeseeker).
      @time = [0]
      @is_playing = false
      @last_timeStamp = -1
      window.requestAnimationFrame(@update)

    play: () ->
      @is_playing = true

    stop: () ->
      @is_playing = false

    toggle: () ->
      @is_playing = !@is_playing

    seek: (time) ->
      @time = time

    update: (timestamp) =>
      # Init timestamp
      if @last_timeStamp == -1 then @last_timeStamp = timestamp
      elapsed = timestamp - @last_timeStamp

      if @is_playing
        @time[0] += elapsed

      @last_timeStamp = timestamp
      window.requestAnimationFrame(@update)
