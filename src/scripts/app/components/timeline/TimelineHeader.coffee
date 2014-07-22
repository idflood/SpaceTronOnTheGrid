define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'

  Signals = require 'Signal'
  TimelineUtils = require 'cs!app/components/Timeline/TimelineUtils'

  class TimelineHeader
    constructor: (@app, @timer, initialDomain, width) ->
      @onBrush = new Signals.Signal()
      @margin = {top: 10, right: 20, bottom: 0, left: 190}
      height = 50 - @margin.top - @margin.bottom

      @x = d3.time.scale().range([0, width])
      @x.domain([0, @timer.totalDuration])

      @xAxis = d3.svg.axis()
        .scale(@x)
        .orient("top")
        .tickSize(-5, 0)
        .tickFormat(TimelineUtils.formatMinutes)

      @svg = d3.select('.editor__time-header').append("svg")
        .attr("width", width + @margin.left + @margin.right)
        .attr("height", 30)
      @svgContainer = @svg.append("g")
        .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")

      @xAxisElement = @svgContainer.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (@margin.top + 7) + ")")
        .call(@xAxis)

      onBrush = () =>
        extent0 = @brush.extent()
        @onBrush.dispatch(extent0)

      @brush = d3.svg.brush()
        .x(@x)
        .extent(initialDomain)
        .on("brush", onBrush)

      gBrush = @svgContainer.append("g")
        .attr("class", "brush")
        .call(@brush)
        .selectAll("rect")
        .attr('height', 20)

    resize: (width) =>
      width = width - @margin.left - @margin.right
      @svg.attr("width", width + @margin.left + @margin.right)

      @x.range([0, width])
      @xAxisElement.call(@xAxis)

