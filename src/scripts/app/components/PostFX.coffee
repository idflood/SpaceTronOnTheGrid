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
  require 'app/shaders/DigitalGlitch2'

  class PostFX
    constructor: (@scene, @camera, @renderer, size) ->
      @renderer.autoClear = false

      renderModel = new THREE.RenderPass( @scene, @camera )
      # There will only be 1 rendermodel and we need to be able
      # to swith camera from the orchestrator.
      window.renderModel = renderModel

      dpr = if window.devicePixelRatio? then window.devicePixelRatio else 1

      @renderTargetParameters = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat, stencilBufer: false }
      @renderTarget = new THREE.WebGLRenderTarget(size.width * dpr, size.height * dpr, @renderTargetParameters)

      @effectFXAA = new THREE.ShaderPass( THREE.FXAAShader )
      @effectFXAA.uniforms[ 'resolution' ].value.set(1 / (size.width * dpr), 1 / (size.height * dpr))

      @bloom = new THREE.BloomPass(0.6, 25, 4)

      @glitchPass = new THREE.GlitchPass2()
      @glitchPass.intensity = 0.3;
      @glitchPass.uniforms.tScratch.value = THREE.ImageUtils.loadTexture( "src/images/lensflare_dirt.jpg" )

      @vignettePass = new THREE.ShaderPass(THREE.VignetteShader)
      @vignettePass.uniforms['darkness'].value = 2

      @filmShader = new THREE.FilmPass( 0.34, 0.01, 648, false )
      @filmShader.renderToScreen = true

      @composer = new THREE.EffectComposer( @renderer, @renderTarget )
      @composer.setSize(size.width * dpr, size.height * dpr)
      @composer.addPass( renderModel )
      @composer.addPass( @effectFXAA )
      @composer.addPass( @bloom )
      #@composer.addPass( @glitchPass )
      @composer.addPass( @vignettePass )
      @composer.addPass( @filmShader )

    resize: (SCREEN_WIDTH, SCREEN_HEIGHT) ->
      dpr = if window.devicePixelRatio? then window.devicePixelRatio else 1
      #@composer.setSize(SCREEN_WIDTH * dpr, SCREEN_HEIGHT * dpr)
      @renderTarget = new THREE.WebGLRenderTarget(SCREEN_WIDTH * dpr, SCREEN_HEIGHT * dpr, @renderTargetParameters)
      @composer.reset(@renderTarget)
      @effectFXAA.uniforms[ 'resolution' ].value.set(1 / (SCREEN_WIDTH * dpr), 1 / (SCREEN_HEIGHT * dpr))

    render: (delta) ->
      @renderer.clear()
      @composer.render(delta)
