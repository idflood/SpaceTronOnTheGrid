require.config({
  paths: {
    jquery: 'bower_components/jquery/dist/jquery',
    text: "bower_components/requirejs-text/text",
    cs: "bower_components/require-cs/cs",
    "coffee-script": "bower_components/coffee-script/extras/coffee-script",
    threejs: "bower_components/three.js/three",
    rng: "bower_components/rng-js/rng",
    d3: "bower_components/d3/d3",
    signals: "bower_components/js-signals/dist/signals",
    TweenMax: "bower_components/gsap/src/uncompressed/TweenMax",
    lodash: "bower_components/lodash/dist/lodash",
    DraggableNumber: "bower_components/draggable-number.js/dist/draggable-number",
    TweenTime: "vendors/TweenTime/dist/scripts/TweenTime.Core",
    Editor: "vendors/TweenTime/dist/scripts/TweenTime.Editor",
    spectrum: "bower_components/spectrum/spectrum",
  },
  shim: {
    TweenMax: {
      exports: 'TweenMax'
    },
    threejs: {
      exports: 'THREE' // This match something in path section.
    },
    rng: {
      exports: 'RNG' // This match something in path section.
    }
  }
});
