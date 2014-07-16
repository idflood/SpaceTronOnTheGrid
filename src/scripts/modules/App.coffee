# green: 567c6d
# yellow: e2cb7b
# brownish: cbad7b
# red: af1925
# pink: ddb3b4
# purple: 715160
# blue: 406872

define (require) ->
  THREE = require 'threejs'

  Background = require 'cs!modules/elements/Background'
  PostFX = require 'cs!modules/elements/PostFX'

  Circles = require 'cs!modules/elements/Circles'

  class App
    constructor: () ->
      @time = Date.now() * 0.0001
      container = document.createElement( 'div' )
      document.body.appendChild( container )

      @scene = new THREE.Scene()

      @camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 2000 )
      @camera.position.z = 600

      @renderer = new THREE.WebGLRenderer( { antialias: false, alpha: false } )
      @renderer.setSize( window.innerWidth, window.innerHeight )

      #@renderer.setClearColor( 0xe1d8c7, 1)
      @renderer.setClearColor( 0x000000, 1)

      circles = new Circles(@scene, 10, 4323, 130, 20, 50)
      circles2 = new Circles(@scene, 20, 51232, 180, 4, 10)

      #@createElements()

      container.appendChild( @renderer.domElement )

      window.addEventListener('resize', @onWindowResize, false)

      @postfx = new PostFX(@scene, @camera, @renderer)
      #new Background(@scene)

      @animate()

    createElements: () ->
      material = new THREE.MeshBasicMaterial({color: 0xebddc8, transparent: true, depthWrite: false, depthTest: false})
      material.blending = THREE.AdditiveBlending

      object = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 50, 1, 1 ), material )
      object.position.set( 20, 0, 350 )
      object.rotation.set(0, 0.8, 0.7)
      @scene.add( object )

      material2 = new THREE.MeshBasicMaterial({color: 0x6f9787, transparent: true, depthWrite: false, depthTest: false})
      material2.blending = THREE.AdditiveBlending

      object = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 50, 1, 1 ), material2 )
      object.position.set( 20, 40, 350 )
      object.rotation.set(0, -1, -0.6)
      @scene.add( object )

    __createElementsBackup: () ->
      #material = new THREE.MeshBasicMaterial( { color: 0xffffff, side: THREE.DoubleSide } )
      #material = new THREE.MeshBasicMaterial({color: 0xaf1925, transparent: true})
      material = new THREE.MeshBasicMaterial({color: 0xd7888e, transparent: true})
      material.blending = THREE.MultiplyBlending

      materialBlack = new THREE.MeshBasicMaterial({color: 0x222222, transparent: true, wireframe: false})
      materialBlack.blending = THREE.MultiplyBlending

      material2 = new THREE.MeshBasicMaterial({color: 0x406872, transparent: true})
      material2.blending = THREE.MultiplyBlending

      object = new THREE.Mesh( new THREE.CircleGeometry( 50, 50, 0, Math.PI * 2 ), material )
      #object = new THREE.Mesh( new THREE.BoxGeometry(30, 30, 30 , 2, 2, 2), material )
      object.position.set( 20, 0, 0 )
      #object.rotation.set(Math.PI / -2, 0, 0)
      @scene.add( object )

      object = new THREE.Mesh( new THREE.RingGeometry( 43, 50, 50, 1, 0, Math.PI * 2 ), materialBlack )
      #object = new THREE.Mesh( new THREE.BoxGeometry(30, 30, 30 , 2, 2, 2), material )
      object.position.set( 20, 0, 0 )
      #object.rotation.set(Math.PI / -2, 0, 0)
      @scene.add( object )



      #object = new THREE.Mesh( new THREE.SphereGeometry( 75, 20, 10 ), material );
      #object = new THREE.Mesh( new THREE.PlaneGeometry( 100, 100, 2, 2 ), material2 );
      object = new THREE.Mesh( new THREE.RingGeometry( 40, 50, 4, 1, 0, Math.PI * 2 ), material2 );
      object.position.set( -20, 0, 0 );
      object.rotation.set(0, 0, Math.PI / 4)
      @scene.add( object )

    onWindowResize: () =>
      SCREEN_WIDTH = window.innerWidth
      SCREEN_HEIGHT = window.innerHeight
      @camera.aspect = SCREEN_WIDTH / SCREEN_HEIGHT
      @camera.updateProjectionMatrix()

      @renderer.setSize( SCREEN_WIDTH, SCREEN_HEIGHT )
      @postfx.resize(SCREEN_WIDTH, SCREEN_HEIGHT)

    animate: () =>
      requestAnimationFrame(@animate)
      @render()

    render: () ->
      newTime = Date.now() * 0.0001
      delta = newTime - @time

      @camera.lookAt( @scene.position )
      @postfx.render(delta)

      @time = newTime

