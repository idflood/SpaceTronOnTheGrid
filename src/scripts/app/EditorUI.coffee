define (require) ->
  Editor = require 'Editor'

  class EditorUI
    constructor: () ->
      @tweenTime = window.tweenTime
      @editor = new Editor(@tweenTime, {
        onMenuCreated: @onMenuCreated
      })

    onMenuCreated: ($el) =>
      console.log "menu created 2"
      console.log $el
      $el.prepend('<span class="menu-item">Add<div class="submenu submenu--add"></div></span>')

      @initAdd($el)

    initAdd: ($el) ->
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
            properties: []
            #options: window.ElementFactory.elements[element_name].default_attributes()
            #properties: window.ElementFactory.elements[element_name].default_properties(current_time)
          self.tweenTime.data.push(data)
          self.editor.timeline.isDirty = true