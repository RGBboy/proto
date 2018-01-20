module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Math.Matrix3 as Mat3 exposing (Mat3)
import Math.Vector2 as Vec2 exposing (vec2, Vec2)
import Polyline as Polyline exposing (Polyline)
import Random exposing (Generator, Seed)
import List.Extra



-- Random Grid

main : Html msg
main =
  Polyline.draw lines
    |> El.html
    |> C.item "#EEE"
    |> C.layout

dimension : Vec2
dimension = vec2 30 30

divisions : number
divisions = 32

seed : Seed
seed = Random.initialSeed 1313

randomList : List Float
randomList = Random.step (Random.list (divisions * divisions) <| Random.float 0 1) seed
  |> Tuple.first

transform : Mat3
transform =
  Mat3.translate (vec2 15 15) Mat3.identity -- Why does this need to be done first?
    |> Mat3.scale (vec2 12 12)

normalize : Float -> Float
normalize value =
  ((value / (toFloat divisions)) - 0.5) * 2

transformXY : Float -> (Int, Int) -> (Float, Float)
transformXY random (intX, intY) =
  let
    x = toFloat intX
    y = toFloat intY
    dx = (sin (x * pi / divisions))
    dy = (sin (y * pi / divisions))
  in
    ( x - (dx * dy * random) |> normalize
    , y - (dx * dy * 0.5 * (sin (2 * pi * random))) |> normalize
    )

data : List (Int, Vec2)
data =
  randomList
    |> List.indexedMap (\index random ->
        let
          x = index % divisions
          y = (index - x) // divisions
        in
          (x, y, random)
      )
    |> List.map (\(x, y, random) ->
        let
          vector = Vec2.fromTuple (transformXY random (x, y))
        in
          (y, vector)
      )

horizontalLines : List Polyline
horizontalLines =
  data
    |> List.Extra.groupWhile (\(a, _) (b, _) -> a == b)
    |> List.map (List.map Tuple.second)

verticalLines : List Polyline
verticalLines =
  List.Extra.transpose horizontalLines

lines : List Polyline
lines =
  List.append horizontalLines verticalLines
    |> List.map (Polyline.transform transform)