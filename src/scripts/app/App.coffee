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

  Shaders = require 'app/components/Shaders'
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
    constructor: (options = {}) ->
      window.updateCameraAspect = @updateCameraAspect

      @autoplay = false
      if options.autoplay?
        @autoplay = options.autoplay

      @shaders = new Shaders()

      audio_url = './assets/08 - Space Tron On The Grid.mp3'
      @audio = new Audio(audio_url, @onAudioLoaded)
      @factory = new ElementFactory()

      # Convert loaded data
      conf = JSON.parse(dataJson)
      @settings = conf.settings
      @data = DataNormalizer.normalizeData(conf.data, @factory)

      @tweenTime = new TweenTime(@data)
      @tweenTime.timer.statusChanged.add(@onTimerStatusChanged)
      @tweenTime.timer.seeked.add(@onTimerSeeked)

      if options.time?
        @tweenTime.timer.seek([options.time])
      else if @settings.time
        @tweenTime.timer.seek([@settings.time])

      size = @getScreenSize()
      @camera = new THREE.PerspectiveCamera( 45, size.width / size.height, 1, 2000 )
      @camera.position.z = 600
      window.activeCamera = @camera

      @scene = new THREE.Scene()
      @scene.fog = new THREE.FogExp2( 0x111111, 0.0045 )
      #@orchestrator = new Orchestrator(@timer, @data, @scene, @camera)
      @sceneManager = new SceneManager(@tweenTime, @data, @scene, @camera, @factory)

      @time = Date.now() * 0.0001
      $container = $('<div class="experiment"></div>')
      container = $container.get(0)
      @containerWebgl = container # Save for use in EditorUI for object picking.
      $('body').append($container)

      @renderer = new THREE.WebGLRenderer( { antialias: false, alpha: false } )
      @renderer.setPixelRatio( window.devicePixelRatio )
      @renderer.setSize(size.width, size.height)

      @renderer.setClearColor( 0x111111, 1)

      light1 = new THREE.DirectionalLight( 0xffffff, 0.4 )
      light1.position.set(100, 300, 700)
      @scene.add(light1)

      container.appendChild( @renderer.domElement )

      window.addEventListener('resize', @onWindowResize, false)

      @postfx = new PostFX(@scene, @camera, @renderer, size)

      @onWindowResize()
      @animate()

    onTimerStatusChanged: (is_playing) =>
      if is_playing
        @audio.play()
      else
        @audio.pause()

    onTimerSeeked: (time) =>
      @audio.seek(time / 1000)

    play: () =>
      @tweenTime.timer.play()
      $('body').addClass('is-playing')

    onAudioLoaded: () =>
      console.log "audio loaded"
      $('body').addClass('is-audio-loaded')
      if @autoplay
        @play()


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
      @shaders.update()
      @render()

    render: () ->
      newTime = Date.now() * 0.0001
      delta = newTime - @time

      if @particles then @particles.update()
      if @chaos then @chaos.update()
      @camera.lookAt( @scene.position )
      @postfx.render(delta)

      @time = newTime
