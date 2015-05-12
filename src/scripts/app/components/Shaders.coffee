define (require) ->
  THREE = require 'Three'
  Audio = require 'app/components/Audio'

  ShaderVertex = require 'app/shaders/Basic.vert'
  LineFragement = require 'app/shaders/Line.frag'

  class Shaders
    constructor: () ->
      window.shaders = this

      # A non dynamic shader, can be used for all geometries
      @simpleMaterial = new THREE.MeshBasicMaterial({color: 0xdddddd, shading: THREE.FlatShading, side: THREE.DoubleSide})

      @lineMaterial1 = @createMaterialLine()

    update: () ->
      @lineMaterial1.uniforms.percent.value = (@lineMaterial1.uniforms.percent.value + 0.01) % 2
      #console.log @lineMaterial1.uniforms.percent.value

    getMaterialLine: () ->
      if Math.random() <= 0.5
        return @simpleMaterial
      return @lineMaterial1

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

      #material.blending = THREE.AdditiveBlending
      return material
