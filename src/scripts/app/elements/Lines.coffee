define (require) ->
  AnimatedLine = require 'cs!app/elements/AnimatedLine'
  SpreadedObjects = require 'cs!app/elements/SpreadedObjects'

  class Lines extends SpreadedObjects
    getItemClass: () -> return AnimatedLine
