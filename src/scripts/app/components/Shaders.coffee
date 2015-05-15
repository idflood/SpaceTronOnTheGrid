define (require) ->
  THREE = require 'Three'
  Audio = require 'app/components/Audio'

  ShaderVertex = require 'app/shaders/Basic.vert'
  LineFragement = require 'app/shaders/Line.frag'

  class Shaders
    constructor: () ->
      window.shaders = this
      @shaders = []

      # A non dynamic shader, can be used for all geometries
      @simpleMaterial = new THREE.MeshBasicMaterial({color: 0xdddddd, shading: THREE.FlatShading, side: THREE.DoubleSide})

      for i in [0...50]

        @shaders.push(@createMaterialLine(0xdddddd))
      console.log @shaders

    update: () ->

      for shader in @shaders
        #shader.uniforms.percent.value = (shader.uniforms.percent.value + 0.01) % 2

        shader.uniforms.percent.value = Math.max(0, shader.uniforms.percent.value - shader.speed * 0.03)
        if window.audio.mid > 0.8 && Math.random() < 0.02
          shader.uniforms.percent.value = 2
      #console.log @lineMaterial1.uniforms.percent.value

    getMaterialLine: (animated) ->
      if animated == false
        return @simpleMaterial
      return @shaders[Math.floor(Math.random() * @shaders.length)]

    createMaterialLine: (color) ->
      uniforms = {
        percent: {
          type: 'f',
          value: 1.0
        },
        color: {
          type: 'c',
          value: new THREE.Color(color)
        },
        fogColor: {type: "c", value: new THREE.Color(0x111111)},
        fogDensity: {type: "f", 0.2045}
      }
      material = new THREE.ShaderMaterial({
        vertexShader: ShaderVertex,
        fragmentShader: LineFragement,
        side: THREE.DoubleSide,
        shading: THREE.FlatShading,
        uniforms: uniforms,
        transparent: true,
        depthWrite: false,
        depthTest: false,
        fog: true
        })

      material.speed = Math.random() + 0.5 # custom property for per shader transition speed
      material.blending = THREE.AdditiveBlending
      return material
