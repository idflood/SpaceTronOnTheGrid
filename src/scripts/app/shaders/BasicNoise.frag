precision highp float;

#ifdef GL_OES_standard_derivatives
#extension GL_OES_standard_derivatives : enable
#endif

#pragma glslify: aastep = require('glsl-aastep')

varying vec2 vUv;
uniform vec3 color;

uniform vec3 fogColor;
uniform float fogDensity;

// Common
#define PI 3.14159
#define PI2 6.28318
#define RECIPROCAL_PI2 0.15915494
#define LOG2 1.442695
#define EPSILON 1e-6

float square( in float a ) { return a*a; }
vec2  square( in vec2 a )  { return vec2( a.x*a.x, a.y*a.y ); }
vec3  square( in vec3 a )  { return vec3( a.x*a.x, a.y*a.y, a.z*a.z ); }
vec4  square( in vec4 a )  { return vec4( a.x*a.x, a.y*a.y, a.z*a.z, a.w*a.w ); }
float saturate( in float a ) { return clamp( a, 0.0, 1.0 ); }
vec2  saturate( in vec2 a )  { return clamp( a, 0.0, 1.0 ); }
vec3  saturate( in vec3 a )  { return clamp( a, 0.0, 1.0 ); }
vec4  saturate( in vec4 a )  { return clamp( a, 0.0, 1.0 ); }
float average( in float a ) { return a; }
float average( in vec2 a )  { return ( a.x + a.y) * 0.5; }
float average( in vec3 a )  { return ( a.x + a.y + a.z) / 3.0; }
float average( in vec4 a )  { return ( a.x + a.y + a.z + a.w) * 0.25; }
float whiteCompliment( in float a ) { return saturate( 1.0 - a ); }
vec2  whiteCompliment( in vec2 a )  { return saturate( vec2(1.0) - a ); }
vec3  whiteCompliment( in vec3 a )  { return saturate( vec3(1.0) - a ); }
vec4  whiteCompliment( in vec4 a )  { return saturate( vec4(1.0) - a ); }

vec3 inputToLinear( in vec3 a ) {
  return a;
}

vec3 linearToOutput( in vec3 a ) {
  return a;
}

void main() {
  // For fog
  vec3 outgoingLight = vec3( 0.0 );	// outgoing light does not have an alpha, the surface does
  vec4 diffuseColor = vec4( color, 1.0 );

  float alpha = 0.0;
  float wireframe_size = 0.01;
  float min_x = 0.0;
  float max_x = 1.0;

  // If max is 1 then wireframe is is only half size.
  //max_x = max_x * 0.98;

  // Get distance from edges.
  vec2 edgeX = abs(vec2(vUv.x - min_x, vUv.x - max_x));
  // Add the wireframe.
  edgeX = max(vec2(0.0, 0.0), edgeX - wireframe_size);

  // Get the smallest distance from edges.
  float distance_x = min(edgeX.x, edgeX.y);


  alpha = aastep(distance_x, 0.01);


  // Add the fill alpha.
  if (vUv.x > min_x && vUv.x < max_x) {
    alpha = max(0.1, alpha);
  }

  outgoingLight = diffuseColor.rgb;

  float depth = gl_FragCoord.z / gl_FragCoord.w;
  float fogFactor = exp2( - square( fogDensity ) * square( depth ) * LOG2 );
  fogFactor = whiteCompliment( fogFactor );

  outgoingLight = mix( outgoingLight, fogColor, fogFactor );

  gl_FragColor = vec4(outgoingLight, alpha);
  //vec3 k = vec3(1.0, 1.0, 1.0);
  //gl_FragColor = vec4( vec3( vUv, 0. ), 1. );
  //gl_FragColor = vec4( color, 1.0 );
}
