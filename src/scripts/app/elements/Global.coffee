define (require) ->
  _ = require 'lodash'
  THREE = require 'Three'

  class Global
    @properties:
      bassSensibility: {name: 'bassSensibility', label: 'bassSensibility x', val: 120, min: 0, max: 200}
      midSensibility: {name: 'midSensibility', label: 'midSensibility', val: 100, min: 0, max: 200}
      highSensibility: {name: 'highSensibility', label: 'highSensibility', val: 120, min: 0, max: 200}
      autoAnimate: {name: 'autoAnimate', label: 'autoAnimate', val: 0, min: 0, max: 1}

    constructor: (@values = {}, time = 0) ->
      window.global = this

    update: (seconds, values = false, force = false) ->
      if values == false then values = @values
      @values = _.merge(@values, values)

    destroy: () ->
      return
