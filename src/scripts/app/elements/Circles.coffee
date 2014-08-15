define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'
  RNG = require 'rng'
  TimelineMax = require 'TimelineMax'

  Colors = require 'cs!app/components/Colors'
  AnimatedCircle = require 'cs!app/elements/AnimatedCircle'

  class Circles
    @properties:
      numItems: {name: 'numItems', label: 'num items', val: 20}
      seed: {name: 'seed', label: 'seed', val: 12002, triggerRebuild: true}
      radius: {name: 'radius', label: 'radius', val: 80}
      circleRadius: {name: 'circleRadius', label: 'circle radius', val: 20}
      circleRadiusMax: {name: 'circleRadiusMax', label: 'circle radius max', val: 20}
      progression: {name: 'progression', label: 'progression', val: 1}
      x: {name: 'x', label: 'x', val: 0}
      y: {name: 'y', label: 'y', val: 0}
      z: {name: 'z', label: 'z', val: 0}

    constructor: (@values = {}, time = 0) ->
      # Set the default value of instance properties.
      # Should not happen when created with the orchestrator (so never really...)
      #for key, prop of Circles.properties
      #  if !@values[key]?
      #    @values[key] = prop.val

      @timeline = new TimelineMax()
      @container = new THREE.Object3D()
      @totalDuration = 0
      @items = []
      @cache = @buildCache()
      @build(time)

    buildCache: () ->
      cache = {}
      for key, prop of @values
        cache[key] = prop.val
      return cache

    rebuild: (time) ->
      @empty()
      @build(time)

    empty: () ->
      if !@items || !@items.length then return
      @timeline.clear()

      for item in @items
        @container.remove(item.container)
        item.destroy()
      @items = []

    build: (time = 0) ->
      @rng = new RNG(@values.seed)
      @rngAnimation = new RNG(@values.seed + "lorem")
      @rngOutline = new RNG(@values.seed)

      for i in [0..@values.numItems - 1]
        color = Colors.get(@rng.random(0, 1000))
        fillColor = color.clone().multiplyScalar(@rng.random(0.3, 0.5))
        rndtype = @rng.random(0, 1000) / 1000
        size = @rng.random(@values.circleRadius, @values.circleRadiusMax)
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
          y: y,
          z: 0
        })
        @container.add(item.container)
        @timeline.add(item.timeline, 0)
        @items.push(item)

      @totalDuration = @timeline.duration()

      # Set initial properties
      @update(time, @values, true)

    valueChanged: (key, values) ->
      # Value can't change if it is not even set.
      if !values[key]? then return false
      new_val = values[key]
      has_changed = true
      if @cache[key]? && @cache[key] == new_val then has_changed = false

      # Directly set the new cache value to avoid setting it multiple time to true.
      @cache[key] = new_val
      return has_changed

    update: (seconds, values = false, force = false) ->
      if values == false then values = @values
      needs_rebuild = false

      # Check if any of the invaldating property changed.
      for key, prop of Circles.properties
        if prop.triggerRebuild && @valueChanged(key, values)
          needs_rebuild = true

      if force || @valueChanged("x", values) || @valueChanged("y", values) || @valueChanged("z", values)
        @container.position.set(values.x, values.y, values.z)

      if force || @valueChanged("progression", values)
        progression = values.progression / 2
        @timeline.seek(@totalDuration * progression)
        for item in @items
          item.update(seconds, values.progression)

      if needs_rebuild == true
        @rebuild(seconds)

    getRandomPosition: () ->
      return @rng.random(-@values.radius, @values.radius)

    destroy: () ->
      # clean up...
      if @container
        if @container.parent then @container.parent.remove(@container)
        delete @container
      delete @rng
      delete @rngOutline
      delete @cache
