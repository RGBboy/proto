module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes as A



-- Lines

main : Html msg
main =
  draw lines
    |> El.html
    |> C.item "#EEE"
    |> C.layout

type alias Point = (Float, Float)

type alias Polyline = List Point

(width, height) = (30, 30)

margin : Float
margin = 0.25

lines : List Polyline
lines =
  List.range 0 12
    |> List.map toFloat
    |> List.map (\size ->
        let
          cx = width / 2
          cy = height / 2
        in
          square ((size * pi / 48) + (pi / 4)) (cx) (cy) (size + 1)
      )

add : Point -> Point -> Point
add (ax, ay) (bx, by) =
  (ax + bx, ay + by)

rotateBy : Float -> Point -> Point
rotateBy rotation =
  let
    cosine = cos rotation
    sine = sin rotation
  in
    (\(x, y) -> ( x * cosine - y * sine, y * cosine + x * sine ))

square : Float -> Float -> Float -> Float -> Polyline
square rotation x y size =
  let
    rotate = rotateBy rotation
    xMin = -1 * size
    xMax = size
    yMin = -1 * size
    yMax = size
  in
  [ rotate ( xMin, yMin ) |> add (x, y)
  , rotate ( xMax, yMin ) |> add (x, y)
  , rotate ( xMax, yMax ) |> add (x, y)
  , rotate ( xMin, yMax ) |> add (x, y)
  , rotate ( xMin, yMin ) |> add (x, y)
  ]

draw : List Polyline -> Html msg
draw lines =
  Svg.svg
    [ A.width "320"
    , A.height "320"
    , A.viewBox "0 0 30 30"
    ]
    <| List.map polyline lines

polyline : Polyline -> Svg msg
polyline line =
  Svg.polyline
    [ A.fill "none"
    , A.stroke "black"
    , A.strokeWidth "0.1"
    , A.points <| List.foldl collectPoints "" line
    ]
    []

collectPoints : Point -> String -> String
collectPoints p acc =
  acc ++ " " ++ (point p)

point : Point -> String
point (x, y) =
  (toString x) ++ ", " ++ (toString y)
