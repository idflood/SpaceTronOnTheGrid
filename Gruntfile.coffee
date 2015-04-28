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

    webpack:
      main: require('./webpack.config.js')

    watch:
      sass:
        files: ["src/styles/**"]
        tasks: ["compass:dev"]

      reloadcss:
        options: {livereload: true}
        files: ["assets/styles/*.css"]

      compilejs:
        files: ["src/scripts/**", "!src/scripts/bower_components/**"]
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

  # Load necessary plugins
  require('jit-grunt')(grunt)

  grunt.registerTask "init", ["compass:clean", "compass:dev"]
  grunt.registerTask "default", ["compass:clean", "compass:dev", "webpack", "watch"]
  grunt.registerTask "build", ["clean", "compass:clean", "copy", "imagemin", "compass:build", "webpack", "notify:build"]
