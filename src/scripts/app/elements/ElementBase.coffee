define (require) ->

  class ElementBase
    constructor: (@values = {}, time = 0) ->
      @cache = @buildCache()

    buildCache: () ->
      cache = {}
      for key, prop of @values
        cache[key] = prop.val
      return cache

    valueChanged: (key, values) ->
      # Value can't change if it is not even set.
      if !values[key]? then return false
      new_val = values[key]
      has_changed = true
      if @cache[key]? && @cache[key] == new_val then has_changed = false

      # Directly set the new cache value to avoid setting it multiple time to true.
      @cache[key] = new_val
      return has_changed

    degreeToRadian: (degree) -> Math.PI * degree / 180

    destroy: () =>
      delete @cache
