#https://github.com/geluso/delight/commit/2575886522227c34c0d3d77f795f5d00acce284b
define (require) ->
  _ = require 'lodash'

  class Audio
    @instance = false

    constructor: (mp3Url, @onLoadedCallback) ->
      window.audio = this
      muted = false
      @fftSize = 512
      @filters = {}
      @playing = false
      @now = 0.0
      @timeDelay = 0.0

      @bass = 0
      @mid = 0
      @high = 0
      @audio = false # audio html node

      @context = new (window.AudioContext || window.webkitAudioContext)()
      #if typeof AudioContext != "undefined"
      #  @context = new AudioContext()
      #else if typeof webkitAudioContext != "undefined"
      #  @context = new webkitAudioContext()

      # create analyser
      @analyser = @context.createAnalyser()
      @analyser.fftSize = @fftSize

      #@source = @context.createBufferSource()
      @source = @load(mp3Url)

      # create bass/mid/treble filters
      parameters =
        bass:
          type: "lowpass" #lowpass
          frequency: 120
          Q: 1.2
          gain: 12.0
        mid:
          type: "bandpass" #bandpass
          frequency: 400
          Q: 1.2
          gain: 15.0
        treble:
          type: "highpass" #highpass
          frequency: 2000
          Q: 1.2
          gain: 12.0
      _.each parameters, (spec, key) =>
        filter = @context.createBiquadFilter()
        filter.key = key
        filter.type = spec.type
        filter.frequency.value = spec.frequency
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
        #@source.connect(filter.delayNode)
        #filter.delayNode.connect(filter)
        #filter.connect(filter.gainNode)
        @source.connect(filter.gainNode)
        #filter.gainNode.connect(filter.analyser)

        filter.gainNode.connect(filter)
        filter.connect(filter.analyser)

      # create buffers for time/freq data
      @samples = @analyser.frequencyBinCount
      @data =
        freq: new Uint8Array(@samples)
        time: new Uint8Array(@samples)
        filter:
          bass: new Uint8Array(256)
          mid: new Uint8Array(256)
          treble: new Uint8Array(256)

      #@load(mp3Url)

      # i know, ....
      Audio.instance = this

    update: () =>
      if @playing == false then return
      @analyser.smoothingTimeConstant = 0
      @analyser.getByteFrequencyData(@data.freq)
      @analyser.getByteTimeDomainData(@data.time)

      _.each @filters, (filter) =>
        filter.analyser.fftSize = @fftSize
        filter.analyser.getByteTimeDomainData(@data.filter[filter.key])

      # calculate rms
      bins = [0, 0, 0, 0]
      waveforms = [@data.time, @data.filter.bass, @data.filter.mid, @data.filter.treble]
      for num in [0..3]
        bins[num] = @rms(waveforms[num])
      @bass = bins[1]
      @mid = bins[2]
      @high = bins[3]
      #console.log @mid
      #if Math.random() < 0.04
      #  console.log(@bass, @mid, @high)

      @now = @audio.currentTime - @timeDelay

    seek: (seconds) =>
      @now = seconds
      # Set current time on audio only if playing
      if @audio && @audio.paused == false
        @audio.currentTime = @now

    load: (url) =>
      @audio = document.createElement("audio")
      @audio.src = url

      document.body.appendChild(@audio)
      @audio.addEventListener "canplay", () =>
        console.log "on can play"
        if @onLoadedCallback then @onLoadedCallback()

      source = @context.createMediaElementSource(@audio)
      source.loop = false

      return source

    pause: () =>
      if @audio then @audio.pause()
      @playing = false

    play: () =>
      @playing = true
      #@timeDelay = @context.currentTime - @now

      if @audio

        @audio.play()
        @audio.currentTime = @now
        #@audio.currentTime = @buffer.duration - @now

    rms: (data) =>
      size = data.length
      accum = 0
      for num in [0..size - 1]
        s = (data[num] - 128) / 128
        accum += s * s
      return Math.sqrt(accum / size)
