define (require) ->
  ElementFactory = require 'cs!app/components/ElementFactory'
  _ = require 'lodash'

  TweenMax = require 'TweenMax'
  TimelineMax = require 'TimelineMax'

  class Orchestrator
    constructor: (@timer, @data, @scene, @defaultCamera) ->
      @factory = new ElementFactory()
      @mainTimeline = new TimelineMax({paused: true})
      #@dummy = {percent: 0}
      # Add a dummy timelinelite object with a key at total duration to have
      # a long enough timeline.
      #@dummyTimeline = new TimelineLite()
      #@dummyTimeline.to(@dummy, @timer.totalDuration / 1000, {percent: 1})
      #@mainTimeline.append(@dummyTimeline)
      @mainTimeline.duration(@timer.totalDuration / 1000)

      @timer.updated.add(@update)

      @update(0)

    update: (timestamp) =>
      activeCamera = @defaultCamera
      seconds = timestamp / 1000

      #return false
      for item in @data
        should_exist = if seconds >= item.start && seconds <= item.end then true else false

        # Remove the item
        if (item.object && should_exist == false) || item.isDirtyObject
          item.isDirtyObject = false
          if item.object
            @scene.remove(item.object.container)
            item.object.destroy()
            delete item.object

        # Assign the object class to be able to access all object properties in propertiesEditor
        if !item.classObject then item.classObject = @factory.getTypeClass(item.type)

        # If object doesn't exist skip the update.
        if should_exist == false then continue

        # create the values object to contain all properties
        if !item.values
          item.values = {}
          #item.isDirty = true
          for key, property of item.classObject.properties
            item_property = _.find(item.properties, (prop) -> prop.name == key)
            # Create the item property if it didn't exist.
            if !item_property
              item_property = {keys: [], name: property.name, val: property.val}
              item.properties.push(item_property)

            if item_property.keys.length
              # Take the value of the first key as initial value.
              # @todo: update this when the value of the first key change. (when rebuilding the timeline, simply delete item.values before item.timeline)
              item_property.val = item_property.keys[0].val

            item.values[property.name] = item_property.val

        # Handle adding keys to previously emptry properties
        #if item.isDirty && item.values
        #  for key, prop of item.properties
        #    if !item.values[key]


        # Create the timeline if needed
        if !item.timeline
          item.timeline = new TimelineMax()
          @mainTimeline.add(item.timeline, 0)
          item.isDirty = true

        if item.timeline and item.isDirty and item.properties
          item.isDirty = false
          item.timeline.clear()

          for property in item.properties
            propertyTimeline = new TimelineMax()
            propName = property.name
            # Add a inital key, even if there is no animation to set the value from time 0.
            first_key = if property.keys.length > 0 then property.keys[0] else false
            tween_time = 0
            if first_key
              tween_time = Math.min(-1, first_key.time - 0.1)

            tween_duration = 0
            val = {}
            val[propName] = if first_key then first_key.val else property.val
            tween = TweenLite.to(item.values, tween_duration, val)
            propertyTimeline.add(tween, tween_time)


            for key, key_index in property.keys
              if key_index < property.keys.length - 1
                next_key = property.keys[key_index + 1]
                tween_duration = next_key.time - key.time

                val = {}
                val[propName] = next_key.val
                tween = TweenLite.to(item.values, tween_duration, val)
                propertyTimeline.add(tween, key.time)

            item.timeline.add(propertyTimeline, 0)

          # force main timeline to refresh
          seconds = seconds - 0.0000001
        #if item.values then console.log item.values.percent

        # Create the item
        if should_exist && !item.object
          type = item.type
          el = @factory.create(type, item.values, seconds - item.start)
          @scene.add(el.container)
          item.object = el

        # If this is a camera set it as the active camera.
        if item.object && item.object.isCamera
          activeCamera = item.object.container
          window.updateCameraAspect(activeCamera)

        # Update the item
        if item.object then item.object.update(seconds - item.start, item.values)

      # Set correct camera
      window.activeCamera = activeCamera
      if window.renderModel
        window.renderModel.camera = activeCamera

      # Finally update the main timeline.
      @mainTimeline.seek(seconds)

