attribute vec3 position;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

varying vec3 vViewPosition;

void main() {

  mat4 modelViewMatrix = view * model;
  vec4 viewModelPosition = modelViewMatrix * vec4(position, 1.0);

  vViewPosition = viewModelPosition.xyz;

  gl_Position = projection * viewModelPosition;
}
