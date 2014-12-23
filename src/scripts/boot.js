// We need to configure cs! and require.js plugins to boot.
// @see: require-config.js
require.config({
  paths: {
    "coffee-script": "bower_components/coffee-script/extras/coffee-script",
    cs: "bower_components/require-cs/cs"
  }
});

require(['cs!app/Main'], function (Main) {
  window.app = new Main();
  window.tweenTime = app.tweenTime;
});
