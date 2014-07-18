define (require) ->
  THREE = require 'threejs'
  RNG = require 'rng'

  Colors = require 'cs!app/components/Colors'
  AnimatedCircle = require 'cs!app/elements/AnimatedCircle'

  TimelineMax = require 'TimelineMax'

  class Circles
    @defaults:
      numItems: 20
      seed: 12002
      radius: 80
      circleRadius: 20
      circleRadiusMax: 20

    constructor: (options = {}) ->
      @numItems = options.numItems || Circles.defaults.numItems
      @seed = options.seed || Circles.defaults.seed
      @radius = options.radius || Circles.defaults.radius
      @circleRadius = options.circleRadius || Circles.defaults.circleRadius
      @circleRadiusMax = options.circleRadiusMax || Circles.defaults.circleRadiusMax

      @timeline = new TimelineMax()
      @rng = new RNG(@seed)
      @rngAnimation = new RNG(@seed + "lorem")
      @rngOutline = new RNG(@seed)
      @container = new THREE.Object3D()
      @totalDuration = 0
      @items = []

      #@blackMaterial = new THREE.MeshBasicMaterial({color: 0x7ed2f1, transparent: true, depthWrite: false, depthTest: false})
      #@blackMaterial.blending = THREE.AdditiveBlending

      for i in [0..@numItems - 1]
        color = Colors.get(@rng.random(0, 1000))
        fillColor = color.clone().multiplyScalar(@rng.random(0.3, 0.5))
        rndtype = @rng.random(0, 1000) / 1000
        size = @rng.random(@circleRadius, @circleRadiusMax)
        x = @getRandomPosition()
        y = @getRandomPosition()
        delay = @rngAnimation.random(0, 2400) / 1000
        duration = @rngAnimation.random(600, 800) / 1000
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
          duration: duration
          }, {
            x: x,
            y: y
            })
        @container.add(item.container)
        @timeline.add(item.timeline, 0)
        @items.push(item)
        #@drawOutline(x, y, size, color)
        #@createCircle(x, y, size, color)
      @totalDuration = @timeline.duration()

    update: (seconds, values) ->
      # todo.
      if values.progression != undefined
        #@container.position.x = values.progression
        progression = values.progression / 2
        @timeline.seek(@totalDuration * progression)
        for item in @items
          item.update(seconds, values.progression)

    getRandomPosition: () ->
      return @rng.random(-@radius, @radius)
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
