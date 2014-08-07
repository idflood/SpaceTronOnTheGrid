define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'
  RNG = require 'rng'
  TimelineMax = require 'TimelineMax'

  Colors = require 'cs!app/components/Colors'
  AnimatedCircle = require 'cs!app/elements/AnimatedCircle'

  class Circles
    @properties:
      numItems: {name: 'num items', val: 20}
      seed: {name: 'seed', val: 12002}
      radius: {name: 'radius', val: 80}
      circleRadius: {name: 'circle radius', val: 20}
      circleRadiusMax: {name: 'circle radius max', val: 20}
      progression: {name: 'progression', val: 1}
      x: {name: 'x', val: 0}
      y: {name: 'y', val: 0}
      z: {name: 'z', val: 0}

    constructor: (@properties = {}) ->
      # Set the default value of instance properties.
      for key, prop of Circles.properties
        if !@properties[key]?
          @properties[key] = prop.val

      @timeline = new TimelineMax()
      @rng = new RNG(@properties.seed)
      @rngAnimation = new RNG(@properties.seed + "lorem")
      @rngOutline = new RNG(@properties.seed)
      @container = new THREE.Object3D()
      @totalDuration = 0
      @items = []

      #@blackMaterial = new THREE.MeshBasicMaterial({color: 0x7ed2f1, transparent: true, depthWrite: false, depthTest: false})
      #@blackMaterial.blending = THREE.AdditiveBlending

      for i in [0..@properties.numItems - 1]
        color = Colors.get(@rng.random(0, 1000))
        fillColor = color.clone().multiplyScalar(@rng.random(0.3, 0.5))
        rndtype = @rng.random(0, 1000) / 1000
        size = @rng.random(@properties.circleRadius, @properties.circleRadiusMax)
        x = @getRandomPosition()
        y = @getRandomPosition()
        delay = @rngAnimation.random(0, 2400) / 1000
        duration = @rngAnimation.random(600, 800) / 1000
        duration *= 4
        border_radius = @rngOutline.exponential()
        draw_outline = if rndtype < 0.8 then true else false
        draw_circle = if rndtype > 0.5 then true else false
        item = new AnimatedCircle({
          size: size,
          outlineWidth: border_radius,
          drawOutline: draw_outline,
          drawCircle: draw_circle,
          color: color,
          fillColor: fillColor,
          delay: delay,
          duration: duration,
          x: x,
          y: y
        })
        @container.add(item.container)
        @timeline.add(item.timeline, 0)
        @items.push(item)

      @totalDuration = @timeline.duration()

      # Set initial properties
      @update(0, @properties)

    update: (seconds, values = false) ->
      if values == false then return
      if values.x?
        @container.position.set(values.x, values.y, values.z)

      if values.progression?
        progression = values.progression / 2
        @timeline.seek(@totalDuration * progression)
        for item in @items
          item.update(seconds, values.progression)


    getRandomPosition: () ->
      return @rng.random(-@properties.radius, @properties.radius)
      #x = @rng.exponential() * @radius
      #if @rng.random(-1, 1) < 0 then x *= -1
      #return x

    createCircle: (x, y, size, color) =>


    drawOutline: (x, y, size, color) =>


    destroy: () ->
      # clean up...
      if @container
        if @container.parent then @container.parent.remove(@container)
        delete @container
      delete @rng
      delete @rngOutline
      #delete @blackMaterial
