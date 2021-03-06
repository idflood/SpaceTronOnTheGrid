define (require) ->
  _ = require 'lodash'
  Signals = require 'js-signals'

  class SceneManager
    constructor: (@tweenTime, @data, @scene, @defaultCamera, @factory) ->
      @timer = @tweenTime.timer
      @timer.updated.add(@update)
      @update(0)

    update: (timestamp) =>
      activeCamera = @defaultCamera
      seconds = timestamp / 1000

      for item in @data
        should_exist = if seconds >= item.start && seconds <= item.end then true else false

        # Create the item
        if !item.object
          type = item.type
          el = @factory.create(type, item.values, seconds - item.start)
          # Save reference to the custom object class in data
          item.object = el
          # And a reference to the data from the 3d container
          if el.container
            el.container._data = item

        # Remove the item from the scene
        if (item.object && should_exist == false) || item.isDirtyObject
          item.isDirtyObject = false
          if item.object && item.object.container && item.object.container.parent
            @scene.remove(item.object.container)
            #item.object.destroy()
            #delete item.object

        # Assign the object class to be able to access all object properties in propertiesEditor
        if !item.classObject then item.classObject = @factory.getTypeClass(item.type)

        # If object doesn't exist skip the update.
        #if should_exist == false then continue


        # Add item to scene if it exists.
        if should_exist && item.object.container && !item.object.container.parent
          @scene.add(item.object.container)

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
