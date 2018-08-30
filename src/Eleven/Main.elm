module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Math.Matrix3 as Mat3 exposing (Mat3)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Polyline exposing (Polyline)



-- Deformed Grid


main : Html msg
main =
    Polyline.draw lines
        |> El.html
        |> C.item "#EEE"
        |> C.layout


dimension : Vec2
dimension =
    vec2 30 30


list =
    List.range -10 10
        |> List.map toFloat
        |> List.map (flip (/) 2)


transform : Mat3
transform =
    Mat3.translate (vec2 15 15) Mat3.identity
        -- Why does this need to be done first?
        |> Mat3.scale (vec2 2 2)
        |> Mat3.rotate (pi * 3 / 5)


transformXY : ( Float, Float ) -> ( Float, Float )
transformXY ( x, y ) =
    ( x - sin (y * pi / 13) * cos (x * pi / 5)
    , y + cos (y * pi / 11) * sin (x * pi / 3)
    )


horizontalLines : List Polyline
horizontalLines =
    list
        |> List.map
            (\x ->
                List.map ((,) x) list
                    |> List.map transformXY
                    |> List.map Vec2.fromTuple
            )


verticalLines : List Polyline
verticalLines =
    list
        |> List.map
            (\y ->
                List.map (flip (,) y) list
                    |> List.map transformXY
                    |> List.map Vec2.fromTuple
            )


lines : List Polyline
lines =
    List.append horizontalLines verticalLines
        |> List.map (Polyline.transform transform)
