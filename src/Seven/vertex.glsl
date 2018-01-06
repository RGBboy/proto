precision mediump float;

attribute vec3 position;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

varying vec3 vPosition;

void main() {

  mat4 modelViewMatrix = view * model;
  vec4 viewModelPosition = modelViewMatrix * vec4(position, 1.0);
  vPosition = position;

  gl_Position = projection * viewModelPosition;
}
