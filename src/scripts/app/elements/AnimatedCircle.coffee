define (require) ->
  THREE = require 'threejs'
  RNG = require 'rng'

  Colors = require 'cs!app/components/Colors'

  TweenMax = require 'TweenMax'
  TimelineMax = require 'TimelineMax'

  class AnimatedCircle
    @defaults:
      size: 80
      outlineWidth: 2
      drawOutline: true
      drawCircle: false
      color: false
      fillColor: false
      delay: 0
      duration: 0.5

    constructor: (options = {}, values = {x: 0, y: 0}) ->
      @size = options.size || AnimatedCircle.defaults.size
      @outlineWidth = options.outlineWidth || AnimatedCircle.defaults.outlineWidth
      @drawOutline = options.drawOutline || AnimatedCircle.defaults.drawOutline
      @drawCircle = options.drawCircle || AnimatedCircle.defaults.drawCircle
      @color = options.color || Colors.get(0)
      @fillColor = options.fillColor || Colors.get(0).clone().multiplyScalar(0.5)
      @delay = options.delay || AnimatedCircle.defaults.delay
      @duration = options.duration || AnimatedCircle.defaults.duration

      @container = new THREE.Object3D()
      @container.scale.set(0,0,0)
      @container.position.set(values.x, values.y, 0)
      @animatedProperties =
        scale: 0
      @timeline = new TimelineMax()
      # First value
      tween = TweenLite.to(@animatedProperties, 0, {scale: 0.00001, ease: Linear.easeNone})
      @timeline.add(tween, 0)
      # Middle
      tween = TweenLite.to(@animatedProperties, @duration, {scale: 1, delay: @delay, ease: Cubic.easeOut})
      @timeline.add(tween)

      # Stay for a while
      tween = TweenLite.to(@animatedProperties, @duration * 0.5, {scale: 1.1, ease: Cubic.easeOut})
      @timeline.add(tween)

      # End
      tween = TweenLite.to(@animatedProperties, @duration, {scale: 0.00001, ease: Cubic.easeIn})
      @timeline.add(tween)

      if @drawOutline then @renderOutline(@size, @color, @outlineWidth)
      if @drawCircle then @renderCircle(@size, @fillColor)


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
