define (require) ->
  $ = require 'jquery'
  tpl_timeline = require 'text!modules/templates/timeline.tpl.html'

  class Editor
    constructor: () ->
      @app = window.app

      $timeline = $(tpl_timeline)
      $('body').append($timeline)
