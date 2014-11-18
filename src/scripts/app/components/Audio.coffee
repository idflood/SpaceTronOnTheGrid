#https://github.com/geluso/delight/commit/2575886522227c34c0d3d77f795f5d00acce284b
define (require) ->
  _ = require 'lodash'

  class Audio
    @instance = false

    constructor: (mp3Url, @onLoadedCallback) ->
      muted = true
      @fftSize = 512
      @filters = {}
      @playing = false
      @now = 0.0
      @timeDelay = 0.0

      @bass = 0
      @mid = 0
      @high = 0

      @context = false
      if typeof AudioContext != "undefined"
        @context = new AudioContext()
      else if typeof webkitAudioContext != "undefined"
        @context = new webkitAudioContext()

      # create analyser
      @analyser = @context.createAnalyser()
      @analyser.fftSize = @fftSize

      @source = @context.createBufferSource()

      # create bass/mid/treble filters
      parameters =
        bass:
          type: 0 #lowpass
          frequency: 120
          Q: 1.2
          gain: 2.0
        mid:
          type: 2 #bandpass
          frequency: 400
          Q: 1.2
          gain: 4.0
        treble:
          type: 1 #highpass
          frequency: 2000
          Q: 1.2
          gain: 3.0
      _.each parameters, (spec, key) =>
        filter = @context.createBiquadFilter()
        filter.key = key
        filter.type = spec.type
        filter.frequency = spec.frequency
        filter.Q.value = spec.Q

        # create analyser for filtered signal
        filter.analyser = @context.createAnalyser()
        filter.analyser.fftSize = @fftSize

        # create delay to compensate fftSize lag
        if @context.createDelay?
          filter.delayNode = @context.createDelay()
        else
          filter.delayNode = @context.createDelayNode()
        filter.delayNode.delayTime.value = 0

        # create gain node to offset filter loss
        if @context.createGain?
          filter.gainNode = @context.createGain()
        else
          filter.gainNode = @context.createGainNode()
        filter.gainNode.gain.value = spec.gain

        @filters[key] = filter

      # create delay to compensate fftSize lag
      if @context.createDelay?
        @delay = @context.createDelay()
      else
        @delay = @context.createDelayNode()
      @delay.delayTime.value = @fftSize * 2 / @context.sampleRate

      # connect audio processing pipe
      @source.connect(@analyser)
      @analyser.connect(@delay)


      if muted
        gain2 = @context.createGain()
        @delay.connect(gain2)
        gain2.gain.value = 0.00
        gain2.connect(@context.destination)
      else
        @delay.connect(@context.destination)

      # connect secondary filters + analysers + gain
      _.each @filters, (filter) =>
        @source.connect(filter.delayNode)
        filter.delayNode.connect(filter)
        filter.connect(filter.gainNode)
        filter.gainNode.connect(filter.analyser)

      # create buffers for time/freq data
      @samples = @analyser.frequencyBinCount
      @data =
        freq: new Uint8Array(@samples)
        time: new Uint8Array(@samples)
        filter:
          bass: new Uint8Array(256)
          mid: new Uint8Array(256)
          treble: new Uint8Array(256)

      @load(mp3Url)

      # i know, ....
      Audio.instance = this

    update: () =>
      if @playing == false then return
      @analyser.smoothingTimeConstant = 0
      @analyser.getByteFrequencyData(@data.freq)
      @analyser.getByteTimeDomainData(@data.time)

      _.each @filters, (filter) =>
        filter.analyser.getByteTimeDomainData(@data.filter[filter.key])

      # calculate rms
      bins = [0, 0, 0, 0]
      waveforms = [@data.time, @data.filter.bass, @data.filter.mid, @data.filter.treble]
      for num in [0..3]
        bins[num] = @rms(waveforms[num])
      @bass = bins[1]
      @mid = bins[2]
      @high = bins[3]

      @now = @context.currentTime - @timeDelay

    seek: (seconds) =>
      @now = seconds
      #@context.currentTime = @now

      if @source.buffer
        #@source.noteOn(0)
        if @playing
          @pause()
          @play()
          #@source.stop(0)
          #@source.start(0, @now, @buffer.duration - @now)


    load: (url) =>
      request = new XMLHttpRequest()
      request.open("GET", url, true)
      request.responseType = "arraybuffer"

      request.onload = () =>
        #@buffer = @context.createBuffer(request.response, false)
        @context.decodeAudioData request.response, (buff) =>
          @buffer = buff
          @source.buffer = @buffer
          @source.loop = false
          if @onLoadedCallback then @onLoadedCallback()
          #@play()

      request.send()

    createSound: () =>
      src = @context.createBufferSource()
      if @buffer
        src.buffer = @buffer
      src.connect(@analyser)
      _.each @filters, (filter) =>
        src.connect(filter.delayNode)
      return src

    pause: () =>
      if @source
        if @playing
          @source.stop(0)
        @source.disconnect(0)
        @source = false
      @playing = false

    play: () =>
      @playing = true
      @timeDelay = @context.currentTime - @now
      #console.log @now
      if !@source
        @source = @createSound()
      if @source.buffer
        #@source.noteOn(0)
        @source.start(0, @now, @buffer.duration - @now)


    rms: (data) =>
      size = data.length
      accum = 0
      for num in [0..size - 1]
        s = (data[num] - 128) / 128
        accum += s * s
      return Math.sqrt(accum / size)
