define (require) ->
  $ = require 'jquery'

  Mustache = require 'Mustache'
  tpl_property = require 'text!app/templates/propertyNumber.tpl.html'

  class PropertyIndicator
    constructor: (@property, @instance_property, @object) ->
      @$el = $(tpl_property)
      console.log "..."
      console.log @property
      console.log @instance_property

      @render()

    render: () =>
      # current values are defined in @object.values
      @values = if @object.values? then @object.values else {}
      # By default assign the property default value
      val = @property.val
      # If defined in the instance values use that instead (keys)
      #if @values[@property.name]
      data =
        id: @instance_property.name # "circleRadius" instead of "circle radius"
        label: @property.name
        has_keys: if @instance_property.keys then true else false
        val: val


      view = Mustache.render(tpl_property, data)
      @$el.html(view)
