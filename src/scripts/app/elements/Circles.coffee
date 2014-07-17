define (require) ->
  THREE = require 'threejs'

  RNG = require 'rng'

  Colors = require 'cs!app/components/Colors'

  class Circles
    constructor: (options = {}) ->
      @numItems = options.numItems || 10
      @seed = options.seed || 12001
      @radius = options.radius || 80
      @circleRadius = options.circleRadius || 20
      @circleRadiusMax = options.circleRadiusMax || 30

      @rng = new RNG(@seed)
      @rngOutline = new RNG(@seed)
      @container = new THREE.Object3D()

      #@blackMaterial = new THREE.MeshBasicMaterial({color: 0x7ed2f1, transparent: true, depthWrite: false, depthTest: false})
      #@blackMaterial.blending = THREE.AdditiveBlending

      for i in [0..@numItems]
        color = Colors.get(@rng.random(0, 1000))
        rndtype = @rng.random(0, 1000) / 1000
        size = @rng.random(@circleRadius, @circleRadiusMax)
        x = @getRandomPosition()
        y = @getRandomPosition()

        if rndtype < 0.8
          @drawOutline(x, y, size, color)
        if rndtype > 0.5
          @createCircle(x, y, size, color)

    update: (seconds, values) ->
      # todo.

    getRandomPosition: () ->
      return @rng.random(-@radius, @radius)
      #x = @rng.exponential() * @radius
      #if @rng.random(-1, 1) < 0 then x *= -1
      #return x

    createCircle: (x, y, size, color) =>
      color = color.clone().multiplyScalar(@rng.random(0.3, 0.5))
      material = new THREE.MeshBasicMaterial({color: color, transparent: true, depthWrite: false, depthTest: false})
      material.blending = THREE.AdditiveBlending

      numSegments = parseInt(size / 1.5, 10) + 4
      object = new THREE.Mesh( new THREE.CircleGeometry( size, numSegments, 0, Math.PI * 2 ), material )
      #object = new THREE.Mesh( new THREE.BoxGeometry(30, 30, 30 , 2, 2, 2), material )
      object.position.set( x, y, 0 )
      #object.rotation.set(Math.PI / -2, 0, 0)
      @container.add( object )

    drawOutline: (x, y, size, color) =>
      borderRadius = @rngOutline.exponential()
      material = new THREE.MeshBasicMaterial({color: color, transparent: true, depthWrite: false, depthTest: false})
      material.blending = THREE.AdditiveBlending
      object = new THREE.Mesh( new THREE.RingGeometry( size - 1, size + borderRadius, 50, 1, 0, Math.PI * 2 ), material )
      object.position.set(x, y, 0 )
      @container.add( object )

    destroy: () ->
      # clean up...
      if @container
        if @container.parent then @container.parent.remove(@container)
        delete @container
      delete @rng
      delete @rngOutline
      #delete @blackMaterial
