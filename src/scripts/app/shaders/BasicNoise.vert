varying vec2 vUv;
varying float noise;
uniform float time;
uniform float strength;
uniform float seed;

#pragma glslify: pnoise = require(glsl-noise/periodic/3d)

float turbulence( vec3 p ) {
    float w = 100.0;
    float t = -.5;
    for (float f = 1.0 ; f <= 10.0 ; f++ ){
        float power = pow( 2.0, f );
        t += abs( pnoise( vec3( power * p ), vec3( 10.0, 10.0, 10.0 ) ) / power );
    }
    return t;
}

void main() {
    vUv = uv;

    float time2 = time + seed;

    // add time to the noise parameters so it's animated
    noise = 10.0 *  -.10 * turbulence( 10.5 * normal + time2 );
    float b = 5.0 * pnoise( 0.2 * position + vec3( 2.0 * time2 ), vec3( 100.0 ) );
    float displacement = - noise + b;

    // Less displacement on center.
    displacement = displacement * vUv.x;

    //vec3 newPosition = position + normal * displacement * strength * 30.0;
    //vec2 normal2 = normalize(uv - 0.5);
    vec3 normal2 = normalize(position - 0.5);
    float strengthMultiplier = 15.0;
    vec3 newPosition = position + vec3(normal2.x, normal2.y, 0.0) * displacement * strength * strengthMultiplier;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );
}
