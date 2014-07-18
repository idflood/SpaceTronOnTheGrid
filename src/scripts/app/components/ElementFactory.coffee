define (require) ->

  Circles = require 'cs!app/elements/Circles'

  extend = (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  class ElementFactory
    @elements:
      Circles:
        default_attributes: () -> extend({}, Circles.defaults)
        default_properties: (time = 0) ->
          return [
            {name: "progression", default: 1, keys: []}
          ]
        create: (options) ->
          # Assign default parameters if not defined
          defaults = Circles.defaults
          options = extend (extend {}, defaults), options
          item = new Circles(options)
          return item


    create: (itemName, data) ->
      item = ElementFactory.elements[itemName]
      if !item
        console.warn("Can't create item: " + itemName)
        return false
      console.log("will create a " + itemName)
      console.log data
      return item.create(data)

  window.ElementFactory = ElementFactory
