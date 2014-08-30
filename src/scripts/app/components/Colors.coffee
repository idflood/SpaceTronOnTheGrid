#https://kuler.adobe.com/Tron-Legacy2-color-theme-1406713/edit/?copy=true&base=2&rule=Custom&selected=0&name=Copy%20of%20Tron%20Legacy2&mode=rgb&rgbvalues=0.008019047984151012,0.2173110006233171,0.3137254901960784,0.00784313725490196,0.5411764705882353,0.6196078431372549,0.05627426106529288,0.7490196078431373,0.6616535221392924,0.9490196078431372,0.7547155506500436,0.11287104291749415,0.8509803921568627,0.1894012485482237,0.1429403608472727&swatchOrder=0,1,2,3,4
define (require) ->
  THREE = require 'threejs'

  items = [
    new THREE.Color(0xffffff),
    new THREE.Color(0x023750),
    new THREE.Color(0x028A9E),
    new THREE.Color(0x0EBFA9),
    new THREE.Color(0xF2C01D),
    new THREE.Color(0xD93024),
    #new THREE.Color(0x9ACCEF),
  ]

  length = items.length

  class Colors
    @get = (index) ->
      index = Math.abs(parseInt(index, 10))
      return items[index % length]

