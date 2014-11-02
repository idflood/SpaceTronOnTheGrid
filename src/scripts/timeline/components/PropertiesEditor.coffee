define (require) ->
  $ = require 'jquery'
  _ = require 'lodash'
  Signals = require 'Signal'
  PropertyNumber = require 'cs!timeline/components/PropertyNumber'

  tpl_propertiesEditor = require 'text!app/templates/propertiesEditor.tpl.html'

  class PropertiesEditor
    constructor: (@timeline, @timer) ->
      @$el = $(tpl_propertiesEditor)
      @$container = @$el.find('.properties-editor__main')
      @keyAdded = new Signals.Signal()

      $('body').append(@$el)

      @timeline.onSelect.add(@onSelect)

    onKeyAdded: () =>
      @keyAdded.dispatch()

    onSelect: (selectedObject, data = false, propertyData = false) =>
      @$container.empty()
      # data and propertyData are defined on key select.
      property_name = false
      if propertyData
        property_name = propertyData.name

      type_properties = selectedObject.classObject.properties

      for key, prop of type_properties
        # show all properties or only 1 if we selected a key.
        if !property_name || key == property_name
          instance_prop = _.find(selectedObject.properties, (d) -> d.name == key)
          prop = new PropertyNumber(prop, instance_prop, selectedObject, @timer, data)
          prop.keyAdded.add(@onKeyAdded)
          @$container.append(prop.$el)
