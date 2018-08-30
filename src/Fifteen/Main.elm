module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import List.Extra
import Math.Matrix3 as Mat3 exposing (Mat3)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Polyline exposing (Polyline)



-- Zig Zag


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
    50


segments : number
segments =
    points - 1


transform : Mat3
transform =
    Mat3.translate (vec2 15 15) Mat3.identity
        -- Why does this need to be done first?
        |> Mat3.scale (vec2 12 12)


normalize : Float -> Float
normalize value =
    ((value / segments) - 0.5) * 2


transformXY : ( Int, Int ) -> ( Float, Float )
transformXY ( intX, intY ) =
    let
        x =
            toFloat intX

        y =
            if (intX % 2) == 0 then
                toFloat intY + 1

            else
                toFloat intY
    in
    ( x |> normalize
    , y |> normalize
    )


lines : List Polyline
lines =
    List.repeat (points * points) 0
        |> List.indexedMap
            (\index _ ->
                let
                    x =
                        index % points

                    y =
                        (index - x) // points
                in
                ( x, y )
            )
        |> List.map
            (\( x, y ) ->
                let
                    group =
                        y

                    vector =
                        Vec2.fromTuple (transformXY ( x, y ))
                in
                ( group, vector )
            )
        |> List.Extra.groupWhile (\a b -> Tuple.first a == Tuple.first b)
        |> List.map (List.map Tuple.second)
        |> List.map (Polyline.transform transform)
