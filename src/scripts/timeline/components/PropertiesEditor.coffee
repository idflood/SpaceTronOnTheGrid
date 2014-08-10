define (require) ->
  $ = require 'jquery'
  _ = require 'lodash'
  PropertyNumber = require 'cs!timeline/components/PropertyNumber'

  tpl_propertiesEditor = require 'text!app/templates/propertiesEditor.tpl.html'

  class PropertiesEditor
    constructor: (@timeline) ->
      @$el = $(tpl_propertiesEditor)
      @$container = @$el.find('.properties-editor__main')

      $('body').append(@$el)

      @timeline.onSelect.add(@onSelect)

    onSelect: (selectedObject) =>
      @$container.empty()

      #for key, option of selectedObject.options
      #  # body...
      console.log "selected:"
      console.log selectedObject
      type_properties = selectedObject.classObject.properties

      #console.log type_properties
      for key, prop of type_properties
        instance_prop = _.find(selectedObject.properties, (d) -> d.name == key)
        prop = new PropertyNumber(prop, instance_prop, selectedObject)
        @$container.append(prop.$el)


