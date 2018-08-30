module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import List.Extra
import Math.Matrix3 as Mat3 exposing (Mat3)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Polyline exposing (Polyline)



-- Based on Bridget Riley's Decending


main : Html msg
main =
    Polyline.draw lines
        |> El.html
        |> C.item "#EEE"
        |> C.layout


dimension : Vec2
dimension =
    vec2 30 30


pointsX : number
pointsX =
    17


segmentsX : number
segmentsX =
    pointsX - 1


pointsY : number
pointsY =
    33


segmentsY : number
segmentsY =
    pointsY - 1


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


transformXY : ( Int, Int ) -> ( Float, Float )
transformXY ( intX, intY ) =
    let
        x =
            toFloat intX

        y =
            toFloat intY
    in
    if (intX % 2) == 0 then
        ( x |> normalizeX
        , y + 1.4 |> normalizeY
        )

    else
        ( x + (sin (pi * (y + (-2.4 * x)) / 16) / 2) |> normalizeX
        , y - 1.4 |> normalizeY
        )


lines : List Polyline
lines =
    List.repeat (pointsX * pointsY) 0
        |> List.indexedMap
            (\index _ ->
                let
                    x =
                        index % pointsX

                    y =
                        (index - x) // pointsX
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
