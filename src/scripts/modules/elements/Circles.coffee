define (require) ->
  THREE = require 'threejs'

  RNG = require 'rng'

  Colors = require 'cs!modules/elements/Colors'

  class Circles
    constructor: (@scene, @numItems, @seed, @radius = 70, @circleRadius = 30) ->
      @rng = new RNG(@seed)
      @rngOutline = new RNG(@seed)
      @object = new THREE.Object3D()

      @blackMaterial = new THREE.MeshBasicMaterial({color: 0x444444, transparent: true, depthWrite: false, depthTest: false})
      @blackMaterial.blending = THREE.MultiplyBlending

      for i in [0..@numItems]
        @createCircle()

      @scene.add(@object)

    createCircle: () ->
      color = Colors.get(@rng.random(0, 1000))
      color.addScalar(0.1)
      material = new THREE.MeshBasicMaterial({color: color, transparent: true, depthWrite: false, depthTest: false})
      material.blending = THREE.MultiplyBlending

      size = @rng.exponential() * @circleRadius
      x = @rng.exponential() * @radius
      if @rng.random(-1, 1) < 0 then x *= -1
      y = @rng.exponential() * @radius
      if @rng.random(-1, 1) < 0 then y *= -1

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
