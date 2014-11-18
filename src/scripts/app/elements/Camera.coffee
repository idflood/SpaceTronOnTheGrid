define (require) ->
  THREE = require 'threejs'

  class Camera
    @properties:
      x: {name: 'x', label: 'x', val: 0}
      y: {name: 'y', label: 'y', val: 0}
      z: {name: 'z', label: 'z', val: 700}
      target_x: {name: 'target_x', label: 'target x', val: 0}
      target_y: {name: 'target_y', label: 'target y', val: 0}
      target_z: {name: 'target_z', label: 'target z', val: 0}
      fov: {name: 'fov', label: 'fov', val: 45}

    constructor: (@values = {}, time = 0) ->
      @isCamera = true
      @target = new THREE.Vector3(@values.target_x, @values.target_y, @values.target_z)
      @container = new THREE.PerspectiveCamera( @values.fov, window.innerWidth / window.innerHeight, 1, 2000 )
      @container.position.set(@values.x, @values.y, @values.z)

    update: (seconds, values = false, force = false) ->
      if values.fov? then @container.fov = values.fov
      @container.position.set(values.x, values.y, values.z)
      @target.set(values.target_x, values.target_y, values.target_z)
      @container.lookAt( @target )

    destroy: () ->
      delete @container
      delete @isCamera
