precision mediump float;

#pragma glslify: square = require(glsl-square-frame)

uniform vec2 resolution;

varying vec3 vNormal;

float pi = 3.14159;

void main() {

  vec2 screenPos = square(resolution);

  float z = screenPos.x * cos(pi * vNormal.z) + screenPos.y * sin(pi * vNormal.z);
  float surface = ceil(z * 16.0);
  float col = 1.0;
  if (mod(surface, 2.0) == 1.0) {
    col = 0.0;
  }

  gl_FragColor = vec4(vec3(col), 1.0);
}
