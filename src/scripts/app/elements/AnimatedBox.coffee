#http://www.clicktorelease.com/blog/vertex-displacement-noise-3d-webgl-glsl-three-js
#
define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'

  AnimatedObject = require 'cs!app/elements/AnimatedObject'
  class AnimatedBox extends AnimatedObject
    @circleGeom = new THREE.CircleGeometry( 10, 4, 0, Math.PI * 2 )
    @ringGeom = new THREE.RingGeometry( 10 - 1, 10 + 1, 4, 1, 0, Math.PI * 2 )
    @ringGeom2 = new THREE.RingGeometry( 10 - 1, 10, 4, 1, 0, Math.PI * 2 )

    constructor: () ->
      super
      console.log AnimatedBox.properties

    getGeometry: () ->
      return AnimatedBox.circleGeom

    getGeometryOutline: (outlineWidth) ->
      if outlineWidth < 1 then return AnimatedBox.ringGeom
      return AnimatedBox.ringGeom2
