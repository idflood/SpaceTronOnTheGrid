define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'
  RNG = require 'rng'
  SingleObject = require 'cs!app/elements/SingleObject'
  Colors = require 'cs!app/components/Colors'

  ShaderVertex = require 'text!app/shaders/BasicNoise.vert'
  ShaderFragement = require 'text!app/shaders/BasicNoise.frag'

  class Circle extends SingleObject
    @properties:
      x: {name: 'x', label: 'x', val: 0}
      y: {name: 'y', label: 'y', val: 0}
      z: {name: 'z', label: 'z', val: 0}
      rotX: {name: 'rotX', label: 'rotation x', val: 0}
      rotY: {name: 'rotY', label: 'rotation y', val: 0}
      rotZ: {name: 'rotZ', label: 'rotation z', val: 0}
      scaleX: {name: 'scaleX', label: 'scale x', val: 1}
      scaleY: {name: 'scaleY', label: 'scale y', val: 1}
      scaleZ: {name: 'scaleZ', label: 'scale z', val: 1}
      innerRadius: {name: 'innerRadius', label: 'innerRadius', val: 0.7, min: 0, max: 1}
      color: {name: 'color', label: 'color', 'type': 'color', val: "#888888"}
      opacity: {name: 'opacity', label: 'opacity', val: 1, min: 0, max: 1}

    getDefaultProperties: () -> Circle.properties

    getGeometry: () =>
      # Don't allow 0 innerRadius
      inner_radius = @values.innerRadius || 0.000000001
      # And neither 1.
      inner_radius = Math.min(0.999999999, inner_radius)
      return new THREE.RingGeometry( 100 * inner_radius, 100, 30, 1, 0, Math.PI * 2 )

    update: (seconds, values = false, force = false) ->
      super

      if force || @valueChanged("innerRadius", values)
        geom = @getGeometry()
        @container.geometry.dynamic = true
        @container.geometry.vertices = geom.vertices
        @container.geometry.verticesNeedUpdate = true

        geom.dispose()
      return
