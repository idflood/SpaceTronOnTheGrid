# References:
#
# d3.js drag/add
# http://stackoverflow.com/questions/19911514/how-can-i-click-to-add-or-drag-in-d3
#
# d3.js brush (show only a portion of time)
# http://bl.ocks.org/bunkat/1962173
#
# d3.js drag date items
# http://codepen.io/Problematic/pen/mskwj
#
# Soundjs
# http://www.createjs.com/#!/SoundJS/documentation
# http://www.createjs.com/Docs/SoundJS/modules/SoundJS.html
#
# Soundjs music visualizer
# https://github.com/CreateJS/SoundJS/blob/master/examples/MusicVisualizer.html
define (require) ->
  #$ = require 'jquery'

  tpl_timeline = require 'text!timeline/templates/timeline.tpl.html'
  EditorTimeline = require 'cs!timeline/Timeline'
  PropertiesEditor = require 'cs!timeline/components/PropertiesEditor'

  class Editor
    constructor: () ->
      @app = window.app
      @timer = @app.timer
      @app.audio.playing = false

      @$timeline = $(tpl_timeline)
      $('body').append(@$timeline)
      $('body').addClass('has-editor')

      @timeline = new EditorTimeline()
      @initControls()
      @initExport()
      @initAdd()
      @initPropertiesEditor()
      @initToggle()

      $(document).keypress (e) =>
        console.log e
        if e.charCode == 32
          # Space
          @playPause()

      # Will help resize the canvas to correct size (minus sidebar and timeline)
      window.editorEnabled = true
      window.dispatchEvent(new Event('resize'))

    initToggle: () ->
      timelineClosed = false
      $toggleLink = @$timeline.find('[data-action="toggle"]')
      $toggleLink.click (e) =>
        e.preventDefault()
        timelineClosed = !timelineClosed
        $toggleLink.toggleClass('menu-item--toggle-up', timelineClosed)
        $('body').toggleClass('timeline-is-closed', timelineClosed)
        window.dispatchEvent(new Event('resize'))

      propertiesClosed = false
      $toggleLinkSide = $('.properties-editor').find('[data-action="toggle"]')
      $toggleLinkSide.click (e) =>
        e.preventDefault()
        propertiesClosed = !propertiesClosed
        $toggleLinkSide.toggleClass('menu-item--toggle-left', propertiesClosed)
        $('body').toggleClass('properties-is-closed', propertiesClosed)

        window.dispatchEvent(new Event('resize'))


    onKeyAdded: () =>
      @timeline.isDirty = true

    initPropertiesEditor: () ->
      @propertiesEditor = new PropertiesEditor(@timeline, @timer)
      @propertiesEditor.keyAdded.add(@onKeyAdded)

    initAdd: () ->
      $container = @$timeline.find('.submenu--add')
      elements = window.ElementFactory.elements
      self = this

      for element_name, element of elements
        # body...
        $link = $('<a href="#" data-key="' + element_name + '">' + element_name + '</a>')
        $container.append($link)

      $container.find('a').click (e) ->
        e.preventDefault()
        element_name = $(this).data('key')
        if ElementFactory.elements[element_name]
          all_data = window.app.data
          next_id = all_data.length + 1
          id = "item" + next_id
          label = element_name + " " + next_id
          current_time = window.app.timer.time[0] / 1000
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
          window.app.data.push(data)
          self.timeline.isDirty = true

    initExport: () ->
      copyAndClean = (source) ->
        target = []
        for obj in source

          new_data =
            id: obj.id,
            type: obj.type,
            label: obj.label,
            start: obj.start,
            end: obj.end,
            collapsed: obj.collapsed,
            properties: obj.properties

          target.push(new_data)

        return target
      @$timeline.find('[data-action="export"]').click (e) ->
        e.preventDefault()
        export_data = copyAndClean(window.app.data)
        #data = JSON.stringify(export_data)
        # Alternative to heave nice looking json string.
        data = JSON.stringify(export_data, null, 2)

        console.log data

    playPause: () =>
      @timer.toggle()
      if @timer.is_playing
        @app.audio.play()
      else
        @app.audio.pause()
      console.log "toggle " + @timer.is_playing

    initControls: () ->
      $play_pause = @$timeline.find('.control.icon-play')
      $play_pause.click (e) =>
        e.preventDefault()
        @playPause()
