define (require) ->
  _ = require 'lodash'
  Signals = require 'Signal'

  class SceneManager
    constructor: (@timer, @data, @scene, @defaultCamera, @factory) ->
      @timer.updated.add(@update)
      @update(0)

    update: (timestamp) =>
      activeCamera = @defaultCamera
      seconds = timestamp / 1000

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
