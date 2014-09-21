define (require) ->
  AnimatedCircle = require 'cs!app/elements/AnimatedCircle'
  SpreadedObjects = require 'cs!app/elements/SpreadedObjects'

  class Circles extends SpreadedObjects
    getItemClass: () -> return AnimatedCircle
