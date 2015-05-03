define (require) ->
  _ = require 'lodash'
  THREE = require 'Three'

  AnimatedObject = require 'app/elements/AnimatedObject'
  CircleGeometry2 = require 'app/geometries/CircleGeometry2'
  RingGeometry2 = require 'app/geometries/RingGeometry2'

  class AnimatedCircle extends AnimatedObject
    @circleGeom = new CircleGeometry2( 10, 30, 0, Math.PI * 2 )
    @ringGeom = new RingGeometry2( 10 - 1, 10 + 1, 30, 1, 0, Math.PI * 2 )
    @ringGeom2 = new RingGeometry2( 10 - 1, 10, 30, 1, 0, Math.PI * 2 )

    constructor: () ->
      super

    getGeometry: () ->
      return AnimatedCircle.circleGeom

    getGeometryOutline: (outlineWidth) ->
      if outlineWidth < 1 then return AnimatedCircle.ringGeom
      return AnimatedCircle.ringGeom2
