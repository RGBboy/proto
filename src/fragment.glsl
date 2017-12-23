precision mediump float;

#pragma glslify: noise = require(glsl-noise/classic/3d)

varying vec2 vpos;
varying float vtime;

void main () {
  float multiplier = noise(vec3(vpos, vtime));
  gl_FragColor = vec4(multiplier, multiplier, multiplier, 1.0);
}
