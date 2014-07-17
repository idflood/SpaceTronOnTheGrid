# References:
#
# d3.js drag/add
# http://stackoverflow.com/questions/19911514/how-can-i-click-to-add-or-drag-in-d3
#
# d3.js brush (show only a portion of time)
# http://bl.ocks.org/bunkat/1962173
#
# d3.js drag date items
# http://codepen.io/Problematic/pen/mskwj
#
# Soundjs
# http://www.createjs.com/#!/SoundJS/documentation
# http://www.createjs.com/Docs/SoundJS/modules/SoundJS.html
#
# Soundjs music visualizer
# https://github.com/CreateJS/SoundJS/blob/master/examples/MusicVisualizer.html
define (require) ->
  $ = require 'jquery'

  tpl_timeline = require 'text!app/templates/timeline.tpl.html'
  EditorTimeline = require 'cs!app/components/EditorTimeline'


  class Editor
    constructor: () ->
      @app = window.app

      $timeline = $(tpl_timeline)
      $('body').append($timeline)

      @timeline = new EditorTimeline()
