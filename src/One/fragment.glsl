precision mediump float;

#pragma glslify: noise = require(glsl-noise/classic/3d)

uniform mediump float time;
varying vec2 vpos;

void main () {
  float multiplier = noise(vec3(vpos, time));
  gl_FragColor = vec4(multiplier, multiplier, multiplier, 1.0);
}
