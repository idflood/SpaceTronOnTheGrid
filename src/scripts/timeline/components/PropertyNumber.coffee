define (require) ->
  $ = require 'jquery'

  Mustache = require 'Mustache'
  tpl_property = require 'text!app/templates/propertyNumber.tpl.html'

  class PropertyIndicator
    constructor: (@attr) ->
      @$el = $(tpl_property)

      data =
        id: "lorem"
        label: "test"

      view = Mustache.render(tpl_property, data)
      @$el.html(view)
