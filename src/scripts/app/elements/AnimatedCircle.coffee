define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'
  RNG = require 'rng'
  TweenMax = require 'TweenMax'
  TimelineMax = require 'TimelineMax'

  Colors = require 'cs!app/components/Colors'

  class AnimatedCircle
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

    constructor: (@properties = {}) ->
      for key, prop of AnimatedCircle.properties
        if !@properties[key]?
          @properties[key] = prop.val
      #@properties = _.cloneDeep(AnimatedCircle.properties)
      #@properties = _.merge(@properties, properties)

      @container = new THREE.Object3D()
      @container.scale.set(0.001,0.001,0.001)
      @container.position.set(@properties.x, @properties.y, @properties.z)
      @animatedProperties =
        scale: 0.001
      @timeline = new TimelineMax()
      # First value
      tween = TweenLite.to(@animatedProperties, 0, {scale: 0.00001, ease: Linear.easeNone})
      @timeline.add(tween, 0)
      # Middle
      tween = TweenLite.to(@animatedProperties, @properties.duration, {scale: 1, delay: @properties.delay, ease: Cubic.easeOut})
      @timeline.add(tween)

      # Stay for a while
      tween = TweenLite.to(@animatedProperties, @properties.duration * 0.5, {scale: 1, ease: Cubic.easeOut})
      @timeline.add(tween)

      # End
      tween = TweenLite.to(@animatedProperties, @properties.duration, {scale: 0.00001, ease: Cubic.easeIn})
      @timeline.add(tween)

      if @properties.drawOutline then @renderOutline(@properties.size, @properties.color, @properties.outlineWidth)
      if @properties.drawCircle then @renderCircle(@properties.size, @properties.fillColor)


      #@update(0, values)

    update: (seconds, progression) ->
      #console.log "ok"
      # Progression goes from 0 to 2, we want to be a percent of total

      #@timeline.seek(@timeline.duration() * progression)
      @container.scale.set(@animatedProperties.scale, @animatedProperties.scale, @animatedProperties.scale)

    renderCircle: (size, color) =>
      #color = color.clone().multiplyScalar(@rng.random(0.3, 0.5))
      material = new THREE.MeshBasicMaterial({color: color, transparent: true, depthWrite: false, depthTest: false})
      material.blending = THREE.AdditiveBlending

      numSegments = parseInt(size / 1.5, 10) + 4
      object = new THREE.Mesh( new THREE.CircleGeometry( size, numSegments, 0, Math.PI * 2 ), material )
      #object = new THREE.Mesh( new THREE.BoxGeometry(30, 30, 30 , 2, 2, 2), material )
      #object.position.set( x, y, 0 )
      #object.rotation.set(Math.PI / -2, 0, 0)
      @container.add( object )

    renderOutline: (size, color, outlineWidth) =>
      material = new THREE.MeshBasicMaterial({color: color, transparent: true, depthWrite: false, depthTest: false})
      material.blending = THREE.AdditiveBlending
      object = new THREE.Mesh( new THREE.RingGeometry( size - 1, size + outlineWidth, 50, 1, 0, Math.PI * 2 ), material )
      #object.position.set(x, y, 0 )
      @container.add( object )
