define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'

  TimelineHeader = require 'cs!app/components/Timeline/TimelineHeader'
  TimelineUtils = require 'cs!app/components/Timeline/TimelineUtils'

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
      @dy = 10 + margin.top

      @timelineHeader = new TimelineHeader(@app, @timer, @initialDomain, width)
      @timelineProperties = new TimelineProperties(this)
      @timelineProperties.onKeyAdded.add(@renderElements)

      @timelineKeys = new TimelineKeys(this)
      @timelineKeys.onKeyUpdated.add(@renderElements)

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
      bar = @renderLines()
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

    renderLines: () ->
      self = this

      selectBar = (d) ->
        # Merge attributes with existing ones on click, so if we add
        # an attribute we don't have to edit the json manually to allow
        # existing object to use it.
        # todo: find a way to get the value as current time (at time between previous and next key)
        factory = window.ElementFactory
        el_type = factory.elements[d.type]
        if el_type
          d.options = extend(el_type.default_attributes(), d.options)
        if window.gui then window.gui.destroy()
        gui = new dat.GUI()
        for key, value of d.options
          controller = gui.add(d.options, key)
          controller.onChange (v) -> d.isDirtyObject = true
        window.gui = gui

      dragmove = (d) ->
        dx = self.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.start)
        d.start += diff
        d.end += diff
        for prop in d.properties
          for key in prop.keys
            key.time += diff

        d.isDirty = true
        self.renderElements()

      dragmoveLeft = (d) ->
        d3.event.sourceEvent.stopPropagation()
        dx = self.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.start)
        d.start += diff
        d.isDirty = true
        self.renderElements()

      dragmoveRight = (d) ->
        d3.event.sourceEvent.stopPropagation()
        dx = self.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.end)
        d.end += diff
        d.isDirty = true
        self.renderElements()

      dragLeft = d3.behavior.drag()
        .origin((d) ->
          t = d3.select(this)
          return {x: t.attr('x'), y: t.attr('y')})
        .on("drag", dragmoveLeft)

      dragRight = d3.behavior.drag()
        .origin((d) ->
          t = d3.select(this)
          return {x: t.attr('x'), y: t.attr('y')})
        .on("drag", dragmoveRight)

      drag = d3.behavior.drag()
        .origin((d) ->
          t = d3.select(this)
          return {x: t.attr('x'), y: t.attr('y')})
        .on("drag", dragmove)

      bar_border = 1
      bar = @linesContainer.selectAll(".line-grp")
        .data(@app.data, (d) -> d.id)

      barEnter = bar.enter()
        .append('g').attr('class', 'line-grp')

      barContainerRight = barEnter.append('svg')
        .attr('class', 'timeline__right-mask')
        .attr('width', window.innerWidth - self.label_position_x)
        .attr('height', self.lineHeight)

      barContainerRight.append("rect")
        .attr("class", "bar")
        .attr("y", 3)
        .attr("height", 14)

      barContainerRight.append("rect")
        .attr("class", "bar-anchor bar-anchor--left")
        .attr("y", 2)
        .attr("height", 16)
        .attr("width", 6)
        .call(dragLeft)

      barContainerRight.append("rect")
        .attr("class", "bar-anchor bar-anchor--right")
        .attr("y", 2)
        .attr("height", 16)
        .attr("width", 6)
        .call(dragRight)

      self.dy = 10 + @margin.top
      bar.attr "transform", (d, i) ->
        y = self.dy
        self.dy += self.lineHeight
        if !d.collapsed
          numProperties = if d.properties then d.properties.length else 0
          self.dy += numProperties * self.lineHeight

        return "translate(0," + y + ")"

      bar.selectAll('.bar-anchor--left')
        .attr("x", (d) -> return self.x(d.start * 1000) - 1)

      bar.selectAll('.bar-anchor--right')
        .attr("x", (d) -> return self.x(d.end * 1000) - 1)

      bar.selectAll('.bar')
        .attr("x", (d) -> return self.x(d.start * 1000) + bar_border)
        .attr("width", (d) ->
          return Math.max(0, (self.x(d.end) - self.x(d.start)) * 1000 - bar_border)
        )
        .call(drag)
        .on("click", selectBar)

      barEnter.append("text")
        .attr("class", "line--label")
        .attr("x", self.label_position_x + 10)
        .attr("y", 16)
        .text((d) -> d.label)

      self = this
      barEnter.append("text")
        .attr("class", "line__toggle")
        .attr("x", self.label_position_x - 10)
        .attr("y", 16)
        .on 'click', (d) ->
          d.collapsed = !d.collapsed
          self.renderElements()

      bar.selectAll(".line__toggle")
        .text((d) -> if d.collapsed then "▸" else"▾")

      barEnter.append("line")
        .attr("class", 'line--separator')
        .attr("x1", -200)
        .attr("x2", self.x(self.timer.totalDuration + 100))
        .attr("y1", self.lineHeight)
        .attr("y2", self.lineHeight)

      bar.exit().remove()

      return bar
