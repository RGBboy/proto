#extension GL_OES_standard_derivatives : enable
precision highp float;

#pragma glslify: faceNormals = require('glsl-face-normal')

varying vec3 vViewPosition;

void main() {
  vec3 normal = faceNormals(vViewPosition);
  gl_FragColor = vec4(normal.z, normal.z, normal.z, 1.0);
}
