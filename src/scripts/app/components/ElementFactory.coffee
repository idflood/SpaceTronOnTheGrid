define (require) ->
  Camera = require 'app/elements/Camera'
  Global = require 'app/elements/Global'
  OrganizedChaos = require 'app/elements/OrganizedChaos'

  extend = (object, properties) ->
    for key, val of properties
      if typeof(object[key]) == 'object' && object[key] != null
        object[key] = extend({}, val)
      else
        object[key] = val
    object

  class ElementFactory
    @elements:
      Chaos:
        classObject: OrganizedChaos
      Camera:
        classObject: Camera
      Global:
        classObject: Global

    getTypeClass: (itemType) =>
      ElementFactory.elements[itemType].classObject

    @getTypeProperties: (itemName) =>
      item = ElementFactory.elements[itemName]
      if item
        element_class = item.classObject
        if element_class
          properties = []
          for key, prop_definition of item.classObject.properties
            prop = extend({}, prop_definition)
            prop.keys = []
            properties.push(prop)
          console.log properties
          return properties
      return

    create: (itemName, values, time) ->
      item = ElementFactory.elements[itemName]
      if !item
        console.warn("Can't create item: " + itemName)
        return false

      return new item.classObject(values)

  window.ElementFactory = ElementFactory
