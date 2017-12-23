attribute vec3 position;
uniform float time;
varying vec2 vpos;
varying float vtime;

void main () {
  gl_Position = vec4(position, 1.0);
  vpos = gl_Position.xy;
  vtime = time;
}
