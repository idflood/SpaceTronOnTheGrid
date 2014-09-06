define (require) ->
  THREE = require 'threejs'

  require 'vendors/three.js-extras/postprocessing/EffectComposer'
  require 'vendors/three.js-extras/postprocessing/MaskPass'
  require 'vendors/three.js-extras/postprocessing/BloomPass'
  require 'vendors/three.js-extras/postprocessing/ShaderPass'
  require 'vendors/three.js-extras/postprocessing/RenderPass'
  require 'vendors/three.js-extras/postprocessing/FilmPass'
  require 'app/postprocessing/GlitchPass2'

  require 'vendors/three.js-extras/shaders/CopyShader'
  require 'vendors/three.js-extras/shaders/FXAAShader'
  require 'vendors/three.js-extras/shaders/FilmShader'
  require 'vendors/three.js-extras/shaders/ConvolutionShader'
  require 'vendors/three.js-extras/shaders/VignetteShader'
  require 'vendors/three.js-extras/shaders/DigitalGlitch'

  class PostFX
    constructor: (@scene, @camera, @renderer) ->
      @renderer.autoClear = false

      renderModel = new THREE.RenderPass( @scene, @camera )
      # There will only be 1 rendermodel and we need to be able
      # to swith camera from the orchestrator.
      window.renderModel = renderModel
      @effectFXAA = new THREE.ShaderPass( THREE.FXAAShader )
      @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / window.innerWidth, 1 / window.innerHeight )

      @bloom = new THREE.BloomPass(0.9, 25, 4)

      @glitchPass = new THREE.GlitchPass2()
      @glitchPass.intensity = 0.3;

      @vignettePass = new THREE.ShaderPass(THREE.VignetteShader)
      @vignettePass.uniforms['darkness'].value = 2

      @filmShader = new THREE.FilmPass( 0.34, 0.01, 648, false )
      @filmShader.renderToScreen = true

      @composer = new THREE.EffectComposer( @renderer )
      @composer.addPass( renderModel )
      @composer.addPass( @effectFXAA )
      @composer.addPass( @bloom )
      #@composer.addPass( @glitchPass )
      @composer.addPass( @vignettePass )
      @composer.addPass( @filmShader )

    resize: (SCREEN_WIDTH, SCREEN_HEIGHT) ->
      @composer.setSize( SCREEN_WIDTH, SCREEN_HEIGHT )
      @effectFXAA.uniforms[ 'resolution' ].value.set( 1 / SCREEN_WIDTH, 1 / SCREEN_HEIGHT )

    render: (delta) ->
      @renderer.clear()
      @composer.render(delta)
