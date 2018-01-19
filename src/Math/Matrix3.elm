module Math.Matrix3 exposing
  ( Mat3
  , mat3
  , identity
  , translate
  , scale
  , rotate
  , transform
  , multiply
  )

import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Math.Vector2 as Vec2 exposing (vec2, Vec2)



type alias Mat3 =
  ( Vec3, Vec3, Vec3 )

mat3 : Vec3 -> Vec3 -> Vec3 -> Mat3
mat3 u v w =
  ( u, v, w )

identity : Mat3
identity =
  ( vec3 1 0 0
  , vec3 0 1 0
  , vec3 0 0 1
  )

translate : Vec2 -> Mat3 -> Mat3
translate vector (u, v, w) =
  let
    (x, y) = Vec2.toTuple vector
    (a00, a01, a02) = Vec3.toTuple u
    (a10, a11, a12) = Vec3.toTuple v
    (a20, a21, a22) = Vec3.toTuple w
    out20 = x * a00 + y * a10 + a20
    out21 = x * a01 + y * a11 + a21
    out22 = x * a02 + y * a12 + a22
  in
    ( u
    , v
    , vec3 out20 out21 out22
    )

scale : Vec2 -> Mat3 -> Mat3
scale vector (u, v, w) =
  let
    (x, y) = Vec2.toTuple vector
    (a00, a01, a02) = Vec3.toTuple u
    (a10, a11, a12) = Vec3.toTuple v
  in
    ( vec3 (x * a00) a01 a02
    , vec3 a10 (y * a11) a12
    , w
    )

rotate : Float -> Mat3 -> Mat3
rotate rad (u, v, w) =
  let
    cosine = cos rad
    sine = sin rad
    (a00, a01, a02) = Vec3.toTuple u
    (a10, a11, a12) = Vec3.toTuple v
    out00 = cosine * a00 + sine * a10
    out01 = cosine * a01 + sine * a11
    out02 = cosine * a02 + sine * a12
    out10 = cosine * a10 - sine * a00
    out11 = cosine * a11 - sine * a01
    out12 = cosine * a12 - sine * a02
  in
    ( vec3 out00 out01 out02
    , vec3 out10 out11 out12
    , w
    )

multiply : Mat3 -> Mat3 -> Mat3
multiply ( a0, a1, a2 ) ( b0, b1, b2 ) =
  let
    (a00, a01, a02) = Vec3.toTuple a0
    (a10, a11, a12) = Vec3.toTuple a1
    (a20, a21, a22) = Vec3.toTuple a2
    (b00, b01, b02) = Vec3.toTuple b0
    (b10, b11, b12) = Vec3.toTuple b1
    (b20, b21, b22) = Vec3.toTuple b2
    out00 = a00 * b00 + a01 * b10 + a02 * b20
    out01 = a00 * b01 + a01 * b11 + a02 * b21
    out02 = a00 * b02 + a01 * b12 + a02 * b22
    out10 = a10 * b00 + a11 * b10 + a12 * b20
    out11 = a10 * b01 + a11 * b11 + a12 * b21
    out12 = a10 * b02 + a11 * b12 + a12 * b22
    out20 = a20 * b00 + a21 * b10 + a22 * b20
    out21 = a20 * b01 + a21 * b11 + a22 * b21
    out22 = a20 * b02 + a21 * b12 + a22 * b22
  in
    ( vec3 out00 out01 out02
    , vec3 out10 out11 out12
    , vec3 out20 out21 out22
    )


transformHelp : Mat3 -> Vec3 -> Vec3
transformHelp ( u, v, w ) vector =
    let
      (x, y, z) = Vec3.toTuple vector
      (a00, a01, a02) = Vec3.toTuple u
      (a10, a11, a12) = Vec3.toTuple v
      (a20, a21, a22) = Vec3.toTuple w
      out0 = x * a00 + y * a10 + z * a20
      out1 = x * a01 + y * a11 + z * a21
      out2 = x * a02 + y * a12 + z * a22
    in
      vec3 out0 out1 out2

transform : Mat3 -> Vec2 -> Vec2
transform m vector =
  let
    (x, y) = Vec2.toTuple vector
    (u, v, w) = Vec3.toTuple <|
      transformHelp m (vec3 x y 1)
  in
    vec2 (u / w) (v / w)
