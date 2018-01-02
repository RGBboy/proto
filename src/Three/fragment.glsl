precision mediump float;

#pragma glslify: lambert = require(glsl-diffuse-lambert)
#pragma glslify: noise = require(glsl-noise/classic/2d)

vec3 lightPosition = vec3(5.0, 5.0, 5.0);

varying vec3 vViewPosition;
varying vec3 vNormal;

void main() {

  vec3 lightDirection = normalize(lightPosition - vViewPosition);

  vec3 normal = normalize(vNormal);

  float ambient = 0.5;

  float power = lambert(lightDirection, normal) * 0.5;

  float noiseAmount = 0.01 * noise(vViewPosition.xy * 25.0); // stop banding

  float value = ambient + power + noiseAmount;

  gl_FragColor = vec4(value, value, value, 1.0);
}
