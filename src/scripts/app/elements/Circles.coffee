define (require) ->
  AnimatedCircle = require 'app/elements/AnimatedCircle'
  SpreadedObjects = require 'app/elements/SpreadedObjects'

  class Circles extends SpreadedObjects
    getItemClass: () -> return AnimatedCircle
