define (require) ->
  THREE = require 'threejs'

  class Background
    constructor: (@scene) ->
      backgroundTexture = THREE.ImageUtils.loadTexture('src/images/background.jpg')
      bgMat = new THREE.MeshBasicMaterial({map: backgroundTexture})
      bg = new THREE.Mesh(new THREE.PlaneGeometry(1600, 1600, 0), bgMat)
      bg.material.depthTest = false
      bg.material.depthWrite = false
      bg.position.set(0, 0, -10)
      @scene.add(bg)
