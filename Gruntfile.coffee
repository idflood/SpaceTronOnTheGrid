#global module:false
module.exports = (grunt) ->
  "use strict"
  require('time-grunt')(grunt)

  grunt.initConfig
    compass:
      clean:
        options:
          bundleExec: true
          clean: true

      dev:
        options:
          bundleExec: true
          debugInfo: false

      build:
        options:
          bundleExec: true
          environment: "production"
          outputStyle: "compressed"
          noLineComments: true
          imagesDir: "assets/images"
          fontsDir: "assets/fonts"

    concat:
      dist:
        src: [
          'src/scripts/bower_components/jquery/dist/jquery.js',
          'src/scripts/bower_components/three.js/three.js',
          'src/scripts/bower_components/js-signals/dist/signals.js',
          'src/scripts/bower_components/lodash/dist/lodash.js',
          'src/scripts/bower_components/gsap/src/uncompressed/TweenMax.js',
          'src/scripts/vendors/TweenTime/dist/scripts/TweenTime.Core.js'
        ],
        dest: 'assets/scripts/vendors.min.js'

    htmlmin:
      dist:
        options:
          removeComments: true,
          collapseWhitespace: true,
          minifyJS: true
        files:
          'index.html': 'src/index.html'

    uglify:
      dist:
        files:
          'assets/scripts/vendors.min.js': ['assets/scripts/vendors.min.js']

    webpack:
      main: require('./webpack.config.js')

    watch:
      html:
        files: ["src/index.html"]
        tasks: ["htmlmin"]

      sass:
        files: ["src/styles/**"]
        tasks: ["compass:dev"]

      reloadcss:
        options: {livereload: true}
        files: ["assets/styles/*.css"]

      compilejs:
        files: ["src/scripts/**", "!src/scripts/bower_components/**", "!src/scripts/vendors/**"]
        tasks: ["webpack"]

      reloadjs:
        options: {livereload: true}
        files: ["assets/scripts/**"]

      reloadhtml:
        options: {livereload: true}
        files: ["**.html"]

    clean:
      build: ["assets/images/"]

    copy:
      main:
        files: [
          expand: true
          src: ["**"]
          cwd: "src/images/"
          dest: "assets/images/"
        ,
          expand: true
          src: ["**"]
          cwd: "src/fonts/"
          dest: "assets/fonts/"
        ,
          expand: true
          src: ["src/scripts/vendors/modernizr.js"]
          dest: "assets/scripts/vendors/"
        ,
          expand: true
          src: ["src/scripts/app.js"]
          dest: "assets/scripts/"
        ]

    imagemin:
      build:
        options:
          optimizationLevel: 7
          progressive: true

        files: [
          expand: true
          cwd: "assets/images/"
          src: ["**.png", "*/**.png"]
          dest: "assets/images/"
        ,
          expand: true
          cwd: "assets/images/"
          src: ["**.jpg", "*/**.jpg"]
          dest: "assets/images/"
        ]

    notify:
      build:
        options: {message: "Build complete"}

    browserSync:
      bsFiles:
        src : ['assets/scripts/*.js', 'assets/styles/*.css']
      options:
        watchTask: true
        server:
          baseDir: "./"

  # Load necessary plugins
  require('jit-grunt')(grunt)

  grunt.registerTask "init", ["compass:clean", "compass:dev"]
  grunt.registerTask "default", ['browserSync', 'htmlmin', "compass:clean", "compass:dev", "webpack", "watch"]
  grunt.registerTask "buildVendors", ['concat', 'uglify']
  grunt.registerTask "build", ["clean", 'htmlmin', "compass:clean", "copy", "imagemin", "compass:build", "webpack", 'buildVendors', "notify:build"]
