define (require) ->
  _ = require 'lodash'
  THREE = require 'Three'

  class Global
    @properties:
      bassSensibility: {name: 'bassSensibility', label: 'bassSensibility x', val: 5, min: 0, max: 5}
      midSensibility: {name: 'midSensibility', label: 'midSensibility', val: 0.8, min: 0, max: 5}
      highSensibility: {name: 'highSensibility', label: 'highSensibility', val: 5, min: 0, max: 5}
      autoAnimate: {name: 'autoAnimate', label: 'autoAnimate', val: 0, min: 0, max: 1}

    constructor: (@values = {}, time = 0) ->
      window.global = this

    update: (seconds, values = false, force = false) ->
      if values == false then values = @values
      @values = _.merge(@values, values)

    destroy: () ->
      return
