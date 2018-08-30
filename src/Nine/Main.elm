module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Math.Matrix3 as Mat3
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Polyline exposing (Polyline)



-- The Lorenz Attractor


main : Html msg
main =
    Polyline.draw [ line ]
        |> El.html
        |> C.item "#EEE"
        |> C.layout


dimension : Vec2
dimension =
    vec2 30 30


sigma =
    10.0


beta =
    8.0 / 3.0


rho =
    28.0


line : Polyline
line =
    List.range 0 20000
        |> List.map toFloat
        |> List.foldl
            (\_ acc ->
                let
                    ( x, y, z ) =
                        List.head acc |> Maybe.withDefault ( 1.0, 1.0, 1.0 )

                    dx =
                        (sigma * (y - x)) * 0.005

                    dy =
                        ((x * (rho - z)) - y) * 0.005

                    dz =
                        ((x * y) - (beta * z)) * 0.005
                in
                ( x + dx, y + dy, z + dz ) :: acc
            )
            []
        |> List.map (\( x, y, z ) -> vec2 (y * 0.5 + 14.0) (z * 0.5 + 2.0))
