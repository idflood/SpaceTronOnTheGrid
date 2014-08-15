define (require) ->
  THREE = require 'threejs'

  items = [
    new THREE.Color(0xffffff),
    new THREE.Color(0xffffff),
    new THREE.Color(0xffffff),
    new THREE.Color(0xffffff),
    new THREE.Color(0xfF777F),
    #new THREE.Color(0x9ACCEF),
  ]

  length = items.length

  class Colors
    @get = (index) ->
      index = Math.abs(parseInt(index, 10))
      return items[index % length]

