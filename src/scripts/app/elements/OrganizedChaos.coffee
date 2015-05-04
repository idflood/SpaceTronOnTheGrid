define (require) ->
  _ = require 'lodash'
  THREE = require 'Three'

  Audio = require 'app/components/Audio'
  Colors = require 'app/components/Colors'

  CircleGeometry2 = require 'app/geometries/CircleGeometry2'
  ShaderVertex = require 'app/shaders/BasicNoise.vert'
  ShaderFragement = require 'app/shaders/BasicNoise.frag'

  class OrganizedChaos
    @lineGeom = new THREE.PlaneGeometry( 100, 1)
    @circleGeom = new THREE.CircleGeometry( 10, 30, 0, Math.PI * 2 )
    @ringGeom = new THREE.RingGeometry( 10 - 1, 10 + 1, 30, 1, 0, Math.PI * 2 )
    @ringGeom2 = new CircleGeometry2( 10, 30, 0, Math.PI * 2 )

    @properties:
      numItems: {name: 'numItems', label: 'num items', val: 10, triggerRebuild: true}

    constructor: (@values = {}, time = 0) ->
      # Set the default value of instance properties.
      for key, prop of OrganizedChaos.properties
        if !@values[key]?
          @values[key] = prop.val

      @container = new THREE.Object3D()
      @container.position.set(0, 0, 100)
      @items = []

      @speed = Math.random() * 2 - 1
      @scale = Math.random() * 2 + 0.1

      material = new THREE.MeshPhongMaterial({ ambient: 0x030303, color: 0xdddddd, specular: 0xffffff, shininess: 10, shading: THREE.FlatShading })
      material.blending = THREE.AdditiveBlending



      geom = OrganizedChaos.circleGeom
      #if Math.random() < 0.7
      #  geom = OrganizedChaos.ringGeom

      spread = 300
      spread_half = spread / 2

      #@el = new THREE.Mesh(geom , material )
      #@el.position.x = Math.random() * spread - spread_half
      #@el.position.y = Math.random() * spread - spread_half
      #@el.position.z = Math.random() * spread - spread_half

      #@el.rotation.x = Math.random() * 0.4 - 0.2

      #@el.scale.set(@scale, @scale, @scale)
      #@container.add(@el)


      for i in [0..@values.numItems - 1]
        num_childs = 1
        scale = Math.random() + 0.2

        position = new THREE.Vector3(Math.random() * spread - spread_half, Math.random() * spread - spread_half, i * -20)
        rotation = Math.random() * 0.1 + Math.PI / 2
        if Math.random() > 0.7

          scale *= 0.3

        num_childs = parseInt(Math.random() * 7, 10) + 1
        #num_childs = 6

        #material = @getMaterial(0xffffff)
        #geom = OrganizedChaos.circleGeom
        geom = OrganizedChaos.ringGeom2


        #if Math.random() < 0.7
        #  geom = OrganizedChaos.ringGeom

        #if Math.random() < 0.7
        #  geom = OrganizedChaos.lineGeom
        geom = OrganizedChaos.lineGeom

        @addItem(geom, material, i, scale, position, rotation)

        if num_childs > 1
          spacing = 30 + Math.random() * 40
          offset = position.clone().normalize().multiplyScalar(spacing)
          offset.z = 0


          for ii in [0..num_childs - 1]
            pos2 = position.clone().add(offset.multiplyScalar(ii + 1))
            @addItem(geom, material, i, scale, pos2, rotation)

    addItem: (geom, material, i, scale, position, rotation) ->
      position.y = position.y * 0.1

      item = new THREE.Mesh(geom , material )
      item.position.x = position.x
      item.position.y = position.y
      item.position.z = position.z
      item.rotation.set(0,0, rotation)
      item.scale.set(scale, scale, scale)
      @container.add(item)
      @items.push(item)

      # mirroring
      item2 = new THREE.Mesh(geom , material )
      item2.position.x = position.x * -1
      item2.position.y = position.y
      item2.position.z = position.z
      item2.rotation.set(0,0, rotation * -1)
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
          value: color
        }
      }
      material = new THREE.ShaderMaterial({
        vertexShader: ShaderVertex,
        fragmentShader: ShaderFragement,
        uniforms: uniforms,
        transparent: true,
        depthWrite: false,
        depthTest: false
        })

      #material = new THREE.MeshPhongMaterial({ ambient: 0x030303, color: 0xdddddd, specular: 0x009900, shininess: 30, shading: THREE.FlatShading })
      material.blending = THREE.AdditiveBlending
      return material

    update: (seconds, values = false, force = false) ->
      volume = Audio.instance.mid
      #current = @el.scale.x
      #if volume > 0.2 && Math.random() < 0.1
      #  current += volume * 10

      #current = current + (@scale - current) * 0.992
      #@el.scale.set(current, current, current)


      #for item in @items
      #  item.update()
