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

      if @values[@property.name]?
        # If defined in the instance values use that instead (keys)
        val = @values[@property.name]
      else if @instance_property and @instance_property.val?
        # Use the instance property if defined (value changed but no key)
        val = @instance_property.val

      data =
        id: @property.name # "circleRadius" instead of "circle radius"
        label: @property.label
        #has_keys: if @instance_property.keys then true else false
        val: val


      view = Mustache.render(tpl_property, data)
      @$el.html(view)
