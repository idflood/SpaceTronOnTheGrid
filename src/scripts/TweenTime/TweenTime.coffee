define (require) ->
  Timer = require 'cs!TweenTime/core/Timer'
  Orchestrator = require 'cs!TweenTime/core/Orchestrator'

  class TweenTime
    constructor: (@data) ->
      @timer = new Timer()
      @orchestrator = new Orchestrator(@timer, @data)