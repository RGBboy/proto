precision mediump float;

attribute vec2 position;
uniform float time;

void main() {
  gl_Position = vec4(position, 0.0, 1.0);
}
