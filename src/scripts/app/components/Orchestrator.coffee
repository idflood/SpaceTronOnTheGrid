define (require) ->
  ElementFactory = require 'cs!app/components/ElementFactory'

  TweenMax = require 'TweenMax'
  TimelineMax = require 'TimelineMax'

  class Orchestrator
    constructor: (@timer, @data, @scene) ->
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
      seconds = timestamp / 1000

      #return false
      for item in @data
        should_exist = if seconds >= item.start && seconds <= item.end then true else false

        # create the values object to contain all properties
        if !item.values && item.properties.length
          item.values = {}
          for property in item.properties
            # Take the value of the first key as initial value.
            # @todo: update this when the value of the first key change. (when rebuilding the timeline, simply delete item.values before item.timeline)
            item.values[property.name] = property.keys[0].val


        # Create the timeline if needed
        if !item.timeline
          item.timeline = new TimelineMax()
          @mainTimeline.add(item.timeline)
          item.isDirty = true

        if item.timeline and item.isDirty
          item.isDirty = false
          item.timeline.clear()

          for property in item.properties
            propertyTimeline = new TimelineMax()
            propName = property.name
            for key, key_index in property.keys
              if key_index < property.keys.length - 1
                next_key = property.keys[key_index + 1]
                tween_duration = next_key.time - key.time
                tween_value = next_key.val
                #console.log "add tween: " + propName
                #console.log {duration: tween_duration, val: tween_value, time: key.time}
                val = {}
                val[propName] = tween_value
                tween = TweenLite.to(item.values, tween_duration, val)
                propertyTimeline.add(tween, key.time)
            item.timeline.add(propertyTimeline)

        #if item.values then console.log item.values.percent

        # Create the item
        if should_exist && !item.object
          el = @factory.create('Circles', item.options)
          @scene.add(el.container)
          item.object = el

        # Remove the item
        if item.object && should_exist == false
          @scene.remove(item.object.container)
          item.object.destroy()
          delete item.object

        # Update the item
        if item.object then item.object.update(seconds - item.start, item.values)

      # Finally update the main timeline.
      @mainTimeline.seek(seconds)
