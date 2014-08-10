define (require) ->
  d3 = require 'd3'
  Signals = require 'Signal'
  _ = require 'lodash'

  class Items
    constructor: (@timeline, @container) ->
      @dy = 10 + @timeline.margin.top
      @onUpdate = new Signals.Signal()
      @onSelect = new Signals.Signal()

    render: () =>
      self = this

      selectBar = (d) ->
        # Merge attributes with existing ones on click, so if we add
        # an attribute we don't have to edit the json manually to allow
        # existing object to use it.
        # todo: find a way to get the value as current time (at time between previous and next key)
        factory = window.ElementFactory
        type_properties = {}
        if d.object then type_properties = d.object.constructor.properties

        existing_options = _.map(d.properties, (prop) -> prop.name)
        #console.log existing_options
        #console.log type_properties
        for key, property of type_properties
          has_prop = if existing_options.indexOf(key) != -1 then true else false
          # if prorperty doesn't exists in the d.options array create it
          # and assign the default value. {keys: [], name: "n", val: 1}
          if has_prop == false
            d.properties.push({keys: [], name: key, val: property.val})

        self.onSelect.dispatch(d)
        #if el_type
        #  d.options = extend(el_type.default_attributes(), d.options)
        #if window.gui then window.gui.destroy()
        #gui = new dat.GUI()

        #for key, value in d.properties
        #  controller = gui.add(d.properties, key)
        #  controller.onChange (v) -> d.isDirtyObject = true
        #for key, prop in d.properties
        #  controller = gui.add(d.properties, key)
        #window.gui = gui

      dragmove = (d) ->
        dx = self.timeline.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.start)
        d.start += diff
        d.end += diff
        if d.properties
          for prop in d.properties
            for key in prop.keys
              key.time += diff

        d.isDirty = true
        self.onUpdate.dispatch()

      dragmoveLeft = (d) ->
        d3.event.sourceEvent.stopPropagation()
        dx = self.timeline.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.start)
        d.start += diff
        d.isDirty = true
        self.onUpdate.dispatch()

      dragmoveRight = (d) ->
        d3.event.sourceEvent.stopPropagation()
        dx = self.timeline.x.invert(d3.event.x).getTime() / 1000
        diff = (dx - d.end)
        d.end += diff
        d.isDirty = true
        self.onUpdate.dispatch()

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
      bar = @container.selectAll(".line-grp")
        .data(@timeline.app.data, (d) -> d.id)

      barEnter = bar.enter()
        .append('g').attr('class', 'line-grp')

      barContainerRight = barEnter.append('svg')
        .attr('class', 'timeline__right-mask')
        .attr('width', window.innerWidth - self.timeline.label_position_x)
        .attr('height', self.timeline.lineHeight)

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

      self.dy = 10 + @timeline.margin.top
      bar.attr "transform", (d, i) ->
        y = self.dy
        self.dy += self.timeline.lineHeight
        if !d.collapsed
          numProperties = 0
          if d.properties
            # only show properties with keys
            visibleProperties = _.filter(d.properties, (prop) -> prop.keys.length)
            numProperties = visibleProperties.length
          self.dy += numProperties * self.timeline.lineHeight

        return "translate(0," + y + ")"

      bar.selectAll('.bar-anchor--left')
        .attr("x", (d) -> return self.timeline.x(d.start * 1000) - 1)

      bar.selectAll('.bar-anchor--right')
        .attr("x", (d) -> return self.timeline.x(d.end * 1000) - 1)

      bar.selectAll('.bar')
        .attr("x", (d) -> return self.timeline.x(d.start * 1000) + bar_border)
        .attr("width", (d) ->
          return Math.max(0, (self.timeline.x(d.end) - self.timeline.x(d.start)) * 1000 - bar_border)
        )
        .call(drag)
        .on("click", selectBar)

      barEnter.append("text")
        .attr("class", "line--label")
        .attr("x", self.timeline.label_position_x + 10)
        .attr("y", 16)
        .text((d) -> d.label)
        .on 'click', selectBar

      self = this
      barEnter.append("text")
        .attr("class", "line__toggle")
        .attr("x", self.timeline.label_position_x - 10)
        .attr("y", 16)
        .on 'click', (d) ->
          d.collapsed = !d.collapsed
          self.onUpdate.dispatch()

      bar.selectAll(".line__toggle")
        .text((d) -> if d.collapsed then "▸" else"▾")

      barEnter.append("line")
        .attr("class", 'line--separator')
        .attr("x1", -200)
        .attr("x2", self.timeline.x(self.timeline.timer.totalDuration + 100))
        .attr("y1", self.timeline.lineHeight)
        .attr("y2", self.timeline.lineHeight)

      bar.exit().remove()

      return bar
