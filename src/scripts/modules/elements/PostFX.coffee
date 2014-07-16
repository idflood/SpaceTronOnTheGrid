define (require) ->
  THREE = require 'threejs'

  require 'vendors/three.js-extras/postprocessing/EffectComposer'
  require 'vendors/three.js-extras/postprocessing/MaskPass'
  require 'vendors/three.js-extras/postprocessing/BloomPass'
  require 'vendors/three.js-extras/postprocessing/ShaderPass'
  require 'vendors/three.js-extras/postprocessing/RenderPass'
  require 'vendors/three.js-extras/postprocessing/FilmPass'

  require 'vendors/three.js-extras/shaders/CopyShader'
  require 'vendors/three.js-extras/shaders/FXAAShader'
  require 'vendors/three.js-extras/shaders/FilmShader'
  require 'vendors/three.js-extras/shaders/ConvolutionShader'

  class PostFX
    constructor: (@scene, @camera, @renderer) ->
      @renderer.autoClear = false

      renderModel = new THREE.RenderPass( @scene, @camera )
      @effectFXAA = new THREE.ShaderPass( THREE.FXAAShader )
      @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / window.innerWidth, 1 / window.innerHeight )

      @bloom = new THREE.BloomPass(1.2)

      @filmShader = new THREE.FilmPass( 0.09, 0.0, 648, false )
      @filmShader.renderToScreen = true

      @composer = new THREE.EffectComposer( @renderer )
      @composer.addPass( renderModel )
      @composer.addPass( @effectFXAA )
      @composer.addPass( @bloom )
      @composer.addPass( @filmShader )

    resize: (SCREEN_WIDTH, SCREEN_HEIGHT) ->
      @composer.setSize( SCREEN_WIDTH, SCREEN_HEIGHT )
      @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / SCREEN_WIDTH, 1 / SCREEN_HEIGHT )

    render: (delta) ->
      @renderer.clear()
      @composer.render(delta)
