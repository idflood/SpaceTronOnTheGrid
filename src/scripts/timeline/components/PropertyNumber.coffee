define (require) ->
  $ = require 'jquery'

  Mustache = require 'Mustache'
  tpl_property = require 'text!app/templates/propertyNumber.tpl.html'

  class PropertyIndicator
    constructor: (@property, @instance_property) ->
      @$el = $(tpl_property)
      console.log "..."
      console.log @property
      console.log @instance_property
      data =
        id: @instance_property.name # "circleRadius" instead of "circle radius"
        label: @property.name
        has_keys: if @instance_property.keys then true else false


      view = Mustache.render(tpl_property, data)
      @$el.html(view)
