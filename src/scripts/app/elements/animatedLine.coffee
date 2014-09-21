define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'

  AnimatedObject = require 'cs!app/elements/AnimatedObject'
  class AnimatedLine extends AnimatedObject
    @circleGeom = new THREE.PlaneGeometry( 100, 1)
    @ringGeom = false
    @ringGeom2 = false
    @noOutline = true

    constructor: () ->
      super

    getGeometry: () -> return AnimatedLine.circleGeom

    getGeometryOutline: (outlineWidth) -> return false

    update: (seconds, progression) ->
      #if Audio.instance.high > 0.002
      #  @speed += Audio.instance.high
      #console.log Audio.instance.high

      #if Math.random() > 0.9 && Audio.instance.high > 0.09
      #  @velocity.add(@direction.clone().multiplyScalar(Audio.instance.high * 12 * @weight))
      @container.position.add(@velocity)

      @velocity = @velocity.multiplyScalar(0.94)

      timeDiff = Date.now() - @start
      for material in @materials
        material.uniforms['time'].value = 0.00025 * ( timeDiff )

      scale = @animatedProperties.scale * @values.size * 0.1
      @container.scale.set(1, scale, 1)
