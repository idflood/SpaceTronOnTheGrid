define (require) ->
  THREE = window.THREE
  Editor = require 'Editor'
  d3 = require 'd3'

  class EditorUI
    constructor: () ->
      @tweenTime = window.tweenTime
      @editor = new Editor(@tweenTime, {
        #onMenuCreated: @onMenuCreated,
        json_replacer: (key, val) ->
          # filter some circular values
          if key == 'container' then return undefined
          if key == 'parent' then return undefined
          if key == 'children' then return undefined
          if key == 'object' then return undefined
          if key == 'classObject' then return undefined
          return val
      })
      @onMenuCreated($('.timeline__menu'))


      $container = $(window.app.containerWebgl)
      offset = new THREE.Vector3()
      projector = new THREE.Projector()
      mouse = new THREE.Vector2()
      selectedObject = false
      selectedObjectPos = new THREE.Vector3()

      plane = new THREE.Mesh(
        new THREE.PlaneBufferGeometry( 3000, 2000, 8, 8 ),
        new THREE.MeshBasicMaterial( { color: 0xff0000, opacity: 0.25, transparent: true } )
      )
      plane.visible = false
      #window.app.scene.add( plane )

      getRaycaster = () =>
        camera = window.activeCamera
        vector = new THREE.Vector3( mouse.x, mouse.y, 0.5 ).unproject( camera )
        raycaster = new THREE.Raycaster(camera.position, vector.sub( camera.position ).normalize())
        return raycaster

      $container.mousedown (e) =>
        e.preventDefault()
        raycaster = getRaycaster()
        intersects = raycaster.intersectObjects( window.app.scene.children )

        if intersects.length
          element = intersects[0].object
          if element._data
            @editor.selectionManager.select(element._data)
            selectedObject = element
            selectedObjectPos = selectedObject.position.clone()

            intersects = raycaster.intersectObject(plane)
            offset.copy(intersects[ 0 ].point).sub(plane.position)
      $(window).mouseup (e) =>
        selectedObject = false

      $container.mousemove (e) =>
        mouse.x = ( e.clientX / $container.width() ) * 2 - 1
        mouse.y = -( e.clientY / $container.height() ) * 2 + 1

        if !selectedObject then return
        if !selectedObject._data then return
        prop_x = @tweenTime.getProperty('x', selectedObject._data)
        prop_y = @tweenTime.getProperty('y', selectedObject._data)

        raycaster = getRaycaster()
        intersects = raycaster.intersectObject( plane )
        pos = intersects[ 0 ].point.sub( offset )

        posDiff = selectedObjectPos.clone().add(pos)

        @tweenTime.setValue(prop_x, posDiff.x)
        @tweenTime.setValue(prop_y, posDiff.y)
        selectedObject._data._isDirty = true
        @editor.timeline._isDirty = true


    onMenuCreated: ($el) =>
      $el.append('<a class="menu-item menu-item--remove">Remove</a>')
      $el.prepend('<span class="menu-item">Add<div class="submenu submenu--add"></div></span>')

      @initAdd($el)
      @initRemove($el)

    initRemove: ($el) =>
      self = this
      selectionManager = self.editor.selectionManager
      data = window.tweenTime.data
      $el.find('.menu-item--remove').click (e) ->
        e.preventDefault()
        for item in selectionManager.selection
          # only remove full objects.
          datum = d3.select(item).datum()
          index = data.indexOf(datum)
          if datum && datum.type && datum.id && index > -1
            data.splice(index, 1)
            # also remove the three.js object
            if datum.object
              datum.object.destroy()
              delete datum.object

        selectionManager.reset()
        self.editor.render(false, false, true)
        return
      return

    initAdd: ($el) =>
      if !window.ElementFactory then return
      $container = $el.find('.submenu--add')
      elements = window.ElementFactory.elements
      self = this

      for element_name, element of elements
        $link = $('<a href="#" data-key="' + element_name + '">' + element_name + '</a>')
        $container.append($link)

      $container.find('a').click (e) ->
        e.preventDefault()
        element_name = $(this).data('key')
        if ElementFactory.elements[element_name]
          all_data = self.tweenTime.data
          next_id = all_data.length + 1
          id = "item" + next_id
          label = element_name + " " + next_id
          current_time = self.tweenTime.timer.time[0] / 1000
          data =
            isDirty: true
            id: id
            label: label
            type: element_name
            start: current_time
            end: current_time + 2
            collapsed: false
            #properties: []
            #options: window.ElementFactory.elements[element_name].default_attributes()
            #properties: window.ElementFactory.elements[element_name].default_properties(current_time)
            properties: ElementFactory.getTypeProperties(element_name)

          self.tweenTime.data.push(data)
          self.editor.timeline._isDirty = true
        return
      return
