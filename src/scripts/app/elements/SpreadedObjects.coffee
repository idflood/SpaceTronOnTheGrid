define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'
  RNG = require 'rng'
  TimelineMax = require 'TimelineMax'

  Colors = require 'cs!app/components/Colors'

  class SpreadedObjects
    @properties:
      numItems: {name: 'numItems', label: 'num items', val: 20, triggerRebuild: true}
      seed: {name: 'seed', label: 'seed', val: 12002, triggerRebuild: true}
      randX: {name: 'randX', label: 'random x', val: 80, triggerRebuild: true}
      randY: {name: 'randY', label: 'random y', val: 80, triggerRebuild: true}
      randZ: {name: 'randZ', label: 'random z', val: 0, triggerRebuild: true}
      circleRadius: {name: 'circleRadius', label: 'circle radius', val: 20}
      circleRadiusMax: {name: 'circleRadiusMax', label: 'circle radius max', val: 20}
      progression: {name: 'progression', label: 'progression', val: 1}
      depth: {name: 'depth', label: 'depth', val: 0}
      percent_color: {name: 'percent_color', label: 'percent color', val: 0.4, triggerRebuild: true}
      x: {name: 'x', label: 'x', val: 0}
      y: {name: 'y', label: 'y', val: 0}
      z: {name: 'z', label: 'z', val: 0}
      rotX: {name: 'rotX', label: 'rotation x', val: 0}
      rotY: {name: 'rotY', label: 'rotation y', val: 0}
      rotZ: {name: 'rotZ', label: 'rotation z', val: 0}

    constructor: (@values = {}, time = 0) ->
      # Set the default value of instance properties.
      # Should not happen when created with the orchestrator (so never really...)
      #for key, prop of SpreadedObjects.properties
      #  if !@values[key]?
      #    @values[key] = prop.val

      @timeline = new TimelineMax()
      @container = new THREE.Object3D()
      @totalDuration = 0
      @items = []
      @items_position = []
      @cache = @buildCache()
      @build(time)

    getItemClass: () -> return AnimatedCircle

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
      @items_position = []

      for item in @items
        @container.remove(item.container)
        item.destroy()
      @items = []

    build: (time = 0) ->
      @rng = new RNG(@values.seed)
      @rngAnimation = new RNG(@values.seed + "lorem")
      @rngOutline = new RNG(@values.seed)

      for i in [0..@values.numItems - 1]
        itemClass = @getItemClass()
        rndtype = @rng.random(0, 1000) / 1000
        draw_outline = if rndtype < 0.8 then true else false
        draw_circle = if rndtype > 0.5 then true else false

        if itemClass.noOutline
          draw_outline = false
          draw_circle = true

        color = Colors.get(@rng.random(0, 1000))
        if @rng.random(0, 1000) > @values.percent_color * 1000
          color = Colors.get(0)

        fillColor = color.clone()
        if draw_outline
          fillColor.multiplyScalar(@rng.random(0.1, 0.5))

        size = @rng.random(@values.circleRadius, @values.circleRadiusMax)
        x = @getRandomPosition(@values.randX)
        y = @getRandomPosition(@values.randY)
        z = @getRandomPosition(@values.randZ)
        pos = {x: x, y: y, z: z}

        delay = @rngAnimation.random(0, 2400) / 1000
        duration = @rngAnimation.random(600, 800) / 1000
        duration *= 4
        border_radius = @rngOutline.random(1, 400) / 100


        if draw_outline == false
          # more fill opacity if no outline
          fillColor.multiplyScalar(3)

        item = new itemClass({
          size: size,
          outlineWidth: border_radius,
          drawOutline: draw_outline,
          drawCircle: draw_circle,
          color: color,
          fillColor: fillColor,
          delay: delay,
          duration: duration,
          depth: @values.depth,
          x: pos.x,
          y: pos.y,
          z: pos.z
        })
        @container.add(item.container)
        @timeline.add(item.timeline, 0)
        @items.push(item)
        @items_position.push(pos)

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

    degreeToRadian: (degree) -> Math.PI * degree / 180

    update: (seconds, values = false, force = false) ->
      if values == false then values = @values
      needs_rebuild = false

      # Check if any of the invaldating property changed.
      for key, prop of SpreadedObjects.properties
        if prop.triggerRebuild && @valueChanged(key, values)
          needs_rebuild = true

      if force || @valueChanged("x", values) || @valueChanged("y", values) || @valueChanged("z", values)
        @container.position.set(values.x, values.y, values.z)

      if force || @valueChanged("rotX", values) || @valueChanged("rotY", values) || @valueChanged("rotZ", values)
        @container.rotation.set(@degreeToRadian(values.rotX), @degreeToRadian(values.rotY), @degreeToRadian(values.rotZ))

      #if force || @valueChanged("progression", values)
      progression = values.progression / 2
      @timeline.seek(@totalDuration * progression)
      for item in @items
        item.update(seconds, {progression: values.progression})

      if force || @valueChanged("depth", values)
        for item, key in @items
          pos = @items_position[key]
          item.container.position.set(pos.x, pos.y, pos.z * values.depth)

      # save the new values
      @values = _.merge(@values, values)

      if needs_rebuild == true
        @rebuild(seconds)

    getRandomPosition: (scale = 1) ->
      return @rng.random(-scale, scale)

    destroy: () ->
      # clean up...
      if @container
        if @container.parent then @container.parent.remove(@container)
        delete @container
      delete @rng
      delete @rngOutline
      delete @cache
