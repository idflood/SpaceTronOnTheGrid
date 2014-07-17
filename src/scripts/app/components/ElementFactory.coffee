define (require) ->

  Circles = require 'cs!app/elements/Circles'

  extend = (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  class ElementFactory
    @elements:
      Circles:
        options:
          numItems: 20
          seed: 12000
          radius: 80
          circleRadius: 20
          circleRadiusMax: 20
        create: (options) ->
          # Assign default parameters if not defined
          defaults = ElementFactory.elements.Circles.options
          options = extend (extend {}, defaults), options
          console.log options
          item = new Circles(options)
          return item

    #constructor: () ->

    create: (itemName, data) ->
      console.log ElementFactory
      item = ElementFactory.elements[itemName]
      if !item
        console.warn("Can't create item: " + itemName)
        return false
      console.log("will create a " + itemName)
      console.log data
      return item.create(data)
