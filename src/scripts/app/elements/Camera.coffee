define (require) ->
  THREE = require 'threejs'

  class Camera
    @properties:
      x: {name: 'x', label: 'x', val: 0}
      y: {name: 'y', label: 'y', val: 0}
      z: {name: 'z', label: 'z', val: 0}

    constructor: (@values = {}, time = 0) ->
      @isCamera = true
      @container = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 2000 )
      @container.position.set(@values.x, @values.y, @values.z)

    update: (seconds, values = false, force = false) ->
      @container.position.set(values.x, values.y, values.z)

    destroy: () ->
      delete @container
      delete @isCamera
