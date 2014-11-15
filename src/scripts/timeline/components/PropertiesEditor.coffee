define (require) ->
  $ = require 'jquery'
  _ = require 'lodash'
  Signals = require 'Signal'
  PropertyNumber = require 'cs!timeline/components/PropertyNumber'
  PropertyTween = require 'cs!timeline/components/PropertyTween'

  tpl_propertiesEditor = require 'text!timeline/templates/propertiesEditor.tpl.html'

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

      if selectedObject.label
        @$container.append('<h2 class="properties-editor__title">' + selectedObject.label + '</h2>')

      if selectedObject.classObject
        # if we uuse the ElementFactory we have access to more informations
        type_properties = selectedObject.classObject.properties

        for key, prop of type_properties
          # show all properties or only 1 if we selected a key.
          if !property_name || key == property_name
            instance_prop = _.find(selectedObject.properties, (d) -> d.name == key)
            prop = new PropertyNumber(prop, instance_prop, selectedObject, @timer, data)
            prop.keyAdded.add(@onKeyAdded)
            @$container.append(prop.$el)
      else
        # Basic data, loop through properties.
        for key, instance_prop of selectedObject.properties
          if !property_name || instance_prop.name == property_name
            prop = new PropertyNumber({label: instance_prop.name}, instance_prop, selectedObject, @timer, data)
            prop.keyAdded.add(@onKeyAdded)
            @$container.append(prop.$el)

      if property_name
        # Add tween select if we are editing a key.
        tween = new PropertyTween({label: instance_prop.name}, instance_prop, selectedObject, @timer, data)
        @$container.append(tween.$el)