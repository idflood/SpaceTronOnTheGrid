# green: 567c6d
# yellow: e2cb7b
# brownish: cbad7b
# red: af1925
# pink: ddb3b4
# purple: 715160
# blue: 406872


define (require) ->
  THREE = require 'Three'

  TweenTime = require 'TweenTime'

  Background = require 'app/components/Background'
  PostFX = require 'app/components/PostFX'
  SceneManager = require 'app/components/SceneManager'
  Audio = require 'app/components/Audio'
  ElementFactory = require 'app/components/ElementFactory'
  DataNormalizer = require 'app/components/DataNormalizer'

  dataJson = require 'raw!app/data.json'

  #Circles = require 'app/elements/Circles'

  Particles = require 'app/elements/Particles'
  OrganizedChaos = require 'app/elements/OrganizedChaos'

  window.App = class App
    constructor: () ->
      window.updateCameraAspect = @updateCameraAspect

      audio_url = './assets/08 - Space Tron On The Grid.mp3'
      @audio = new Audio(audio_url, @onAudioLoaded)
      @factory = new ElementFactory()

      # Convert loaded data
      conf = JSON.parse(dataJson)
      console.log conf
      @settings = conf.settings
      @data = DataNormalizer.normalizeData(conf.data, @factory)

      @tweenTime = new TweenTime(@data)
      @tweenTime.timer.statusChanged.add(@onTimerStatusChanged)
      @tweenTime.timer.seeked.add(@onTimerSeeked)

      size = @getScreenSize()
      @camera = new THREE.PerspectiveCamera( 45, size.width / size.height, 1, 2000 )
      @camera.position.z = 600
      window.activeCamera = @camera

      @scene = new THREE.Scene()
      @scene.fog = new THREE.FogExp2( 0x111111, 0.0025 )
      #@orchestrator = new Orchestrator(@timer, @data, @scene, @camera)
      @sceneManager = new SceneManager(@tweenTime, @data, @scene, @camera, @factory)

      @time = Date.now() * 0.0001
      container = document.createElement( 'div' )
      @containerWebgl = container # Save for use in EditorUI for object picking.
      document.body.appendChild( container )

      @renderer = new THREE.WebGLRenderer( { antialias: true, alpha: false } )
      @renderer.setPixelRatio( window.devicePixelRatio )
      @renderer.setSize(size.width, size.height)

      #@renderer.setClearColor( 0xe1d8c7, 1)
      @renderer.setClearColor( 0x111111, 1)

      #circles = new Circles(@scene, 10, 4323, 130, 20, 50)
      #circles2 = new Circles(@scene, 20, 51232, 180, 4, 10)

      light1 = new THREE.PointLight( 0xffffff, 3, 1400 )
      light1.position.set(100, 300, 700)
      @scene.add(light1)

      #@createElements()

      container.appendChild( @renderer.domElement )

      window.addEventListener('resize', @onWindowResize, false)

      @postfx = new PostFX(@scene, @camera, @renderer, size)
      #new Background(@scene)

      #@particles = new Particles()
      #@scene.add(@particles.container)

      @chaos = new OrganizedChaos()
      @chaos.container.position.z = 300
      @scene.add(@chaos.container)

      @animate()

    onTimerStatusChanged: (is_playing) =>
      if is_playing
        @audio.play()
      else
        @audio.pause()

    onTimerSeeked: (time) =>
      @audio.seek(time / 1000)

    onAudioLoaded: () =>
      console.log "audio loaded"
      $('body').addClass('is-audio-loaded')

    createElements: () ->
      material = new THREE.MeshPhongMaterial({color: 0x111111, specular: 0x666666, shininess: 30, shading: THREE.SmoothShading})
      #material.blending = THREE.AdditiveBlending

      object = new THREE.Mesh( new THREE.PlaneBufferGeometry( 2000, 650, 1, 1 ), material )
      object.position.set( 420, 0, -350 )
      object.rotation.set(0.1, 0.8, 0.7)
      @scene.add( object )

      object2 = new THREE.Mesh( new THREE.PlaneBufferGeometry( 2000, 650, 1, 1 ), material )
      object2.position.set( 320, 0, -450 )
      object2.rotation.set(0.17, 0.85, 0.78)
      @scene.add( object2 )

      object3 = new THREE.Mesh( new THREE.PlaneBufferGeometry( 2000, 650, 1, 1 ), material )
      object3.position.set( -120, -600, -950 )
      object3.rotation.set(0.17, 0.35, -0.38)
      @scene.add( object3 )


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

      if @particles then @particles.update()
      if @chaos then @chaos.update()
      @camera.lookAt( @scene.position )
      @postfx.render(delta)

      @time = newTime
