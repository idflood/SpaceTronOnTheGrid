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
      projector = new THREE.Projector()
      mouseVector = new THREE.Vector3(0, 0, 0.5)
      $container.mousemove (e) =>
        mouseVector.x = ( e.clientX / $container.width() ) * 2 - 1
        mouseVector.y = -( e.clientY / $container.height() ) * 2 + 1
        raycaster = projector.pickingRay( mouseVector.clone(), window.activeCamera )
        intersects = raycaster.intersectObjects( window.app.scene.children )
        if intersects.length
          element = intersects[0].object
          if element._data
            console.log element

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
