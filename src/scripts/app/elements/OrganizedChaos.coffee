define (require) ->
  _ = require 'lodash'
  THREE = require 'Three'
  RNG = require 'exports?RNG!rng'
  ElementBase = require 'app/elements/ElementBase'

  Audio = require 'app/components/Audio'
  Colors = require 'app/components/Colors'

  CircleGeometry2 = require 'app/geometries/CircleGeometry2'
  ShaderVertex = require 'app/shaders/BasicNoise.vert'
  ShaderFragement = require 'app/shaders/BasicNoise.frag'

  class OrganizedChaos extends ElementBase
    @lineGeom = new THREE.PlaneGeometry( 100, 1)
    @circleGeom = new THREE.CircleGeometry( 10, 30, 0, Math.PI * 2 )
    @ringGeom = new THREE.RingGeometry( 10 - 1, 10 + 1, 30, 1, 0, Math.PI * 2 )
    @ringGeom2 = new CircleGeometry2( 10, 30, 0, Math.PI * 2 )

    @properties:
      numItems: {name: 'numItems', label: 'num items', val: 10, triggerRebuild: true, group: "global"}
      seed: {name: 'seed', label: 'seed', val: 10042, triggerRebuild: true, group: "global"}
      depth: {name: 'depth', label: 'depth', val: 20, triggerRebuild: true, group: "global"}
      spread: {name: 'spread', label: 'spread', val: 300, triggerRebuild: true, group: "global"}
      spreadY: {name: 'spreadY', label: 'spreadY', val: 300, triggerRebuild: true, group: "global"}
      maxChilds: {name: 'maxChilds', label: 'maxChilds', val: 8, triggerRebuild: true, group: "global"}
      x: {name: 'x', label: 'x', val: 0, group: "position"}
      y: {name: 'y', label: 'y', val: 0, group: "position"}
      z: {name: 'z', label: 'z', val: 0, group: "position"}
      rotationX: {name: 'rotationX', label: 'x', val: 0, min: 0, max: 2, group: "rotation", triggerRebuild: true}
      rotationY: {name: 'rotationY', label: 'y', val: 0, min: 0, max: 2, group: "rotation", triggerRebuild: true}
      rotationZ: {name: 'rotationZ', label: 'z', val: 0, min: 0, max: 2, group: "rotation", triggerRebuild: true}
      rotationRandX: {name: 'rotationRandX', label: 'rand x', val: 0, min: 0, max: 1, group: "rotation", triggerRebuild: true}
      rotationRandY: {name: 'rotationRandY', label: 'rand y', val: 0, min: 0, max: 1, group: "rotation", triggerRebuild: true}
      rotationRandZ: {name: 'rotationRandZ', label: 'rand z', val: 1, min: 0, max: 1, group: "rotation", triggerRebuild: true}
      circles: {name: 'circles', label: 'circles', val: 0, triggerRebuild: true, group: "geometry"}

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

    build: (time = 0) ->
      rngX = new RNG(@values.seed + "x")
      rngY = new RNG(@values.seed + "y")
      rngRotationX = new RNG(@values.seed + "rotationX")
      rngRotationY = new RNG(@values.seed + "rotationY")
      rngRotationZ = new RNG(@values.seed + "rotationZ")
      rngChilds = new RNG(@values.seed + "childs")
      rngSpacing = new RNG(@values.seed + "spacing")
      rngType = new RNG(@values.seed + "type")

      #material = new THREE.MeshPhongMaterial({ ambient: 0x030303, color: 0xdddddd, specular: 0xffffff, shininess: 10, shading: THREE.FlatShading, side: THREE.DoubleSide })
      material = new THREE.MeshBasicMaterial({color: 0xdddddd, shading: THREE.FlatShading, side: THREE.DoubleSide})
      material.blending = THREE.AdditiveBlending

      geom = OrganizedChaos.circleGeom

      spread = @values.spread
      spread_half = spread / 2

      spreadY = @values.spreadY
      spreadY_half = spreadY / 2

      #material = @getMaterial(0xffffff)

      for i in [0..@values.numItems - 1]
        num_childs = 1
        scale = Math.random() + 0.2

        posX = rngX.random(spread * 100) * 0.01 - spread_half
        posY = rngY.random(spreadY * 100) * 0.01 - spreadY_half
        position = new THREE.Vector3(posX, posY, i * -@values.depth)
        rotationX = (rngRotationX.random(0, 1000) / 1000 * Math.PI) * @values.rotationRandX + @values.rotationX * Math.PI
        rotationY = (rngRotationY.random(0, 1000) / 1000 * Math.PI) * @values.rotationRandY + @values.rotationY * Math.PI
        rotationZ = (rngRotationZ.random(0, 1000) / 1000 * Math.PI) * @values.rotationRandZ + @values.rotationZ * Math.PI
        rotation = new THREE.Vector3(rotationX, rotationY, rotationZ)
        #if rngRotationZ.random(0, 1000) * 0.01 > 0.7
        #  scale *= 0.3

        num_childs = parseInt(rngChilds.random(0, @values.maxChilds), 10)
        #num_childs = 6

        #material = @getMaterial(0xffffff)
        #geom = OrganizedChaos.circleGeom
        #geom = OrganizedChaos.ringGeom2


        itemType = rngType.random(0, 1000) / 1000


        #if Math.random() < 0.7
        #  geom = OrganizedChaos.lineGeom
        geom = OrganizedChaos.lineGeom

        if Math.random() < @values.circles
          geom = OrganizedChaos.ringGeom

        @addItem(geom, material, i, scale, position, rotation)

        if num_childs > 1
          spacing = 30 + rngSpacing.random(0, 100) * 0.4
          offset = position.clone().normalize().multiplyScalar(spacing)
          offset.z = 0


          for ii in [0..num_childs - 1]
            pos2 = position.clone().add(offset.multiplyScalar(ii + 1))
            @addItem(geom, material, i, scale, pos2, rotation)

    addItem: (geom, material, i, scale, position, rotation) ->
      #position.y = position.y * 0.1

      item = new THREE.Mesh(geom , material )
      item.position.x = position.x
      item.position.y = position.y
      item.position.z = position.z
      item.rotation.set(rotation.x, rotation.y, rotation.z)
      item.scale.set(scale, scale, scale)
      @container.add(item)
      @items.push(item)

      # mirroring
      item2 = new THREE.Mesh(geom , material )
      item2.position.x = position.x * -1
      item2.position.y = position.y
      item2.position.z = position.z
      item2.rotation.set(rotation.x, rotation.y * -1, rotation.z * -1)
      item2.scale.set(scale, scale, scale)
      @container.add(item2)
      @items.push(item2)

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

      volume = Audio.instance.mid

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
