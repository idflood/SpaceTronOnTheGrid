# green: 567c6d
# yellow: e2cb7b
# brownish: cbad7b
# red: af1925
# pink: ddb3b4
# purple: 715160
# blue: 406872

define (require) ->
  THREE = require 'threejs'

  Background = require 'cs!app/components/Background'
  PostFX = require 'cs!app/components/PostFX'
  Timer = require 'cs!app/components/Timer'
  Orchestrator = require 'cs!app/components/Orchestrator'
  SceneManager = require 'cs!app/components/SceneManager'
  Audio = require 'cs!app/components/Audio'

  dataJson = require 'text!app/data.json'

  #Circles = require 'cs!app/elements/Circles'


  class App
    constructor: () ->
      # Make the app accessible for the editor.
      window.app = this
      window.updateCameraAspect = @updateCameraAspect
      @timer = new Timer()
      audio_url = 'http://localhost/SpaceTronOnTheGrid CB2.mp3'
      @audio = new Audio(audio_url, @onAudioLoaded)

      @dataSample = [
        {
          id: 'item1',
          label: 'Test circles',
          type: 'Circles'
          start: 1, end: 10,
          options: {numItems: 12, seed: 12002, radius: 84},
          properties: [
            {name: 'progression', keys: [{time: 2, val: 7}, {time: 3, val: 42}, {time: 5, val: -40}]}
          ]

        }
      ]

      # Convert loaded data
      @data = JSON.parse(dataJson)
      #@data = []

      size = @getScreenSize()
      @camera = new THREE.PerspectiveCamera( 45, size.width / size.height, 1, 2000 )
      @camera.position.z = 600
      window.activeCamera = @camera

      @scene = new THREE.Scene()
      @orchestrator = new Orchestrator(@timer, @data, @scene, @camera)
      @sceneManager = new SceneManager(@timer, @data, @scene, @camera)

      @time = Date.now() * 0.0001
      container = document.createElement( 'div' )
      document.body.appendChild( container )

      @renderer = new THREE.WebGLRenderer( { antialias: false, alpha: false } )
      @renderer.setSize(size.width, size.height)

      #@renderer.setClearColor( 0xe1d8c7, 1)
      @renderer.setClearColor( 0x111111, 1)

      #circles = new Circles(@scene, 10, 4323, 130, 20, 50)
      #circles2 = new Circles(@scene, 20, 51232, 180, 4, 10)

      @createElements()

      container.appendChild( @renderer.domElement )

      window.addEventListener('resize', @onWindowResize, false)

      @postfx = new PostFX(@scene, @camera, @renderer, size)
      #new Background(@scene)

      @animate()

    onAudioLoaded: () =>
      console.log "audio loaded"
      $('body').addClass('is-audio-loaded')

    createElements: () ->
      material = new THREE.MeshPhongMaterial({color: 0x111111, specular: 0x666666, shininess: 30, shading: THREE.SmoothShading})
      #material.blending = THREE.AdditiveBlending

      object = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 650, 1, 1 ), material )
      object.position.set( 420, 0, -350 )
      object.rotation.set(0.1, 0.8, 0.7)
      @scene.add( object )

      object2 = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 650, 1, 1 ), material )
      object2.position.set( 320, 0, -450 )
      object2.rotation.set(0.17, 0.85, 0.78)
      @scene.add( object2 )

      object3 = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 650, 1, 1 ), material )
      object3.position.set( -120, -600, -950 )
      object3.rotation.set(0.17, 0.35, -0.38)
      @scene.add( object3 )

      light1 = new THREE.PointLight( 0xffffff, 3, 1400 )
      light1.position.set(100, 100, 200)
      @scene.add(light1)


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

    getScreenSize: () ->
      SCREEN_WIDTH = window.innerWidth
      SCREEN_HEIGHT = window.innerHeight
      if window.editorEnabled
        timelineheight = 295
        if $('body').hasClass('timeline-is-closed') then timelineheight = 95
        propertieswidth = 279
        if $('body').hasClass('properties-is-closed') then propertieswidth = 0
        SCREEN_HEIGHT -= timelineheight
        SCREEN_WIDTH -= propertieswidth

      #console.log {width: SCREEN_WIDTH, height: SCREEN_HEIGHT}
      return {width: SCREEN_WIDTH, height: SCREEN_HEIGHT}

    updateCameraAspect: (camera, size = false) =>
      if size == false
        size = @getScreenSize()
      camera.aspect = size.width / size.height
      camera.updateProjectionMatrix()

    onWindowResize: () =>
      size = @getScreenSize()

      @updateCameraAspect(@camera, size)
      @updateCameraAspect(window.activeCamera, size)

      @renderer.setSize(size.width, size.height)
      @postfx.resize(size.width, size.height)

    animate: () =>
      requestAnimationFrame(@animate)
      @audio.update()
      @render()

    render: () ->
      newTime = Date.now() * 0.0001
      delta = newTime - @time

      @camera.lookAt( @scene.position )
      @postfx.render(delta)

      @time = newTime
