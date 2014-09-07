#http://www.clicktorelease.com/blog/vertex-displacement-noise-3d-webgl-glsl-three-js
#
define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'
  RNG = require 'rng'
  TweenMax = require 'TweenMax'
  TimelineMax = require 'TimelineMax'

  Colors = require 'cs!app/components/Colors'

  # should not be a dependency.
  Audio = require 'cs!app/components/Audio'

  ShaderVertex = require 'text!app/shaders/BasicNoise.vert'
  ShaderFragement = require 'text!app/shaders/BasicNoise.frag'

  class AnimatedCircle
    @circleGeom = new THREE.CircleGeometry( 10, 30, 0, Math.PI * 2 )
    @ringGeom = new THREE.RingGeometry( 10 - 1, 10 + 1, 30, 1, 0, Math.PI * 2 )
    @ringGeom2 = new THREE.RingGeometry( 10 - 1, 10, 30, 1, 0, Math.PI * 2 )

    @properties:
      size: {name: 'size', label: 'size', val: 80}
      outlineWidth: {name: 'outlineWidth', label: 'outline width', val: 2}
      drawOutline: {name: 'drawOutline', label: 'draw outline', val: true}
      drawCircle: {name: 'drawCircle', label: 'draw circle', val: false}
      color: {name: 'color', label: 'color', val: false}
      fillColor: {name: 'fillColor', label: 'fill color', val: false}
      delay: {name: 'delay', label: 'delay', val: 0}
      duration: {name: 'duration', label: 'duration', val: 0.5}
      x: {name: 'x', label: 'x', val: 0}
      y: {name: 'y', label: 'y', val: 0}
      z: {name: 'z', label: 'z', val: 0}

    constructor: (@values = {}, time = 0) ->
      for key, prop of AnimatedCircle.properties
        if !@values[key]?
          @values[key] = prop.val

      @container = new THREE.Object3D()
      @container.scale.set(0.001,0.001,0.001)
      @container.position.set(@values.x, @values.y, @values.z)
      @materials = []
      @start = Date.now()

      @offset = new THREE.Vector3()
      @velocity = new THREE.Vector3()
      @weight = Math.random() * 0.5 + 0.5
      @direction = new THREE.Vector3(Math.random() * 2 - 1, Math.random() * 2 - 1, 0)
      @speed = 0
      @animatedProperties =
        scale: 0.001
      @timeline = new TimelineMax()
      # First value
      tween = TweenLite.to(@animatedProperties, 0, {scale: 0.00001, ease: Linear.easeNone})
      @timeline.add(tween, 0)
      # Middle
      tween = TweenLite.to(@animatedProperties, @values.duration, {scale: 1, delay: @values.delay, ease: Cubic.easeOut})
      @timeline.add(tween)

      # Stay for a while
      tween = TweenLite.to(@animatedProperties, @values.duration * 0.5, {scale: 1, ease: Cubic.easeOut})
      @timeline.add(tween)

      # End
      tween = TweenLite.to(@animatedProperties, @values.duration, {scale: 0.00001, ease: Cubic.easeIn})
      @timeline.add(tween)

      if @values.drawOutline then @renderOutline(@values.size, @values.color, @values.outlineWidth)
      if @values.drawCircle then @renderCircle(@values.size, @values.fillColor)

      #@update(0, values)

    destroy: () ->
      @timeline.clear()

      for child in @container.children
        @container.remove(child)
      #@container.destroy()

      @container = null

    getMaterial: (color) ->
      uniforms = {
        time: {
          type: 'f',
          value: 0.0
        },
        color: {
          type: 'c',
          value: color
        }
      }
      material = new THREE.ShaderMaterial({
        vertexShader: ShaderVertex,
        fragmentShader: ShaderFragement,
        uniforms: uniforms,
        transparent: true,
        depthWrite: false,
        depthTest: false
        })

      material.blending = THREE.AdditiveBlending
      return material

    update: (seconds, progression) ->
      #if Audio.instance.high > 0.002
      #  @speed += Audio.instance.high
      #console.log Audio.instance.high

      #if Math.random() > 0.9 && Audio.instance.high > 0.09
      #  @velocity.add(@direction.clone().multiplyScalar(Audio.instance.high * 12 * @weight))
      @container.position.add(@velocity)

      @velocity = @velocity.multiplyScalar(0.94)

      #@speed *= 0.95
      #console.log "ok"
      # Progression goes from 0 to 2, we want to be a percent of total

      timeDiff = Date.now() - @start
      for material in @materials
        material.uniforms['time'].value = 0.00025 * ( timeDiff )


      #@timeline.seek(@timeline.duration() * progression)
      scale = @animatedProperties.scale * @values.size * 0.1
      @container.scale.set(scale, scale, scale)

    renderCircle: (size, color) =>
      #color = color.clone().multiplyScalar(@rng.random(0.3, 0.5))
      #material = new THREE.MeshBasicMaterial({color: color, wireframe: false, transparent: true, depthWrite: false, depthTest: false})
      material = @getMaterial(color)
      @materials.push(material)

      numSegments = parseInt(size / 1.5, 10) + 4
      #new THREE.CircleGeometry( size, numSegments, 0, Math.PI * 2 )
      object = new THREE.Mesh( AnimatedCircle.circleGeom, material )
      #object = new THREE.Mesh( new THREE.BoxGeometry(30, 30, 30 , 2, 2, 2), material )
      #object.position.set( x, y, 0 )
      #object.rotation.set(Math.PI / -2, 0, 0)
      @container.add( object )

    renderOutline: (size, color, outlineWidth) =>
      geom = AnimatedCircle.ringGeom
      if outlineWidth > 1
        geom = AnimatedCircle.ringGeom2
      #material = new THREE.MeshBasicMaterial({color: color, transparent: true, depthWrite: false, depthTest: false})

      #new THREE.RingGeometry( size - 1, size + outlineWidth, 50, 1, 0, Math.PI * 2 )
      material = @getMaterial(color)
      @materials.push(material)
      object = new THREE.Mesh( geom, material )
      #object.position.set(x, y, 0 )
      @container.add( object )
