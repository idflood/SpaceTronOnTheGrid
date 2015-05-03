var path = require('path');
var webpack = require('webpack');

module.exports = {
  devtool: "source-map",
  entry: {
    App: "app/App",
    Editor: "app/EditorUI"
  },
  output: {
    path: __dirname,
    filename: "bundle.js"
  },
  output: {
    path: path.join(__dirname, "assets/scripts/"),
    publicPath: "assets/",
    filename: "[name].js",
    chunkFilename: "Spacetron.[hash].js"
  },
  externals: {
    "Three": "THREE",
    "TweenTime": "TweenTime.Core",
    "TweenTime.Editor": "TweenTime.Editor",
    "TweenMax": "TweenMax",
    "d3": "d3",
    'js-signals': {
      root: 'signals',
      commonjs: './signals',
      amd: 'signals'
    },
    'lodash': "_",
    "$": "jQuery",
    'draggable-number.js': {
      root: 'DraggableNumber',
      commonjs: 'DraggableNumber',
      commonjs2: 'DraggableNumber',
      amd: 'DraggableNumber'
    },
  },
  resolve: {
    root: __dirname + '/src/scripts',
    extensions: ["", ".coffee", ".js"],
    alias: {
      rng: "bower_components/rng-js/rng",
    }
  },
  module: {
    loaders: [
      {test: /\.coffee$/, loader: "coffee-loader", exclude: /node_modules/},
      { test: /\.(glsl|frag|vert)$/, loader: 'raw', exclude: /node_modules/ },
      { test: /\.(glsl|frag|vert)$/, loader: 'glslify', exclude: /node_modules/ }
    ]
  },
  plugins: [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin()
  ]
};
