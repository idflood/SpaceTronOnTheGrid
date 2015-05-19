#pragma glslify: fxaa = require(glsl-fxaa/fxaa)

//texcoords computed in vertex step
//to avoid dependent texture reads
varying vec2 v_rgbNW;
varying vec2 v_rgbNE;
varying vec2 v_rgbSW;
varying vec2 v_rgbSE;
varying vec2 v_rgbM;

#pragma glslify: random = require(glsl-random)

#pragma glslify: blend = require(glsl-blend-soft-light)
#pragma glslify: luma = require(glsl-luma)

uniform sampler2D tDiffuse;
uniform vec2 resolution;
uniform float nIntensity;
uniform float time;

varying vec2 vUv;

void main() {
  vec2 p = vUv;
  vec2 fragCoord = vUv * resolution;

  // FXAA
  gl_FragColor = fxaa(tDiffuse, fragCoord, resolution, v_rgbNW, v_rgbNE, v_rgbSW, v_rgbSE, v_rgbM);

  float center = smoothstep(0.0, 1.0, length(vUv-0.5));

  // Add vignetting.
  gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0.0, 0.0, 0.0), center * 0.5);

  // Add film grain.
  vec3 g = vec3( random( (gl_FragCoord.xy / resolution.xy) * time )) * nIntensity;

  vec3 color = blend(gl_FragColor.rgb, g);
  float luminance = luma(gl_FragColor.rgb);
  //reduce the noise based on some
  //threshold of the background luminance
  float response = smoothstep(0.05, 0.5, luminance);
  color = mix(color, gl_FragColor.rgb, pow(response, 2.0));

  gl_FragColor = vec4(color, 1.0);

}
