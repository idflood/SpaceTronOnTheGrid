THREE.CustomPostShader = {
  uniforms: {
    "tDiffuse": {type: "t", value: null},
    "resolution": {type: "v2", value: new THREE.Vector2(1 / 1024, 1 / 512)},
    "time": {type: "f", value: 0},
    "nIntensity": {type: "f", value: 0.05},
  },
  vertexShader: require('./CustomPostPass.vert'),
  fragmentShader: require('./CustomPostPass.frag'),
};

THREE.CustomPostPass = function (noiseIntensity, resolution) {
  var shader = THREE.CustomPostShader;

  this.uniforms = THREE.UniformsUtils.clone( shader.uniforms );

  this.material = new THREE.ShaderMaterial({
    uniforms: this.uniforms,
    vertexShader: shader.vertexShader,
    fragmentShader: shader.fragmentShader
  });

  this.uniforms.nIntensity.value = resolution;
  if ( noiseIntensity !== undefined ) this.uniforms.nIntensity.value = noiseIntensity;

  this.enabled = true;
  this.renderToScreen = false;
  this.needsSwap = true;

  this.camera = new THREE.OrthographicCamera( -1, 1, 1, -1, 0, 1 );
  this.scene  = new THREE.Scene();

  this.quad = new THREE.Mesh( new THREE.PlaneGeometry( 2, 2 ), null );
  this.scene.add( this.quad );
};

THREE.CustomPostPass.prototype = {
  render: function (renderer, writeBuffer, readBuffer, delta) {
    this.uniforms[ "tDiffuse" ].value = readBuffer;
    this.uniforms[ "time" ].value += delta;

    this.quad.material = this.material;

    if ( this.renderToScreen ) {
      renderer.render( this.scene, this.camera );
    } else {
      renderer.render( this.scene, this.camera, writeBuffer, false );
    }
  }
};
