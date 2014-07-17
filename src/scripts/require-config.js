require.config({
  paths: {
    jquery: 'bower_components/jquery/dist/jquery',
    //bxslider: 'vendors/jquery.bxslider/jquery.bxslider',
    //'magnific-popup': 'vendors/Magnific-Popup/dist/jquery.magnific-popup',
    text: "bower_components/requirejs-text/text",
    cs: "bower_components/require-cs/cs",
    "coffee-script": "bower_components/coffee-script/extras/coffee-script",
    threejs: "bower_components/three.js/three",
    rng: "bower_components/rng-js/rng",
    d3: "bower_components/d3/d3",
    Signal: "bower_components/js-signals/dist/signals",
    TweenMax: "bower_components/gsap/src/uncompressed/TweenMax",
    TimelineMax: "bower_components/gsap/src/uncompressed/TimelineMax",
  },
  shim: {
    TimelineMax: {
      exports: 'TimelineLite',
      deps: ['TweenMax']
    },

    threejs: {
      exports: 'THREE' // This match something in path section.
    },
    rng: {
      exports: 'RNG' // This match something in path section.
    },
    // If a script require another script to be loaded before:
    /*
    bxslider: {
      deps: ['jquery'] // This match something in path section.
    },
     */
    // If a script returns nothing when added to a file we need
    // to define an export.
    /*
    timeline: {
      deps: ['tweenmax'],
      exports: 'TimelineLite' // In timeline.js the plugin is returned as TimelineLite object.
    },
     */
  }
});
