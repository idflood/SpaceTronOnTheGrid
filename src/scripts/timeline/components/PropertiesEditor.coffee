define (require) ->
  $ = require 'jquery'
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

      prop = new PropertyNumber({test: "ok"})
      @$container.append(prop.$el)


