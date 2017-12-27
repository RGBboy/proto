attribute vec2 position;
uniform mediump float time;
varying vec2 vpos;

void main () {
  gl_Position = vec4(position, 0.0, 1.0);
  vpos = position;
}
