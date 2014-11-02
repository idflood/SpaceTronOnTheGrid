define (require) ->
  d3 = require 'd3'
  Signals = require 'Signal'
  Utils = require 'cs!timeline/components/Utils'

  class Keys
    constructor: (@timeline) ->
      # console.log "test2"
      @onKeyUpdated = new Signals.Signal()

    render: (properties) ->
      self = this

      sortKeys = (keys) -> keys.sort((a, b) -> d3.ascending(a.time, b.time))

      dragmove = (d) ->
        sourceEvent = d3.event.sourceEvent
        propertyObject = this.parentNode.parentNode
        lineObject = propertyObject.parentNode.parentNode
        propertyData = d3.select(propertyObject).datum()
        lineData = d3.select(lineObject).datum()

        currentDomainStart = self.timeline.x.domain()[0]
        mouse = d3.mouse(this)
        dx = self.timeline.x.invert(mouse[0])
        dx = dx.getTime()
        dx = dx / 1000 - currentDomainStart / 1000
        dx = d.time + dx

        timeMatch = false
        if sourceEvent.shiftKey
          timeMatch = Utils.getClosestTime(dx, lineData.id, propertyData.name)
        if !timeMatch
          timeMatch = dx

        d.time = timeMatch
        propertyData.keys = sortKeys(propertyData.keys)
        lineData.isDirty = true
        self.onKeyUpdated.dispatch()

      drag = d3.behavior.drag()
        .origin((d) -> return d;)
        .on("drag", dragmove)

      propValue = (d,i,j) -> d.keys
      propKey = (d, k) -> d.time
      keys = properties.select('.keys--wrapper').selectAll('.key').data(propValue, propKey)

      selectKey = (d) ->
        propertyObject = this.parentNode.parentNode
        lineObject = propertyObject.parentNode.parentNode
        lineData = d3.select(lineObject).datum()
        propertyData = d3.select(propertyObject).datum()

        self.timeline.onSelect.dispatch(lineData, d, propertyData)

      key_size = 6
      keys.enter()
        .append('g')
        .attr('class', 'key')
        .append('g')
        .attr('class', 'key__item')
        .call(drag)
        .on('click', selectKey)
        .append('rect')
        .attr('x', -3)
        .attr('width', key_size)
        .attr('height', key_size)
        .attr('class', 'line--key')
        .attr('transform', 'rotate(45)')

      keys.selectAll('.key__item')
        .attr 'transform', (d) ->
          dx = self.timeline.x(d.time * 1000) + 3
          dy = 9
          return "translate(" + dx + "," + dy + ")"
      keys.exit().remove()
