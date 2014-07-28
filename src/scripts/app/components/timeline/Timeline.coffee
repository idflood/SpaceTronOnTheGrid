define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'

  TimelineHeader = require 'cs!app/components/Timeline/TimelineHeader'
  TimelineUtils = require 'cs!app/components/Timeline/TimelineUtils'

  TimelineItems = require 'cs!app/components/Timeline/TimelineItems'
  TimelineProperties = require 'cs!app/components/Timeline/TimelineProperties'
  TimelineKeys = require 'cs!app/components/Timeline/TimelineKeys'

  extend = (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  class Timeline
    constructor: () ->
      @app = window.app
      @timer = @app.timer
      @currentTime = @timer.time
      @initialDomain = [0, @timer.totalDuration - 220 * 1000]
      margin = {top: 6, right: 20, bottom: 0, left: 190}
      this.margin = margin

      width = window.innerWidth - margin.left - margin.right
      height = 270 - margin.top - margin.bottom - 40
      @lineHeight = 20
      @label_position_x = -170

      @x = d3.time.scale().range([0, width])
      @x.domain(@initialDomain)

      xAxis = d3.svg.axis()
        .scale(@x)
        .orient("top")
        .tickSize(-height, 0)
        .tickFormat(TimelineUtils.formatMinutes)

      @svg = d3.select('.editor__time-main').append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", 600)
        #.attr("height", height + margin.top + margin.bottom)
      @svgContainer = @svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      @linesContainer = @svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + (margin.top + 10) + ")")

      @timelineHeader = new TimelineHeader(@app, @timer, @initialDomain, width)

      @timelineItems = new TimelineItems(this, @linesContainer)
      @timelineItems.onUpdate.add(@renderElements)
      @timelineProperties = new TimelineProperties(this)
      @timelineProperties.onKeyAdded.add(@renderElements)
      @timelineKeys = new TimelineKeys(this)
      @timelineKeys.onKeyUpdated.add(@renderElements)

      xAxisGrid = d3.svg.axis()
        .scale(@x)
        .ticks(100)
        .tickSize(-height, 0)
        .tickFormat("")
        .orient("top")

      xGrid = @svgContainer.append('g')
        .attr('class', 'x axis grid')
        .attr("transform", "translate(0," + margin.top + ")")
        .call(xAxisGrid)

      xAxisElement = @svgContainer.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + margin.top + ")")
        .call(xAxis)

      @timelineHeader.onBrush.add (extent) =>
        @x.domain(extent)
        xGrid.call(xAxisGrid)
        xAxisElement.call(xAxis)
        @renderElements()

      # First render
      @renderElements()
      window.requestAnimationFrame(@render)

      window.onresize = () =>
        INNER_WIDTH = window.innerWidth
        width = INNER_WIDTH - margin.left - margin.right
        @svg.attr("width", width + margin.left + margin.right)
        @svg.selectAll('.timeline__right-mask')
          .attr('width', INNER_WIDTH)
        @x.range([0, width])

        xGrid.call(xAxisGrid)
        xAxisElement.call(xAxis)
        @timelineHeader.resize(INNER_WIDTH)

    render: () =>
      @timelineHeader.render()
      @renderTimeIndicator()

      window.requestAnimationFrame(@render)

    renderElements: () =>
      # No need to call this on each frames, but only on brush, key drag, ...
      bar = @timelineItems.render()
      properties = @timelineProperties.render(bar)
      @timelineKeys.render(properties)

    renderTimeIndicator: () =>
      timeSelection = @svgContainer.selectAll('.time-indicator').data(@currentTime)
      timeGrp = timeSelection.enter().append("svg")
        .attr('class', "time-indicator timeline__right-mask")
        .attr('width', window.innerWidth - @label_position_x)
        .attr('height', 442)

      timeSelection = timeGrp.append('rect')
        .attr('class', 'time-indicator__line')
        .attr('x', -1)
        .attr('y', -@margin.top)
        .attr('width', 1)
        .attr('height', 1000)

      timeSelection = @svgContainer.selectAll('.time-indicator rect')
      timeSelection.attr('x', @x(@currentTime[0]) - 0.5)
      #timeSelection.attr('transform', 'translate(' + (@x(@currentTime[0]) - 0.5) + ', -' + @margin.top + ')')
