define (require) ->
  $ = require 'jquery'
  d3 = require 'd3'
  tpl_timeline = require 'text!modules/templates/timeline.tpl.html'

  class Editor
    constructor: () ->
      @app = window.app

      $timeline = $(tpl_timeline)
      $('body').append($timeline)

      margin = {top: 20, right: 20, bottom: 30, left: 190}
      width = window.innerWidth - margin.left - margin.right
      height = 270 - margin.top - margin.bottom
      lineHeight = 20

      data = [
        {label: "object 1", start: 15, end: 20},
        {label: "object 2", start: 60, end: 142},
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
        .tickFormat(formatMinutes)

      svg = d3.select($timeline.get(0)).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + margin.top + ")")
        .call(xAxis)

      bar = svg.selectAll(".line-grp")
        .data(data)
        .enter().append('g').attr('class', 'line-grp')
        .attr("transform", (d, i) -> return "translate(0," + (i * lineHeight + margin.top + 10) + ")")

      bar.append("rect")
        .attr("class", "bar")
        .attr("y", 3)
        .attr("height", 14)
        .attr("x", (d) -> return x(d.start))
        .attr("width", (d) -> return x(d.end - d.start))

      bar.append("text")
        .attr("class", "line--label")
        .attr("x", -180)
        .attr("y", 16)
        .text((d) -> d.label)

      bar.append("line")
        .attr("class", 'line--separator')
        .attr("x1", -200)
        .attr("x2", x(240))
        .attr("y1", lineHeight)
        .attr("y2", lineHeight)
