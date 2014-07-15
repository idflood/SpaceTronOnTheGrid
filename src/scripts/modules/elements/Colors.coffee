define (require) ->
  THREE = require 'threejs'

  items = [
    new THREE.Color(0x567c6d),
    new THREE.Color(0xe2cb7b),
    new THREE.Color(0xcbad7b),
    new THREE.Color(0xaf1925),
    new THREE.Color(0xddb3b4),
    new THREE.Color(0x715160),
    new THREE.Color(0x406872),
  ]

  length = items.length

  class Colors
    @get = (index) ->
      index = Math.abs(parseInt(index, 10))
      return items[index % length]

