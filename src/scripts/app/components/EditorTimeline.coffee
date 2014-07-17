define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'

  class EditorTimeline
    constructor: () ->
      @app = window.app
      @timer = @app.timer
      @currentTime = @timer.time


      margin = {top: 15, right: 20, bottom: 0, left: 190}
      width = window.innerWidth - margin.left - margin.right
      height = 270 - margin.top - margin.bottom
      @lineHeight = 20
      @label_position_x = -170
      @dy = 10 + margin.top

      @x = d3.time.scale().range([0, width])
      #@x = d3.scale.linear().range([0, width])
      @x.domain([0, @timer.totalDuration - 220 * 1000])

      xAxis = d3.svg.axis()
        .scale(@x)
        .orient("top")
        .tickSize(-height, 0)
        #.tickFormat(d3.time.format("%S %L"))
        .tickFormat(@formatMinutes)

      #@svg = d3.select($timeline.get(0)).append("svg")
      @svg = d3.select('.editor__time-main').append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      xAxisGrid = d3.svg.axis()
        .scale(@x)
        .ticks(100)
        .tickSize(-height, 0)
        .tickFormat("")
        .orient("top")

      xGrid = @svg.append('g')
        .attr('class', 'x axis grid')
        .attr("transform", "translate(0," + margin.top + ")")
        .call(xAxisGrid)

      @svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + margin.top + ")")
        .call(xAxis)

      self = this
      dragTimeMove = (d) ->
        d3.event.sourceEvent.stopPropagation()
        dx = self.x.invert(d3.event.sourceEvent.x - margin.left)
        dx = dx.getTime()
        dx = Math.max(0, dx)
        self.currentTime[0] = dx
        #self.render()

      dragTime = d3.behavior.drag()
        .origin((d) -> return d;)
        .on("drag", dragTimeMove)

      timeSelection = @svg.selectAll('.time-indicator').data(@currentTime)

      timeGrp = timeSelection.enter().append("g")
        .attr('class', "time-indicator")
        .call(dragTime)
      timeGrp.append('rect')
        .attr('class', 'time-indicator__line')
        .attr('x', -1)
        .attr('y', 0)
        .attr('width', 1)
        .attr('height', 1000)
      timeGrp.append('path')
        .attr('class', 'time-indicator__handle')
        .attr('d', 'M -10 0 L 0 10 L 10 0 L -10 0')

      # First render
      #@render()
      window.requestAnimationFrame(@render)

    render: () =>
      bar = @renderLines()
      @renderTimeIndicator()
      @renderProperties(bar)
      @renderKeys()
      window.requestAnimationFrame(@render)

    renderTimeIndicator: () ->
      timeSelection = @svg.selectAll('.time-indicator')
      timeSelection.attr('transform', 'translate(' + (@x(@currentTime[0]) + 0.5) + ', -12)')


    renderLines: () ->
      self = this
      dragOffset = 0
      dragstart = (d) ->
        mouse = d3.mouse(this)
        mouseX = mouse[0]
        dragOffset = self.x(d.start) * 1000 - mouseX
        #dragOffset = mouseX

      dragmove = (d) ->
        mouse = d3.mouse(this)
        dx = self.x.invert(mouse[0] + dragOffset)
        dx = dx.getTime() / 1000
        dx = Math.max(0, dx)

        diff = (dx - d.start)
        d.start += diff
        d.end += diff

        for prop in d.properties
          for key in prop.keys
            key.time += diff
        #self.render()

      drag = d3.behavior.drag()
        .origin((d) -> return d;)
        .on("drag", dragmove)
        .on("dragstart", dragstart)

      bar_border = 1
      bar = @svg.selectAll(".line-grp")
        .data(@app.data, (d) -> d.id)

      barEnter = bar.enter()
        .append('g').attr('class', 'line-grp')
        .attr "transform", (d, i) ->
          numProperties = if d.properties then d.properties.length else 0
          y = self.dy
          self.dy += ((i + 1) + numProperties) * self.lineHeight

          return "translate(0," + y + ")"

      barEnter.append("rect")
        .attr("class", "bar")
        .attr("y", 3)
        .attr("height", 14)

      bar.selectAll('.bar')
        .attr("x", (d) -> return self.x(d.start * 1000) + bar_border)
        .attr("width", (d) -> return self.x((d.end - d.start) * 1000) - bar_border)
        .call(drag)

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

      subGrp.append('rect')
        .attr('class', 'click-handler click-handler--property')
        .attr('x', 0)
        .attr('y', 0)
        .attr('width', self.x(self.timer.totalDuration + 100))
        .attr('height', self.lineHeight)
        .on 'dblclick', (d) ->
          mouse = d3.mouse(this)
          dx = self.x.invert(mouse[0])
          dx = dx.getTime() / 1000
          newKey = {time: dx, val: 42}
          d.keys.push(newKey)
          #self.render()


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

      dragmove = (d) ->
        mouse = d3.mouse(this)
        dx = self.x.invert(mouse[0])
        dx = dx.getTime()
        d.time += dx / 1000
        #self.render()

      drag = d3.behavior.drag()
        .origin((d) -> return d;)
        .on("drag", dragmove)

      propValue = (d,i,j) -> d.keys
      propKey = (d, k) ->
        return k
      keys = @properties.selectAll('.key').data(propValue, propKey)

      key_size = 6
      keys.enter()
        .append('g')
        .attr('class', 'key')
        .append('g')
        .attr('class', 'key__item')
        .call(drag)
        .append('rect')
        .attr('x', -3)
        .attr('width', key_size)
        .attr('height', key_size)
        .attr('class', 'line--key')
        .attr('transform', 'rotate(45)')

      keys.selectAll('.key__item')
        .attr 'transform', (d) ->
          dx = self.x(d.time) * 1000 + 3
          dy = 9
          return "translate(" + dx + "," + dy + ")"

      keys.exit().remove()

    formatMinutes: (d) ->
      # convert milliseconds to seconds
      d = d / 1000
      hours = Math.floor(d / 3600)
      minutes = Math.floor((d - (hours * 3600)) / 60)
      seconds = d - (minutes * 60)
      output = seconds + "s"
      output = minutes + "m " + output  if minutes
      output = hours + "h " + output  if hours
      return output
