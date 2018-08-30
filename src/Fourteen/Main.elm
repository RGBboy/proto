module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import List.Extra
import Math.Matrix3 as Mat3 exposing (Mat3)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Polyline exposing (Polyline)
import Random exposing (Generator, Seed)



-- Random Repeating Lines


main : Html msg
main =
    Polyline.draw lines
        |> El.html
        |> C.item "#EEE"
        |> C.layout


dimension : Vec2
dimension =
    vec2 30 30


segmentsX : number
segmentsX =
    64


pointsX : number
pointsX =
    segmentsX + 1


segmentsY : number
segmentsY =
    32


pointsY : number
pointsY =
    segmentsY + 1


seed : Seed
seed =
    Random.initialSeed 1441


randomList : List Float
randomList =
    Random.step (Random.list pointsX <| Random.float 0 1) seed
        |> Tuple.first


transform : Mat3
transform =
    Mat3.translate (vec2 15 15) Mat3.identity
        -- Why does this need to be done first?
        |> Mat3.scale (vec2 12 12)


normalizeX : Float -> Float
normalizeX value =
    ((value / segmentsX) - 0.5) * 2


normalizeY : Float -> Float
normalizeY value =
    ((value / segmentsY) - 0.5) * 2


transformX : Int -> Float -> Vec2
transformX intX random =
    let
        x =
            toFloat intX

        dy =
            sin (x * pi / segmentsX)
    in
    vec2 (x |> normalizeX) (0 - (10 * dy * dy * dy * random / segmentsX))


horizontalLine : Polyline
horizontalLine =
    randomList
        |> List.indexedMap transformX


lines : List Polyline
lines =
    List.repeat pointsY horizontalLine
        |> List.indexedMap
            (\index line ->
                let
                    y =
                        toFloat index

                    dy =
                        sin (y * pi / segmentsY)

                    offset =
                        y |> normalizeY

                    transform =
                        Mat3.translate (vec2 0 offset) Mat3.identity
                            |> Mat3.scale (vec2 1 dy)
                in
                Polyline.transform transform line
            )
        |> List.map (Polyline.transform transform)
