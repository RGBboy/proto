attribute vec3 position;
attribute vec3 color;
uniform mat4 perspective;
uniform mat4 camera;
uniform mat4 rotation;
varying vec3 vcolor;

void main () {
  gl_Position = perspective * camera * rotation * vec4(position, 1.0);
  vcolor = color;
}
