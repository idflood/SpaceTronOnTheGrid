define (require) ->
  _ = require 'lodash'
  ElementFactory = require 'app/components/ElementFactory'

  class DataNormalizer
    @normalizeItem = (data_item, factory) ->
      if !data_item.classObject
        data_item.classObject = factory.getTypeClass(data_item.type)
      static_properties = data_item.classObject.properties
      if !static_properties then return
      for key, static_prop of static_properties
        existing_prop = _.find(data_item.properties, (prop) -> prop.name == static_prop.name)
        if !existing_prop
          new_prop = {}
          # clone static prop in new_prop
          for key2, value2 of static_prop
            new_prop[key2] = value2

          new_prop.keys = []
          data_item.properties.push(new_prop)
      return data_item

    @normalizeData = (data, factory) ->
      data = _.map(data, (item) ->
        DataNormalizer.normalizeItem(item, factory)
      )
      return data
