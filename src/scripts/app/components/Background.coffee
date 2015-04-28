define (require) ->
  THREE = require 'Three'

  class Background
    constructor: (@scene) ->
      texture = THREE.ImageUtils.loadTexture('src/images/background.jpg')
      texture.wrapS = texture.wrapT = THREE.RepeatWrapping
      texture.repeat.set( 2, 2 )
      bgMat = new THREE.MeshBasicMaterial({map: texture})
      bg = new THREE.Mesh(new THREE.PlaneGeometry(1600, 1600, 4, 4), bgMat)
      bg.material.depthTest = false
      bg.material.depthWrite = false
      bg.position.set(0, 0, -10)
      @scene.add(bg)
