define (require) ->
  $ = require 'jquery'
  Signals = require 'Signal'
  _ = require 'lodash'

  Mustache = require 'Mustache'
  tpl_property = require 'text!app/templates/propertyNumber.tpl.html'

  class PropertyIndicator
    constructor: (@property, @instance_property, @object, @timer) ->
      @$el = $(tpl_property)
      @keyAdded = new Signals.Signal()
      @render()

    onKeyClick: (e) =>
      e.preventDefault()
      properties = @object.properties
      property = _.find(properties, (prop) => prop.name == @property.name)
      if !property
        property = {keys: [], name: @property.name, val: @getInputVal()}
        properties.push(property)
      currentValue = @getCurrentVal()
      # We want seconds for keys and not milliseconds.
      currentTime = @timer.getCurrentTime() / 1000

      key = {time: currentTime, val: @getInputVal()}
      #@instance_property.keys.push(key)
      property.keys.push(key)
      @keyAdded.dispatch()

    getInputVal: () =>
      @$el.find('input').val()

    getCurrentVal: () =>
      val = @property.val

      if @values[@property.name]?
        # If defined in the instance values use that instead (keys)
        val = @values[@property.name]
      else if @instance_property and @instance_property.val?
        # Use the instance property if defined (value changed but no key)
        val = @instance_property.val
      return val

    render: () =>
      # current values are defined in @object.values
      @values = if @object.values? then @object.values else {}
      # By default assign the property default value
      val = @getCurrentVal()

      data =
        id: @property.name # "circleRadius" instead of "circle radius"
        label: @property.label
        #has_keys: if @instance_property.keys then true else false
        val: val


      view = Mustache.render(tpl_property, data)
      @$el.html(view)
      @$el.find('.property__key').click(@onKeyClick)
