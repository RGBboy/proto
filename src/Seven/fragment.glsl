precision mediump float;

varying vec3 vNormal;
varying vec3 vPosition;

void main() {
  float test = ceil((vPosition.x + vPosition.y + vPosition.z) * 5.0);
  float col = 1.0;
  if (mod(test, 2.0) == 0.0) {
    col = 0.0;
  }
  gl_FragColor = vec4(vec3(col), 1.0);
}
