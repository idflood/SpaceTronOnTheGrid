define (require) ->
  $ = require 'jquery'

  tpl_propertiesEditor = require 'text!app/templates/propertiesEditor.tpl.html'

  class PropertiesEditor
    constructor: (@timeline) ->
      @$el = $(tpl_propertiesEditor)
      $('body').append(@$el)


