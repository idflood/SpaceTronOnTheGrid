define (require) ->
  THREE = require 'threejs'

  require 'vendors/three.js-extras/postprocessing/EffectComposer'
  require 'vendors/three.js-extras/postprocessing/MaskPass'
  require 'vendors/three.js-extras/postprocessing/ShaderPass'
  require 'vendors/three.js-extras/postprocessing/RenderPass'
  require 'vendors/three.js-extras/postprocessing/FilmPass'

  require 'vendors/three.js-extras/shaders/CopyShader'
  require 'vendors/three.js-extras/shaders/FXAAShader'
  require 'vendors/three.js-extras/shaders/FilmShader'

  class PostFX
    constructor: (@scene, @camera, @renderer) ->
      @renderer.autoClear = false

      renderModel = new THREE.RenderPass( @scene, @camera )
      @effectFXAA = new THREE.ShaderPass( THREE.FXAAShader )
      @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / window.innerWidth, 1 / window.innerHeight )

      @filmShader = new THREE.FilmPass( 0.07, 0.0, 648, false )
      @filmShader.renderToScreen = true

      @composer = new THREE.EffectComposer( @renderer )
      @composer.addPass( renderModel )
      @composer.addPass( @effectFXAA )
      @composer.addPass( @filmShader )

    resize: (SCREEN_WIDTH, SCREEN_HEIGHT) ->
      @composer.setSize( SCREEN_WIDTH, SCREEN_HEIGHT )
      @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / SCREEN_WIDTH, 1 / SCREEN_HEIGHT )

    render: (delta) ->
      @renderer.clear()
      @composer.render(delta)
