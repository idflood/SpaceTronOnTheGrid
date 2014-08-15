define (require) ->

  Circles = require 'cs!app/elements/Circles'

  extend = (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  class ElementFactory
    @elements:
      Circles:
        classObject: Circles

        create: (values) ->
          item = new Circles(values)
          return item

    getTypeClass: (itemType) =>
      ElementFactory.elements[itemType].classObject


    create: (itemName, values) ->
      item = ElementFactory.elements[itemName]
      if !item
        console.warn("Can't create item: " + itemName)
        return false
      console.log("will create a " + itemName)
      console.log values
      return item.create(values)

  window.ElementFactory = ElementFactory
