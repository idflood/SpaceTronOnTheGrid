define (require) ->
  _ = require 'lodash'
  THREE = require 'Three'
  RNG = require 'exports?RNG!rng'
  ElementBase = require 'app/elements/ElementBase'

  Colors = require 'app/components/Colors'
  Shaders = require 'app/components/Shaders'

  CircleGeometry2 = require 'app/geometries/CircleGeometry2'
  ShaderVertex = require 'app/shaders/BasicNoise.vert'
  ShaderFragement = require 'app/shaders/BasicNoise.frag'


  class OrganizedChaos extends ElementBase
    @lineGeom = new THREE.PlaneGeometry( 100, 1)
    @circleGeom = new THREE.CircleGeometry( 10, 30, 0, Math.PI * 2 )
    @ringGeom2 = new CircleGeometry2( 10, 30, 0, Math.PI * 2 )

    @triGeom = new CircleGeometry2( 10, 3, 0, Math.PI * 2 )

    @squareGeom = new CircleGeometry2( 10, 4, 0, Math.PI * 2 )

    @TYPE_LINE = 0
    @TYPE_SQUARE = 1
    @TYPE_CIRCLE = 2
    @TYPE_TRI = 3

    @properties:
      numItems: {name: 'numItems', label: 'num items', val: 10, triggerRebuild: true, group: "global"}
      seed: {name: 'seed', label: 'seed', val: 10042, triggerRebuild: true, group: "global"}
      depth: {name: 'depth', label: 'depth', val: 20, triggerRebuild: true, group: "global"}
      spread: {name: 'spread', label: 'spread', val: 300, triggerRebuild: true, group: "global"}
      spreadY: {name: 'spreadY', label: 'spreadY', val: 300, triggerRebuild: true, group: "global"}
      maxChilds: {name: 'maxChilds', label: 'maxChilds', val: 8, triggerRebuild: true, group: "global"}
      horizontalSymmetry: {name: 'horizontalSymmetry', label: 'horizontalSymmetry', val: 1, min: 0, max: 1, triggerRebuild: true, group: "global"}
      verticalSymmetry: {name: 'verticalSymmetry', label: 'verticalSymmetry', val: 0, min: 0, max: 1, triggerRebuild: true, group: "global"}
      x: {name: 'x', label: 'x', val: 0, group: "position"}
      y: {name: 'y', label: 'y', val: 0, group: "position"}
      z: {name: 'z', label: 'z', val: 0, group: "position"}
      rotationX: {name: 'rotationX', label: 'x', val: 0, min: -2, max: 2, group: "rotation", triggerRebuild: true}
      rotationY: {name: 'rotationY', label: 'y', val: 0, min: -2, max: 2, group: "rotation", triggerRebuild: true}
      rotationZ: {name: 'rotationZ', label: 'z', val: 0, min: -2, max: 2, group: "rotation", triggerRebuild: true}
      rotationRandX: {name: 'rotationRandX', label: 'rand x', val: 0, min: 0, max: 1, group: "rotation", triggerRebuild: true}
      rotationRandY: {name: 'rotationRandY', label: 'rand y', val: 0, min: 0, max: 1, group: "rotation", triggerRebuild: true}
      rotationRandZ: {name: 'rotationRandZ', label: 'rand z', val: 1, min: 0, max: 1, group: "rotation", triggerRebuild: true}
      circles: {name: 'circles', label: 'circles', val: 0, triggerRebuild: true, group: "geometry"}
      squares: {name: 'squares', label: 'squares', val: 0, triggerRebuild: true, group: "geometry"}
      tri: {name: 'tri', label: 'tri', val: 0, triggerRebuild: true, group: "geometry"}
      lineWidth: {name: 'lineWidth', label: 'line width', val: 1, triggerRebuild: true, group: "line"}
      lineWidthRand: {name: 'lineWidthRand', label: 'line width randomness', val: 0, triggerRebuild: true, group: "line"}
      lineHeight: {name: 'lineHeight', label: 'line height', val: 1, triggerRebuild: true, group: "line"}
      lineHeightRand: {name: 'lineHeightRand', label: 'line height randomness', val: 0, triggerRebuild: true, group: "line"}
      materialRed: {name: 'materialRed', label: 'percent red', val: 0, min: 0, max: 1, triggerRebuild: true, group: "material"}
      materialBlue: {name: 'materialBlue', label: 'percent blue', val: 0, min: 0, max: 1, triggerRebuild: true, group: "material"}
      materialAnimated: {name: 'materialAnimated', label: 'percent animated', val: 0, triggerRebuild: true, group: "material"}

    getDefaultProperties: () -> OrganizedChaos.properties

    constructor: (@values = {}, time = 0) ->
      # Set the default value of instance properties.
      for key, prop of OrganizedChaos.properties
        if !@values[key]?
          @values[key] = prop.val

      # Set values cache
      super

      @container = new THREE.Object3D()
      @container.position.set(0, 0, 0)
      @items = []
      @build()

    rebuild: (time) ->
      @empty()
      @build(time)

    empty: () ->
      if !@items || !@items.length then return

      for item in @items
        @container.remove(item)
        #item.destroy()
      @items = []

    getItemType: (rng) ->
      itemType = rng.random(0, 1000) / 1000

      if itemType < @values.circles
        return OrganizedChaos.TYPE_CIRCLE

      if itemType < @values.circles + @values.squares
        return OrganizedChaos.TYPE_SQUARE

      if itemType < @values.circles + @values.squares + @values.tri
        return OrganizedChaos.TYPE_TRI

      return OrganizedChaos.TYPE_LINE

    getItemColor: (rng) ->
      itemColor = rng.random(0, 1000) / 1000

      if itemColor < @values.materialBlue
        return Shaders.COLOR_BLUE

      if itemColor < @values.materialBlue + @values.materialRed
        return Shaders.COLOR_RED

      return Shaders.COLOR_WHITE

    build: (time = 0) ->
      rngX = new RNG(@values.seed + "x")
      rngY = new RNG(@values.seed + "y")
      rngRotationX = new RNG(@values.seed + "rotationX")
      rngRotationY = new RNG(@values.seed + "rotationY")
      rngRotationZ = new RNG(@values.seed + "rotationZ")
      rngScale = new RNG(@values.seed + "scale")
      rngScaleLine = new RNG(@values.seed + "scaleLine")
      rngScaleSquare = new RNG(@values.seed + "scaleSquare")
      rngScaleLineHeight = new RNG(@values.seed + "scaleLineHeight")
      rngChilds = new RNG(@values.seed + "childs")
      rngHorizontalSymmetry = new RNG(@values.seed + "horizontalSymmetry")
      rngVerticalSymmetry = new RNG(@values.seed + "verticalSymmetry")
      rngSpacing = new RNG(@values.seed + "spacing")
      rngType = new RNG(@values.seed + "type")
      rngColor = new RNG(@values.seed + "color")
      rngShaderAnim = new RNG(@values.seed + "shaderAnim")

      spread = @values.spread
      spread_half = spread / 2

      spreadY = @values.spreadY
      spreadY_half = spreadY / 2

      #material = @getMaterial(0xffffff)

      for i in [0...@values.numItems]
        animated = false
        if rngShaderAnim.random(100) / 100 < @values.materialAnimated
          animated = true

        num_childs = 1
        scale = rngScale.random(0, 100) / 100 + 0.2

        posX = rngX.random(spread * 100) * 0.01 - spread_half
        posY = rngY.random(spreadY * 100) * 0.01 - spreadY_half
        position = new THREE.Vector3(posX, posY, i * -@values.depth)
        rotationX = (rngRotationX.random(0, 1000) / 1000 * Math.PI) * @values.rotationRandX + @values.rotationX * Math.PI
        rotationY = (rngRotationY.random(0, 1000) / 1000 * Math.PI) * @values.rotationRandY + @values.rotationY * Math.PI
        rotationZ = (rngRotationZ.random(0, 1000) / 1000 * Math.PI) * @values.rotationRandZ + @values.rotationZ * Math.PI
        rotation = new THREE.Vector3(rotationX, rotationY, rotationZ)
        scale = new THREE.Vector3(scale, scale, scale)

        geomMerge = new THREE.Geometry()

        horizontalSymmetry = false
        verticalSymmetry = false
        num_childs = parseInt(rngChilds.random(0, @values.maxChilds), 10)
        itemType = @getItemType(rngType)
        itemColor = @getItemColor(rngColor)

        geom = OrganizedChaos.lineGeom
        material = window.shaders.getMaterialLine(animated, itemColor)

        if @values.horizontalSymmetry && rngHorizontalSymmetry.random(0, 100) / 100 <= @values.horizontalSymmetry
          horizontalSymmetry = true


        if @values.verticalSymmetry && rngVerticalSymmetry.random(0, 100) / 100 <= @values.verticalSymmetry
          verticalSymmetry = true

        if itemType == OrganizedChaos.TYPE_LINE
          scale.y = (scale.y * @values.lineWidth) * (rngScaleLine.random(1, 100) / 100) * (@values.lineWidthRand + 1)
          # Define a minimum scale to avoid invisible lines
          scale.y = Math.max(0.5, scale.y)

          scale.x = (scale.x * @values.lineHeight) * (rngScaleLineHeight.random(1, 100) / 100) * (@values.lineHeightRand + 1)
          # Define a minimum scale to avoid invisible lines
          scale.x = Math.max(0.01, scale.x)

        if itemType == OrganizedChaos.TYPE_CIRCLE
          geom = OrganizedChaos.ringGeom2

        if itemType == OrganizedChaos.TYPE_TRI
          geom = OrganizedChaos.triGeom

        else if itemType == OrganizedChaos.TYPE_SQUARE
          geom = OrganizedChaos.squareGeom
          rnd = 0.5 + rngScaleSquare.random(0, 100) / 100
          scale.multiplyScalar(rnd)


        @addItem(geomMerge, geom, material, i, scale, position, rotation, horizontalSymmetry, verticalSymmetry)

        if num_childs > 1
          spacing = 30 + rngSpacing.random(0, 100) * 0.4
          offset = position.clone().normalize().multiplyScalar(spacing)
          offset.z = 0

          for ii in [0..num_childs - 1]
            pos2 = position.clone().add(offset.multiplyScalar(ii + 1))
            @addItem(geomMerge, geom, material, i, scale, pos2, rotation, horizontalSymmetry, verticalSymmetry)

        itemMesh = new THREE.Mesh(geomMerge , material)
        itemMesh.matrixAutoUpdate = false
        @container.add(itemMesh)
        @items.push(itemMesh)


    addItem: (geomMerge, geom, material, i, scale, position, rotation, horizontalSymmetry, verticalSymmetry) ->
      quaternion = new THREE.Quaternion()
      quaternion.setFromAxisAngle(new THREE.Vector3(rotation.x, rotation.y, rotation.z), Math.PI / 2)
      item = new THREE.Object3D()
      item.position.x = position.x
      item.position.y = position.y
      item.position.z = position.z
      item.rotation.setFromQuaternion(quaternion)
      item.scale.copy(scale)

      item.updateMatrix()
      geomMerge.merge( geom, item.matrix )

      if horizontalSymmetry
        # mirroring
        item2Container = new THREE.Object3D()

        item2 = new THREE.Object3D()
        item2.position.x = position.x
        item2.position.y = position.y
        item2.position.z = position.z
        # mirror rotation
        item2.rotation.setFromQuaternion(quaternion)
        item2.scale.copy(scale)

        item2Container.add(item2)
        item2Container.scale.x = -1
        item2Container.updateMatrix()

        item2.updateMatrix()
        geomMerge.merge(geom, item2Container.matrix.multiply(item2.matrix))

        if verticalSymmetry
          # mirroring
          item2Container = new THREE.Object3D()

          item2 = new THREE.Object3D()
          item2.position.x = position.x
          item2.position.y = position.y
          item2.position.z = position.z
          # mirror rotation
          item2.rotation.setFromQuaternion(quaternion)
          item2.scale.copy(scale)
          item2Container.add(item2)
          item2Container.scale.x = -1
          item2Container.scale.y = -1

          item2Container.updateMatrix()
          item2.updateMatrix()
          geomMerge.merge(geom, item2Container.matrix.multiply(item2.matrix))

      if verticalSymmetry
        # mirroring
        item2Container = new THREE.Object3D()

        @container.add(item2Container)
        item2 = new THREE.Object3D()
        item2.position.x = position.x
        item2.position.y = position.y
        item2.position.z = position.z
        # mirror rotation
        item2.rotation.setFromQuaternion(quaternion)
        item2.scale.copy(scale)
        item2Container.add(item2)
        item2Container.scale.y = -1

        item2Container.updateMatrix()
        item2.updateMatrix()
        geomMerge.merge(geom, item2Container.matrix.multiply(item2.matrix))

      return geomMerge

    getMaterial: (color) ->
      uniforms = {
        time: {
          type: 'f',
          value: 0.0
        },
        seed: {
          type: 'f',
          value: Math.random() * 1000
        },
        strength: {
          type: 'f',
          value: 0.2
        },
        color: {
          type: 'c',
          value: new THREE.Color(color)
        },
        fogColor:    { type: "c", value: new THREE.Color(0x111111) },
        fogDensity:      { type: "f", 0.2045}
      }
      material = new THREE.ShaderMaterial({
        vertexShader: ShaderVertex,
        fragmentShader: ShaderFragement,
        side: THREE.DoubleSide,
        uniforms: uniforms,
        transparent: true,
        depthWrite: false,
        depthTest: false,
        fog: true
        })

      #material = new THREE.MeshPhongMaterial({ ambient: 0x030303, color: 0xdddddd, specular: 0x009900, shininess: 30, shading: THREE.FlatShading })
      material.blending = THREE.AdditiveBlending
      return material

    update: (seconds, values = false, force = false) ->
      if values == false then values = @values
      needs_rebuild = false

      # Check if any of the invaldating property changed.
      for key, prop of OrganizedChaos.properties
        if prop.triggerRebuild && @valueChanged(key, values)
          needs_rebuild = true

      volume = window.audio.data.filters.mid.timeDomainRMS

      if force || @valueChanged("x", values) || @valueChanged("y", values) || @valueChanged("z", values)
        @container.position.set(values.x, values.y, values.z)
      #current = @el.scale.x
      #if volume > 0.2 && Math.random() < 0.1
      #  current += volume * 10

      #current = current + (@scale - current) * 0.992
      #@el.scale.set(current, current, current)


      #for item in @items
      #  item.update()
      # save the new values
      @values = _.merge(@values, values)

      if needs_rebuild == true
        @rebuild(seconds)
      return

    destroy: () ->
      for child in @container.children
        @container.remove(child)

      @container = null
