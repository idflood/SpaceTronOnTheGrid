define (require) ->
  AnimatedBox = require 'app/elements/AnimatedBox'
  SpreadedObjects = require 'app/elements/SpreadedObjects'

  class Boxes extends SpreadedObjects
    getItemClass: () -> return AnimatedBox
