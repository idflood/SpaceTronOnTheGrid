define (require) ->
  THREE = require 'threejs'

  items = [
    new THREE.Color(0xc0ddde),
    #new THREE.Color(0xf1c47e),
  ]

  length = items.length

  class Colors
    @get = (index) ->
      index = Math.abs(parseInt(index, 10))
      return items[index % length]

