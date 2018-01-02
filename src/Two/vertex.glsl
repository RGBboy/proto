precision mediump float;

#pragma glslify: inverse = require(glsl-inverse)
#pragma glslify: transpose = require(glsl-transpose)

attribute vec3 position;
attribute vec3 normal;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

varying vec3 vNormal;

void main() {

  mat4 modelViewMatrix = view * model;
  vec4 viewModelPosition = modelViewMatrix * vec4(position, 1.0);

  mat4 normalMatrix = transpose(inverse(modelViewMatrix));

  vNormal = vec3(normalMatrix * vec4(normal, 1.0));

  gl_Position = projection * viewModelPosition;
}
