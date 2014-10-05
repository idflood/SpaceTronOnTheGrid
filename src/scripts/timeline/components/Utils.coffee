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

    @getClosestTime: (time, objectId = false, property_name = false, tolerance = 0.1) ->
      data = window.app.data
      for item in data
        # Don't match item with itself, but allow property to match item start/end.
        if item.id != objectId || property_name
          # First check start & end.
          if Math.abs(item.start - time) <= tolerance
            return item.start
          if Math.abs(item.end - time) <= tolerance
            return item.end

        # Test properties keys
        for prop in item.properties
          # Don't match property with itself.
          if item.id != objectId || prop.name != property_name
            for key in prop
              if Math.abs(key.time - time) <= tolerance
                return key.time

      return false
