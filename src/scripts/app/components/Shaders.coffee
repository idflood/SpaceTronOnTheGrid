define (require) ->
  THREE = require 'Three'
  Global = require 'app/elements/Global'

  ShaderVertex = require 'app/shaders/Basic.vert'
  LineFragement = require 'app/shaders/Line.frag'

  class Shaders
    @COLOR_WHITE = 0
    @COLOR_RED = 1
    @COLOR_BLUE = 2

    constructor: () ->
      window.shaders = this
      @shaders = []
      @shadersWhite = []
      @shadersRed = []
      @shadersBlue = []

      red = 0xe66c00
      blue = 0x27acef

      num_shaders = 50
      # A non dynamic shader, can be used for all geometries
      @simpleMaterial = new THREE.MeshBasicMaterial({color: 0xdddddd, shading: THREE.FlatShading, side: THREE.DoubleSide})
      @simpleMaterialRed = new THREE.MeshBasicMaterial({color: red, shading: THREE.FlatShading, side: THREE.DoubleSide})
      @simpleMaterialBlue = new THREE.MeshBasicMaterial({color: blue, shading: THREE.FlatShading, side: THREE.DoubleSide})

      for i in [0...num_shaders]
        mat = @createMaterialLine(0xdddddd)
        @shaders.push(mat)
        @shadersWhite.push(mat )

        mat = @createMaterialLine(red)
        @shaders.push(mat)
        @shadersRed.push(mat)

        mat = @createMaterialLine(blue)
        @shaders.push(mat)
        @shadersBlue.push(mat)

    update: (force = 0) ->
      for shader in @shaders
        shader.uniforms.percent.value = Math.max(0, shader.uniforms.percent.value - shader.speed * 0.03)


        # Only bump value if it is not already animating.
        if shader.uniforms.percent.value < 0.02
          # Can force from intro (hover button)
          if force && Math.random() < force
            shader.uniforms.percent.value = 2
          # only bump values once in a while. Without this
          # every shaders would animate on the first boum.
          else if Math.random() < 0.02
            bassSensibility = 0
            midSensibility = 0
            highSensibility = 0

            globalValues = false
            if window.global && window.global.values
              globalValues = window.global.values
              bassSensibility = globalValues.bassSensibility
              midSensibility = globalValues.midSensibility
              highSensibility = globalValues.highSensibility

            audioData = window.audio.data.filters

            if audioData.bass.timeDomainRMS > bassSensibility || audioData.mid.timeDomainRMS > midSensibility || audioData.high.timeDomainRMS > highSensibility
              shader.uniforms.percent.value = 2
            if globalValues && Math.random() < globalValues.autoAnimate
              shader.uniforms.percent.value = 2


      #console.log @lineMaterial1.uniforms.percent.value

    getMaterialLine: (animated, color) ->
      if animated == false
        switch color
          when Shaders.COLOR_RED then return @simpleMaterialRed
          when Shaders.COLOR_BLUE then return @simpleMaterialBlue
        return @simpleMaterial

      shaders = @shadersWhite
      if color == Shaders.COLOR_RED then shaders = @shadersRed
      if color == Shaders.COLOR_BLUE then shaders = @shadersBlue

      return shaders[Math.floor(Math.random() * shaders.length)]

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
