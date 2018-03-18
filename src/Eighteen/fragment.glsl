precision mediump float;

varying vec3 vNormal;
varying vec3 vPosition;

float pi = 3.14159;

void main() {

  float z = (vPosition.x - vPosition.y) + vPosition.z;
  float surface = ceil(z);
  float col = 1.0;
  if (mod(surface, 2.0) == 1.0) {
    col = 0.0;
  }

  gl_FragColor = vec4(vec3(col), 1.0);
}
