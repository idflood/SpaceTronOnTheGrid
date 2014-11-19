define (require) ->
  d3 = require 'd3'
  Signals = require 'Signal'
  Utils = require 'cs!TweenTime/core/Utils'

  class Properties
    constructor: (@timeline) ->
      @onKeyAdded = new Signals.Signal()

    render: (bar) ->
      self = this

      propVal = (d,i) -> if d.properties then d.properties else []
      propKey = (d) -> d.name
      visibleProperties = (d) -> d.keys.length

      properties = bar.selectAll('.line--sub').data(propVal, propKey)

      dy = 0
      subGrp = properties.enter()
        .append('g')
        .filter(visibleProperties)
        .attr("class", 'line--sub')

      properties.filter(visibleProperties)
        .attr "transform", (d, i) ->
          sub_height = (i + 1) * self.timeline.lineHeight
          return "translate(0," + sub_height + ")"

      sortKeys = (keys) -> keys.sort((a, b) -> d3.ascending(a.time, b.time))

      subGrp.append('rect')
        .attr('class', 'click-handler click-handler--property')
        .attr('x', 0)
        .attr('y', 0)
        .attr('width', self.timeline.x(self.timeline.timer.totalDuration + 100))
        .attr('height', self.timeline.lineHeight)
        .on 'dblclick', (d) ->
          lineObject = this.parentNode.parentNode
          lineValue = d3.select(lineObject).datum()
          def = if d.default then d.default else 0
          mouse = d3.mouse(this)
          dx = self.timeline.x.invert(mouse[0])
          dx = dx.getTime() / 1000
          prevKey = Utils.getPreviousKey(d.keys, dx)
          # set the value to match the previous key if we found one
          if prevKey then def = prevKey.val
          newKey = {time: dx, val: def}
          d.keys.push(newKey)
          # Sort the keys for tweens creation
          d.keys = sortKeys(d.keys)

          lineValue.isDirty = true
          self.onKeyAdded.dispatch()

      # Errors
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

      # Mask
      subGrp.append('svg')
        .attr('class','keys--wrapper timeline__right-mask')
        .attr('width', window.innerWidth - self.timeline.label_position_x)
        .attr('height', self.timeline.lineHeight)
        .attr('fill', '#f00')

      subGrp.append('text')
        .attr("class", "line--label line--label-small")
        .attr("x", self.timeline.label_position_x + 30)
        .attr("y", 15)
        .text (d) ->
          d.name

      subGrp.append("line")
        .attr("class", 'line--separator-secondary')
        .attr("x1", -200)
        .attr("x2", self.timeline.x(self.timeline.timer.totalDuration + 100))
        .attr("y1", self.timeline.lineHeight)
        .attr("y2", self.timeline.lineHeight)

      bar.selectAll('.line--sub').attr('display', (d) ->
          lineObject = this.parentNode
          lineValue = d3.select(lineObject).datum()
          return if !lineValue.collapsed then "block" else "none"
        )

      return properties
