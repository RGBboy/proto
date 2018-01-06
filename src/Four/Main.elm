module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Math.Matrix3 as Mat3
import Math.Vector2 as Vec2 exposing (vec2, Vec2)
import Polyline as Polyline exposing (Polyline)



-- Lines

main : Html msg
main =
  Polyline.draw lines
    |> El.html
    |> C.item "#EEE"
    |> C.layout

dimension : Vec2
dimension = vec2 30 30

lines : List Polyline
lines =
  List.range 0 12
    |> List.map toFloat
    |> List.map (\size ->
        let
          transform = Mat3.identity
            |> Mat3.translate (Vec2.scale 0.5 dimension)
            |> Mat3.rotate ((size * pi / 48) + (pi / 4))
        in
          Polyline.square ((size + 1) * 2)
            |> Polyline.transform transform
      )
