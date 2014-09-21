define (require) ->
  Camera = require 'cs!app/elements/Camera'
  Circles = require 'cs!app/elements/Circles'
  Boxes = require 'cs!app/elements/Boxes'
  Lines = require 'cs!app/elements/Lines'

  extend = (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  class ElementFactory
    @elements:
      Circles:
        classObject: Circles

      Boxes:
        classObject: Boxes

      Lines:
        classObject: Lines

      Camera:
        classObject: Camera


    getTypeClass: (itemType) =>
      ElementFactory.elements[itemType].classObject


    create: (itemName, values, time) ->
      item = ElementFactory.elements[itemName]
      if !item
        console.warn("Can't create item: " + itemName)
        return false

      return new item.classObject(values)

  window.ElementFactory = ElementFactory
