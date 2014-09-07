varying vec2 vUv;
uniform vec3 color;

void main() {
  //vec3 k = vec3(1.0, 1.0, 1.0);
  //gl_FragColor = vec4( vec3( vUv, 0. ), 1. );
  gl_FragColor = vec4( color, 1.0 );
}
