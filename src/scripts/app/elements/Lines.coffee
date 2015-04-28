define (require) ->
  AnimatedLine = require 'app/elements/AnimatedLine'
  SpreadedObjects = require 'app/elements/SpreadedObjects'

  class Lines extends SpreadedObjects
    getItemClass: () -> return AnimatedLine
