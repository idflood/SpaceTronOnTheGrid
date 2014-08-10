define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'
  Signals = require 'Signal'

  Utils = require 'cs!timeline/components/Utils'
  Header = require 'cs!timeline/components/Header'
  TimeIndicator = require 'cs!timeline/components/TimeIndicator'

  Items = require 'cs!timeline/components/Items'
  Properties = require 'cs!timeline/components/Properties'
  Keys = require 'cs!timeline/components/Keys'

  extend = (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  class Timeline
    constructor: () ->
      @app = window.app
      @isDirty = true
      @onSelect = new Signals.Signal()
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
        .tickFormat(Utils.formatMinutes)

      @svg = d3.select('.editor__time-main').append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", 600)
        #.attr("height", height + margin.top + margin.bottom)
      @svgContainer = @svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      @linesContainer = @svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + (margin.top + 10) + ")")

      @header = new Header(@app, @timer, @initialDomain, width)
      @timeIndicator = new TimeIndicator(this, @svgContainer)

      @items = new Items(this, @linesContainer)
      @items.onUpdate.add () => @isDirty = true
      # Propagate onSelect event.
      @items.onSelect.add (d) => @onSelect.dispatch(d)
      @properties = new Properties(this)
      @properties.onKeyAdded.add () => @isDirty = true
      @keys = new Keys(this)
      @keys.onKeyUpdated.add () => @isDirty = true

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

      @header.onBrush.add (extent) =>
        @x.domain(extent)
        xGrid.call(xAxisGrid)
        xAxisElement.call(xAxis)
        @isDirty = true

      # First render
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
        @header.resize(INNER_WIDTH)

    render: () =>
      @header.render()
      @timeIndicator.render()

      if @isDirty
        # No need to call this on each frames, but only on brush, key drag, ...
        bar = @items.render()
        properties = @properties.render(bar)
        @keys.render(properties)
        @isDirty = false

      window.requestAnimationFrame(@render)