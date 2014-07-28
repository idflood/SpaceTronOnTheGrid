define (require) ->
  class Utils
    @formatMinutes: (d) ->
      # convert milliseconds to seconds
      d = d / 1000
      hours = Math.floor(d / 3600)
      minutes = Math.floor((d - (hours * 3600)) / 60)
      seconds = d - (minutes * 60)
      output = seconds + "s"
      output = minutes + "m " + output  if minutes
      output = hours + "h " + output  if hours
      return output
