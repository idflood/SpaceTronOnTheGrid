define (require) ->
  AnimatedBox = require 'cs!app/elements/AnimatedBox'
  SpreadedObjects = require 'cs!app/elements/SpreadedObjects'

  class Boxes extends SpreadedObjects
    getItemClass: () -> return AnimatedBox
