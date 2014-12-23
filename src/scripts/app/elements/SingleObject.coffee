define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'
  RNG = require 'rng'
  ElementBase = require 'cs!app/elements/ElementBase'
  Colors = require 'cs!app/components/Colors'

  ShaderVertex = require 'text!app/shaders/BasicNoise.vert'
  ShaderFragement = require 'text!app/shaders/BasicNoise.frag'

  class SingleObject extends ElementBase
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
      color: {name: 'color', label: 'color', 'type': 'color', val: "#888888"}
      opacity: {name: 'opacity', label: 'opacity', val: 1, min: 0, max: 1}

    constructor: (@values = {}, time = 0) ->
      # Set the default value of instance properties.
      for key, prop of @getDefaultProperties()
        if !@values[key]?
          @values[key] = prop.val

      # Set values cache
      super

      @timeline = new TimelineMax()
      #color = Colors.get(0)
      color = new THREE.Color(values.color)
      @material = @getMaterial(color)
      @container = new THREE.Mesh(@getGeometry() , @material )

    getDefaultProperties: () -> SingleObject.properties

    getGeometry: () =>
      return new THREE.PlaneGeometry( 100, 100)

    destroy: () ->
      super
      # clean up...
      if @container
        if @container.parent then @container.parent.remove(@container)
        delete @container

      delete @geometry
      delete @timeline

    update: (seconds, values = false, force = false) ->
      if values == false then values = @values

      if force || @valueChanged("x", values) || @valueChanged("y", values) || @valueChanged("z", values)
        @container.position.set(values.x, values.y, values.z)

      if force || @valueChanged("rotX", values) || @valueChanged("rotY", values) || @valueChanged("rotZ", values)
        @container.rotation.set(@degreeToRadian(values.rotX), @degreeToRadian(values.rotY), @degreeToRadian(values.rotZ))
      if force || @valueChanged("scaleX", values) || @valueChanged("scaleY", values) || @valueChanged("scaleZ", values)
        # Don't allow scale by 0.
        values.scaleX = values.scaleX || 0.000000001
        values.scaleY = values.scaleY || 0.000000001
        values.scaleZ = values.scaleZ || 0.000000001
        @container.scale.set(values.scaleX, values.scaleY, values.scaleZ)

      if force || @valueChanged("color", values)
        @material.color = new THREE.Color(values.color)
      if force || @valueChanged("opacity", values)
        @material.opacity = values.opacity
      return

    getMaterial: (color) ->
      material = new THREE.MeshPhongMaterial({ ambient: 0x030303, color: 0xdddddd, specular: 0x888888, shininess: 30, shading: THREE.FlatShading })
      material.transparent = true
      material.depthWrite = false
      material.depthTest = false
      material.side = THREE.DoubleSide

      material.blending = THREE.AdditiveBlending
      return material
