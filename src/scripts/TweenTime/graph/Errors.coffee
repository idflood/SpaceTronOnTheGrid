define (require) ->
  d3 = require 'd3'
  Signals = require 'Signal'
  Utils = require 'cs!TweenTime/core/Utils'

  class Errors
    constructor: (@timeline) ->

    render: (properties) ->
      self = this
      subGrp = self.timeline.properties.subGrp
      propertiesWithError = (d) -> d.errors?
      errorsGrp = subGrp.append('svg')
        .attr('class','property__errors')
        .attr('width', window.innerWidth - self.timeline.label_position_x)
        .attr('height', self.timeline.lineHeight)
      errorsValue = (d,i,j) -> d.errors
      errorTime = (d, k) -> d.time
      errors = properties.filter(propertiesWithError).select('.property__errors').selectAll('.error').data(errorsValue, errorTime)
      errors.enter().append('rect')
        .attr('class', 'error')
        .attr('width', 4)
        .attr('height', self.timeline.lineHeight)
        .attr('fill', '#CF3938')
        .attr('y', '1')

      properties.selectAll('.error')
        .attr 'x', (d) ->
          dx = self.timeline.x(d.time * 1000)
          return dx

      errors.exit().remove()
