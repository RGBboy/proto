precision mediump float;

uniform vec2 resolution;
uniform float time;

const float pi = 3.14159265359;

vec2 doModel(vec3 p);

#pragma glslify: raytrace = require(glsl-raytrace, map = doModel, steps = 5)
#pragma glslify: square   = require(glsl-square-frame)
#pragma glslify: sdSphere = require(glsl-sdf-primitives/sdSphere)
#pragma glslify: opRepeat = require(@rgbboy/glsl-sdf-ops/repeat)
#pragma glslify: opTransform = require(@rgbboy/glsl-sdf-ops/rotate-translate)

mat4 rotationMatrix(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
              oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
              oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
              0.0,                                0.0,                                0.0,                                1.0);
}

vec2 doModel(vec3 p) {

  mat4 rotate = rotationMatrix(vec3(0.0, 0.0, 1.0), pi / 4.0); // 45 degrees
  vec2 screenPos = square(resolution);
  float scale = sin(((time + sqrt((screenPos.x * screenPos.x) + (screenPos.y * screenPos.y))) * 4.0 )) * 0.04 + 0.05;
  vec3 transform = opTransform(p, rotate);
  vec3 repeat = opRepeat(transform, vec3(0.25, 0.25, 0.0));
  return vec2(sdSphere(repeat, scale), 0.0);

}

void main() {
  vec2 screenPos = square(resolution);
  vec3 rayOrigin = vec3(screenPos, 20.0);
  vec3 rayDirection = vec3(0.0, 0.0, -1.0);

  vec3 col = vec3(0.0);
  vec2 t = raytrace(rayOrigin, rayDirection);

  if (t.x > -0.5) {
    vec3 pos = rayOrigin + t.x * rayDirection;
    col = vec3(pos.z * 30.0);
  }

  gl_FragColor = vec4( col, 1.0 );
}
