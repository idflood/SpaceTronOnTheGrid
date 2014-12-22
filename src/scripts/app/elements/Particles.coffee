define (require) ->
  _ = require 'lodash'
  THREE = require 'threejs'

  Audio = require 'cs!app/components/Audio'
  Colors = require 'cs!app/components/Colors'

  class Particles
    @circleGeom = new THREE.CircleGeometry( 10, 30, 0, Math.PI * 2 )
    @ringGeom = new THREE.RingGeometry( 10 - 1, 10 + 1, 30, 1, 0, Math.PI * 2 )

    @properties:
      numItems: {name: 'numItems', label: 'num items', val: 5, triggerRebuild: true}

    constructor: (@values = {}, time = 0, index = 0) ->
      # Set the default value of instance properties.
      for key, prop of Particles.properties
        if !@values[key]?
          @values[key] = prop.val

      @container = new THREE.Object3D()
      if index == 0
        @container.position.set(0, 0, 100)
      @items = []

      @speed = Math.random() * 2 - 1
      @scale = Math.random() * 2 + 0.1

      material = new THREE.MeshPhongMaterial({ ambient: 0x030303, color: 0xdddddd, specular: 0xffffff, shininess: 10, shading: THREE.FlatShading })
      material.blending = THREE.AdditiveBlending

      geom = Particles.circleGeom
      if Math.random() < 0.7
        geom = Particles.ringGeom

      @el = new THREE.Mesh(geom , material )
      #@el.position.x = index * (Math.random() * 20 + 20)
      if index > 0
        @el.position.x = Math.random() * 60 + 10
        @el.position.y = Math.random() * 60 + 10
        @el.position.z = Math.random() * 60 + 10

      #@el.rotation.x = Math.random() * 0.4 - 0.2

      @el.scale.set(@scale, @scale, @scale)
      @container.add(@el)

      if index < 5
        for i in [0..@values.numItems - 1]
          num_childs = 1
          if Math.random() > 0.7
            num_childs = parseInt(Math.random * 3, 10) + 1
          item = new Particles({numItems: num_childs}, 0, index + 1)

          @el.add( item.container )
          @items.push(item)


    update: (seconds, values = false, force = false) ->
      @container.rotation.z += @speed / 100

      volume = Audio.instance.mid
      current = @el.scale.x
      if volume > 0.2 && Math.random() < 0.1
        current += volume * 10

      current = current + (@scale - current) * 0.992
      @el.scale.set(current, current, current)


      for item in @items
        item.update()
