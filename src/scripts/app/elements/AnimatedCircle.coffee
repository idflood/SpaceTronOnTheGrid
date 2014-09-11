#http://www.clicktorelease.com/blog/vertex-displacement-noise-3d-webgl-glsl-three-js
#
define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'

  AnimatedObject = require 'cs!app/elements/AnimatedObject'
  class AnimatedCircle extends AnimatedObject
    @circleGeom = new THREE.CircleGeometry( 10, 30, 0, Math.PI * 2 )
    @ringGeom = new THREE.RingGeometry( 10 - 1, 10 + 1, 30, 1, 0, Math.PI * 2 )
    @ringGeom2 = new THREE.RingGeometry( 10 - 1, 10, 30, 1, 0, Math.PI * 2 )

    constructor: () ->
      super
      console.log AnimatedCircle.properties

    getGeometry: () ->
      return AnimatedCircle.circleGeom

    getGeometryOutline: (outlineWidth) ->
      if outlineWidth < 1 then return AnimatedCircle.ringGeom
      return AnimatedCircle.ringGeom2
