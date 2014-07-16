define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'
  tpl_timeline = require 'text!modules/templates/timeline.tpl.html'

  class Editor
    constructor: () ->
      @app = window.app

      $timeline = $(tpl_timeline)
      $('body').append($timeline)
