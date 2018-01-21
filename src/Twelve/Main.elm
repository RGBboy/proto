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

points : number
points = 50

segments : number
segments = points - 1

seed : Seed
seed = Random.initialSeed 1221

randomList : List Float
randomList = Random.step (Random.list (points * points) <| Random.float 0 1) seed
  |> Tuple.first

transform : Mat3
transform =
  Mat3.translate (vec2 15 15) Mat3.identity -- Why does this need to be done first?
    |> Mat3.scale (vec2 12 12)

normalize : Float -> Float
normalize value =
  ((value / segments) - 0.5) * 2

transformXY : Float -> (Int, Int) -> (Float, Float)
transformXY random (x, y) =
  ( (toFloat x) |> normalize
  , (toFloat y) + (random / 2) |> normalize
  )

lines : List Polyline
lines =
  randomList
    |> List.indexedMap (\index random ->
        let
          x = index % points
          y = (index - x) // points
        in
          (x, y, random)
      )
    |> List.map (\(x, y, random) ->
        let
          group = y
          vector = Vec2.fromTuple (transformXY random (x, y))
        in
          (group, vector)
      )
    |> List.Extra.groupWhile (\a b -> Tuple.first a == Tuple.first b)
    |> List.map (List.map Tuple.second)
    |> List.map (Polyline.transform transform)
