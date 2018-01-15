module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Math.Matrix3 as Mat3
import Math.Vector2 as Vec2 exposing (vec2, Vec2)
import Polyline as Polyline exposing (Polyline)



-- The Aizawa Attractor

main : Html msg
main =
  Polyline.draw [line]
    |> El.html
    |> C.item "#EEE"
    |> C.layout

dimension : Vec2
dimension = vec2 30 30

dt = 0.01

a = 0.95
b = 0.7
c = 0.6
d = 3.5
e = 0.25
f = 0.1

line : Polyline
line =
  List.range 0 20000
    |> List.map toFloat
    |> List.foldl (\_ acc ->
        let
          (x, y, z) = List.head acc |> Maybe.withDefault (0.1, 0.0, 0.0)
          dx = (((z - b) * x) - (d * y)) * dt
          dy = ((d * x) + ((z - b) * y)) * dt
          dz = (c + (a * z) - ((z ^ 3) / 3) - (((x ^ 2) + (y ^ 2)) * (1 + (e * z))) + (f * z * (x ^ 3))) * dt
        in
          (x + dx, y + dy, z + dz) :: acc
      ) []
    |> List.map (\(x, y, z) -> vec2 (z * 8.0 + 10.0) (y * 8.0 + 15.0))
