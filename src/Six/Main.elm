module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes as A



-- Negative Space

main : Html msg
main =
  draw lines
    |> El.html
    |> C.item
    |> C.layout

type alias Point = (Float, Float)

addPoint : (Float, Float) -> (Float, Float) -> (Float, Float)
addPoint (aX, aY) (bX, bY) = (aX + bX, aY + bY)

type alias Polyline = List Point

dimension = (30, 30)

(width, height) = dimension

center = (width / 2, height / 2)

(centerX, centerY) = center

intersection : Float -> Float -> Maybe (Float, Float)
intersection radius y =
  let
    max = (radius ^ 2) - (y ^ 2) |> sqrt
  in
    if (isNaN max) then
      Nothing
    else
      Just (-max, max)

lines : List Polyline
lines =
  List.range 1 23
    |> List.map toFloat
    |> List.concatMap (\i ->
        let
          y = height * i / 24 - centerY
        in
          intersection (height / 2.5) y
            |> Maybe.map (\(left, right) ->
                [ [ (-centerX, y)
                  , (left, y)
                  ]
                , [ (right, y)
                  , (centerX, y)
                  ]
                ]
              )
            |> Maybe.withDefault [[(-centerX, y), (centerX, y)]]
      )
    |> List.map (List.map (addPoint center))

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
