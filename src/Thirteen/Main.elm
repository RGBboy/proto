module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import List.Extra
import Math.Matrix3 as Mat3 exposing (Mat3)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Polyline exposing (Polyline)
import Random exposing (Generator, Seed)



-- Random Grid


main : Html msg
main =
    Polyline.draw lines
        |> El.html
        |> C.item "#EEE"
        |> C.layout


dimension : Vec2
dimension =
    vec2 30 30


points : number
points =
    32


segments : number
segments =
    points - 1


seed : Seed
seed =
    Random.initialSeed 1313


randomList : List Float
randomList =
    Random.step (Random.list (points * points) <| Random.float 0 1) seed
        |> Tuple.first


transform : Mat3
transform =
    Mat3.translate (vec2 15 15) Mat3.identity
        -- Why does this need to be done first?
        |> Mat3.scale (vec2 12 12)


normalize : Float -> Float
normalize value =
    ((value / segments) - 0.5) * 2


transformXY : Float -> ( Int, Int ) -> ( Float, Float )
transformXY random ( intX, intY ) =
    let
        x =
            toFloat intX

        y =
            toFloat intY

        dx =
            sin (x * pi / segments)

        dy =
            sin (y * pi / segments)
    in
    ( x - (dx * dy * random) |> normalize
    , y - (dx * dy * 0.5 * sin (2 * pi * random)) |> normalize
    )


data : List ( Int, Vec2 )
data =
    randomList
        |> List.indexedMap
            (\index random ->
                let
                    x =
                        index % points

                    y =
                        (index - x) // points
                in
                ( x, y, random )
            )
        |> List.map
            (\( x, y, random ) ->
                let
                    vector =
                        Vec2.fromTuple (transformXY random ( x, y ))
                in
                ( y, vector )
            )


horizontalLines : List Polyline
horizontalLines =
    data
        |> List.Extra.groupWhile (\( a, _ ) ( b, _ ) -> a == b)
        |> List.map (List.map Tuple.second)


verticalLines : List Polyline
verticalLines =
    List.Extra.transpose horizontalLines


lines : List Polyline
lines =
    List.append horizontalLines verticalLines
        |> List.map (Polyline.transform transform)
