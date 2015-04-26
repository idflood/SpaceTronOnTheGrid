#global module:false
module.exports = (grunt) ->
  "use strict"
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

    requirejs:
      compile:
        options:
          baseUrl: 'src/scripts'
          mainConfigFile: 'src/scripts/require-config.js'
          name: "bower_components/almond/almond"
          out: "assets/scripts/boot.js"
          generateSourceMaps: true
          #optimize: "uglify2"
          optimize: "none"
          inlineText: true
          preserveLicenseComments: false
          include: "boot"
          paths:
            requireLib: "bower_components/requirejs/require"
          exclude: ['coffee-script']
          stubModules: ['cs']
          pragmasOnSave:
            excludeCoffeeScript: true

      compileEditor:
        options:
          baseUrl: 'src/scripts'
          mainConfigFile: 'src/scripts/require-config.js'
          name: "bower_components/almond/almond"
          out: "assets/scripts/boot-editor.js"
          generateSourceMaps: true
          #optimize: "uglify2"
          optimize: "none"
          inlineText: true
          preserveLicenseComments: false
          include: "boot-editor"
          paths:
            requireLib: "bower_components/requirejs/require"
          exclude: ['coffee-script']
          stubModules: ['cs']
          pragmasOnSave:
            excludeCoffeeScript: true

    watch:
      sass:
        files: ["src/styles/**"]
        tasks: ["compass:dev"]

      reloadcss:
        options: {livereload: true}
        files: ["assets/styles/*.css"]

      compilejs:
        files: ["src/scripts/**", "!src/scripts/bower_components/**"]
        tasks: ["requirejs"]

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
  grunt.registerTask "default", ["compass:clean", "compass:dev", "requirejs", "watch"]
  grunt.registerTask "build", ["clean", "compass:clean", "copy", "imagemin", "compass:build", "requirejs", "notify:build"]
