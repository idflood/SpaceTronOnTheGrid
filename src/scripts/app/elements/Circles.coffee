define (require) ->
  THREE = require 'threejs'

  RNG = require 'rng'

  Colors = require 'cs!app/components/Colors'

  class Circles
    constructor: (@scene, @numItems, @seed, @radius = 80, @circleRadius = 20, @circleRadiusMax= 30) ->
      @rng = new RNG(@seed)
      @rngOutline = new RNG(@seed)
      @object = new THREE.Object3D()

      @blackMaterial = new THREE.MeshBasicMaterial({color: 0x7ed2f1, transparent: true, depthWrite: false, depthTest: false})
      @blackMaterial.blending = THREE.AdditiveBlending

      for i in [0..@numItems]
        @createCircle()

      @scene.add(@object)

    getRandomPosition: () ->
      return @rng.random(-@radius, @radius)
      #x = @rng.exponential() * @radius
      #if @rng.random(-1, 1) < 0 then x *= -1
      #return x

    createCircle: () ->
      color = Colors.get(@rng.random(0, 1000))
      color.multiplyScalar(@rng.random(0.5, 1))
      material = new THREE.MeshBasicMaterial({color: color, transparent: true, depthWrite: false, depthTest: false})
      material.blending = THREE.AdditiveBlending

      size = @rng.random(@circleRadius, @circleRadiusMax)
      x = @getRandomPosition()
      y = @getRandomPosition()

      numSegments = parseInt(size / 1.5, 10) + 4
      object = new THREE.Mesh( new THREE.CircleGeometry( size, numSegments, 0, Math.PI * 2 ), material )
      #object = new THREE.Mesh( new THREE.BoxGeometry(30, 30, 30 , 2, 2, 2), material )
      object.position.set( x, y, 0 )
      #object.rotation.set(Math.PI / -2, 0, 0)
      @object.add( object )

      if size > 4 && @rngOutline.exponential() > 1.2
        @drawOutline(x, y, size)

    drawOutline: (x, y, size) ->
      borderRadius = @rngOutline.exponential()
      object = new THREE.Mesh( new THREE.RingGeometry( size - 1, size + borderRadius, 50, 1, 0, Math.PI * 2 ), @blackMaterial )
      object.position.set( x, y, 0 )
      @object.add( object )
