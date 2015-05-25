define (require) ->
  THREE = require 'Three'

  require 'vendors/three.js-extras/postprocessing/EffectComposer'
  require 'vendors/three.js-extras/postprocessing/MaskPass'
  require 'vendors/three.js-extras/postprocessing/BloomPass'
  require 'vendors/three.js-extras/postprocessing/ShaderPass'
  require 'vendors/three.js-extras/postprocessing/RenderPass'

  require 'app/postprocessing/CustomPostPass'

  require 'vendors/three.js-extras/shaders/CopyShader'
  require 'vendors/three.js-extras/shaders/ConvolutionShader'

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

      @bloom = new THREE.BloomPass(0.9, 25, 4)


      resolution = new THREE.Vector2(size.width * dpr, size.height * dpr)
      @customPass = new THREE.CustomPostPass(0.55, resolution)
      @customPass.renderToScreen = true

      @composer = new THREE.EffectComposer( @renderer, @renderTarget )
      @composer.setSize(size.width * dpr, size.height * dpr)
      @composer.addPass( renderModel )
      @composer.addPass( @bloom )
      @composer.addPass(@customPass)

    resize: (SCREEN_WIDTH, SCREEN_HEIGHT) ->
      dpr = if window.devicePixelRatio? then window.devicePixelRatio else 1
      @renderTarget = new THREE.WebGLRenderTarget(SCREEN_WIDTH * dpr, SCREEN_HEIGHT * dpr, @renderTargetParameters)
      @composer.reset(@renderTarget)
      @customPass.uniforms['resolution'].value.set(SCREEN_WIDTH * dpr, SCREEN_HEIGHT * dpr)

    render: (delta) ->
      @renderer.clear()
      @composer.render(delta)
