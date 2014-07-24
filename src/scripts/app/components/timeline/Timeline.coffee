define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'

  TimelineHeader = require 'cs!app/components/Timeline/TimelineHeader'
  TimelineUtils = require 'cs!app/components/Timeline/TimelineUtils'

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

      # First render
      window.requestAnimationFrame(@render)

      window.onresize = () =>
        INNER_WIDTH = window.innerWidth
        width = INNER_WIDTH - margin.left - margin.right
        @svg.attr("width", width + margin.left + margin.right)
        @x.range([0, width])

        xGrid.call(xAxisGrid)
        xAxisElement.call(xAxis)
        @timelineHeader.resize(INNER_WIDTH)

    render: () =>
      @timelineHeader.render()
      @renderTimeIndicator()

      bar = @renderLines()
      @renderProperties(bar)
      @renderKeys()

      window.requestAnimationFrame(@render)

    renderTimeIndicator: () =>
      timeSelection = @svgContainer.selectAll('.time-indicator').data(@currentTime)
      timeGrp = timeSelection.enter().append("g")
        .attr('class', "time-indicator")

      timeGrp.append('rect')
        .attr('class', 'time-indicator__line')
        .attr('x', -1)
        .attr('y', 0)
        .attr('width', 1)
        .attr('height', 1000)

      timeSelection = @svgContainer.selectAll('.time-indicator')
      timeSelection.attr('transform', 'translate(' + (@x(@currentTime[0]) + 0.5) + ', -' + @margin.top + ')')

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

      dragmoveLeft = (d) ->
        d3.event.sourceEvent.stopPropagation()
        dx = self.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.start)
        d.start += diff
        d.isDirty = true

      dragmoveRight = (d) ->
        d3.event.sourceEvent.stopPropagation()
        dx = self.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.end)
        d.end += diff
        d.isDirty = true

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
      bar = @svgContainer.selectAll(".line-grp")
        .data(@app.data, (d) -> d.id)

      barEnter = bar.enter()
        .append('g').attr('class', 'line-grp')

      barEnter.append("rect")
        .attr("class", "bar")
        .attr("y", 3)
        .attr("height", 14)

      barEnter.append("rect")
        .attr("class", "bar-anchor bar-anchor--left")
        .attr("y", 2)
        .attr("height", 16)
        .attr("width", 6)
        .call(dragLeft)

      barEnter.append("rect")
        .attr("class", "bar-anchor bar-anchor--right")
        .attr("y", 2)
        .attr("height", 16)
        .attr("width", 6)
        .call(dragRight)

      self.dy = 10 + @margin.top
      bar.attr "transform", (d, i) ->
        numProperties = if d.properties then d.properties.length else 0
        y = self.dy
        self.dy += (numProperties + 1) * self.lineHeight

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

      barEnter.append("rect")
        .attr("class", "graph-mask")
        .attr("x", -self.margin.left)
        .attr("y", 1)
        .attr("width", self.margin.left)
        .attr("height", self.lineHeight - 2)

      barEnter.append("text")
        .attr("class", "line--label")
        .attr("x", self.label_position_x)
        .attr("y", 16)
        .text((d) -> d.label)

      barEnter.append("line")
        .attr("class", 'line--separator')
        .attr("x1", -200)
        .attr("x2", self.x(self.timer.totalDuration + 100))
        .attr("y1", self.lineHeight)
        .attr("y2", self.lineHeight)

      bar.exit().remove()

      return bar

    renderProperties: (bar) ->
      self = this
      # Properties
      propVal = (d,i) -> d.properties
      propKey = (d) -> d.name
      self.properties = bar.selectAll('.line--sub').data(propVal, propKey)

      subGrp = self.properties.enter().append('g')
        .attr("class", 'line--sub')
        .attr "transform", (d, i) ->
          sub_height = (i + 1) * self.lineHeight
          return "translate(0," + sub_height + ")"

      sortKeys = (keys) -> keys.sort((a, b) -> d3.ascending(a.time, b.time))

      subGrp.append('rect')
        .attr('class', 'click-handler click-handler--property')
        .attr('x', 0)
        .attr('y', 0)
        .attr('width', self.x(self.timer.totalDuration + 100))
        .attr('height', self.lineHeight)
        .on 'dblclick', (d) ->
          lineObject = this.parentNode.parentNode
          lineValue = d3.select(lineObject).datum()
          def = if d.default then d.default else 0
          mouse = d3.mouse(this)
          dx = self.x.invert(mouse[0])
          dx = dx.getTime() / 1000
          newKey = {time: dx, val: def}
          d.keys.push(newKey)
          # Sort the keys for tweens creation
          d.keys = sortKeys(d.keys)

          lineValue.isDirty = true

      subGrp.append('g').attr('class','keys--wrapper')

      subGrp.append("rect")
        .attr("class", "graph-mask")
        .attr("x", -self.margin.left)
        .attr("y", 1)
        .attr("width", self.margin.left)
        .attr("height", self.lineHeight - 2)

      subGrp.append('text')
        .attr("class", "line--label line--label-small")
        .attr("x", self.label_position_x)
        .attr("y", 15)
        .text (d) ->
          d.name

      subGrp.append("line")
        .attr("class", 'line--separator-secondary')
        .attr("x1", -200)
        .attr("x2", self.x(self.timer.totalDuration + 100))
        .attr("y1", self.lineHeight)
        .attr("y2", self.lineHeight)

    renderKeys: () ->
      self = this

      sortKeys = (keys) -> keys.sort((a, b) -> d3.ascending(a.time, b.time))

      dragmove = (d) ->
        propertyObject = this.parentNode.parentNode
        lineObject = propertyObject.parentNode.parentNode
        propertyData = d3.select(propertyObject).datum()
        lineData = d3.select(lineObject).datum()

        currentDomainStart = self.x.domain()[0]
        mouse = d3.mouse(this)
        dx = self.x.invert(mouse[0])
        dx = dx.getTime()
        d.time += dx / 1000 - currentDomainStart / 1000

        propertyData.keys = sortKeys(propertyData.keys)
        lineData.isDirty = true

      drag = d3.behavior.drag()
        .origin((d) -> return d;)
        .on("drag", dragmove)

      propValue = (d,i,j) -> d.keys
      propKey = (d, k) -> d.time
      keys = @properties.select('.keys--wrapper').selectAll('.key').data(propValue, propKey)

      selectKey = (d) ->
        propertyObject = this.parentNode.parentNode
        lineObject = propertyObject.parentNode.parentNode
        lineData = d3.select(lineObject).datum()

        if window.gui then window.gui.destroy()
        gui = new dat.GUI()
        controller = gui.add(d, "val")
        controller.onChange (v) -> lineData.isDirty = true
        window.gui = gui

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
          dx = self.x(d.time * 1000) + 3
          dy = 9
          return "translate(" + dx + "," + dy + ")"
      keys.exit().remove()
