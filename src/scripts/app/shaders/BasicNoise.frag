precision highp float;

#ifdef GL_OES_standard_derivatives
#extension GL_OES_standard_derivatives : enable
#endif

#pragma glslify: aastep = require('glsl-aastep')

varying vec2 vUv;
uniform vec3 color;

void main() {
  float alpha = 0.0;
  float wireframe_size = 0.04;
  float min_x = 0.3;
  float max_x = 1.0;

  // If max is 1 then wireframe is is only half size.
  max_x = max_x * 0.9;

  // Get distance from edges.
  vec2 edgeX = abs(vec2(vUv.x - min_x, vUv.x - max_x));
  // Add the wireframe.
  edgeX = max(vec2(0.0, 0.0), edgeX - wireframe_size);

  // Get the smallest distance from edges.
  float distance_x = min(edgeX.x, edgeX.y);


  alpha = aastep(distance_x, 0.01);

  // Add the fill alpha.
  if (vUv.x > min_x && vUv.x < max_x) {
    alpha = max(0.3, alpha);
  }

  gl_FragColor = vec4( color, alpha );
  //vec3 k = vec3(1.0, 1.0, 1.0);
  //gl_FragColor = vec4( vec3( vUv, 0. ), 1. );
  //gl_FragColor = vec4( color, 1.0 );
}
