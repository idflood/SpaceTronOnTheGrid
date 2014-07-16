# References:
#
# d3.js drag/add
# http://stackoverflow.com/questions/19911514/how-can-i-click-to-add-or-drag-in-d3
#
# d3.js brush (show only a portion of time)
# http://bl.ocks.org/bunkat/1962173
#
# d3.js drag date items
# http://codepen.io/Problematic/pen/mskwj
define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'
  tpl_timeline = require 'text!modules/templates/timeline.tpl.html'

  class Editor
    constructor: () ->
      @app = window.app

      $timeline = $(tpl_timeline)
      $('body').append($timeline)

      margin = {top: 15, right: 20, bottom: 30, left: 190}
      width = window.innerWidth - margin.left - margin.right
      height = 270 - margin.top - margin.bottom
      lineHeight = 20
      label_position_x = -170

      data = [
        {label: "object 1", start: 15, end: 20, properties: [
          {name: "opacity", keys: [{time: 15, val: 0}, {time: 17, val: 0.8}]},
          {name: "quantity", keys: [{time: 15, val: 10}, {time: 20, val: 15}]}
        ]},
        {label: "object 2", start: 60, end: 142, properties: [
          {name: "opacity", keys: [{time: 60, val: 0}, {time: 72, val: 0.3}]}
        ]},
      ]



      x = d3.time.scale()
        .range([0, width])

      x.domain([0, 240])

      formatMinutes = (d) ->
        hours = Math.floor(d / 3600)
        minutes = Math.floor((d - (hours * 3600)) / 60)
        seconds = d - (minutes * 60)
        output = seconds + "s"
        output = minutes + "m " + output  if minutes
        output = hours + "h " + output  if hours
        return output

      xAxis = d3.svg.axis()
        .scale(x)
        .orient("top")
        .tickSize(-height, 0)
        .tickFormat(formatMinutes)

      svg = d3.select($timeline.get(0)).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      xAxisGrid = d3.svg.axis()
        .scale(x)
        .ticks(40)
        .tickSize(-height, 0)
        .tickFormat("")
        .orient("top")

      xGrid = svg.append('g')
        .attr('class', 'x axis grid')
        .attr("transform", "translate(0," + margin.top + ")")
        .call(xAxisGrid)

      svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + margin.top + ")")
        .call(xAxis)


      dy = 10 + margin.top
      bar = svg.selectAll(".line-grp")
        .data(data)
        .enter().append('g').attr('class', 'line-grp')
        .attr "transform", (d, i) ->
          numProperties = if d.properties then d.properties.length else 0
          y = dy
          console.log numProperties + " / " + i
          dy += ((i + 1) + numProperties) * lineHeight

          return "translate(0," + y + ")"

      dragOffset = 0
      dragstart = (d) ->
        mouse = d3.mouse(this)
        mouseX = mouse[0]
        dragOffset = x(d.start) - mouseX

      dragmove = (d) ->
        mouse = d3.mouse(this)
        dx = x.invert(mouse[0] + dragOffset)
        diff = dx - d.start
        d.start = d.start + diff
        d.end = d.end + diff
        d3.select(this)
          .attr('x', x(d.start))

      drag = d3.behavior.drag()
        .origin((d) -> return d;)
        .on("drag", dragmove)
        .on("dragstart", dragstart)

      bar_border = 1
      bar.append("rect")
        .attr("class", "bar")
        .attr("y", 3)
        .attr("height", 14)
        .attr("x", (d) -> return x(d.start) + bar_border)
        .attr("width", (d) -> return x(d.end - d.start) - bar_border)
        .call(drag)

      bar.append("text")
        .attr("class", "line--label")
        .attr("x", label_position_x)
        .attr("y", 16)
        .text((d) -> d.label)

      bar.append("line")
        .attr("class", 'line--separator')
        .attr("x1", -200)
        .attr("x2", x(240 + 100))
        .attr("y1", lineHeight)
        .attr("y2", lineHeight)

      # Properties

      properties = bar.selectAll('.line--sub').data (d,i,j) ->
        return d.properties

      subGrp = properties.enter().append('g')
        .attr("class", 'line--sub')
        .attr "transform", (d, i) ->
          sub_height = (i + 1) * lineHeight
          return "translate(0," + sub_height + ")"

      subGrp.append('text')
        .attr("class", "line--label line--label-small")
        .attr("x", label_position_x)
        .attr("y", 15)
        .text (d) ->
          d.name


      # Keys
      keys = properties.selectAll('.key').data (d,i,j) ->
        return d.keys

      keys.enter().append("line")
        .attr("class", 'line--separator-secondary')
        .attr("x1", -200)
        .attr("x2", x(240 + 100))
        .attr("y1", lineHeight)
        .attr("y2", lineHeight)

      key_size = 6
      keys.enter().append('g')
        .attr('class', 'key')
        .attr 'transform', (d) ->
          dx = x(d.time) + 3
          dy = 9
          return "translate(" + dx + "," + dy + ")"
        .append('rect')
        .attr('x', -3)
        .attr('width', key_size)
        .attr('height', key_size)
        .attr('class', 'line--key')
        .attr('transform', 'rotate(45)')
