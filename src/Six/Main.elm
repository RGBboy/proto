module Main exposing (main)

import Components as C
import Element as El
import Html exposing (Html)
import Math.Matrix3 as Mat3
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Polyline exposing (Polyline)



-- Negative Space


main : Html msg
main =
    Polyline.draw lines
        |> El.html
        |> C.item "#EEE"
        |> C.layout


dimension : Vec2
dimension =
    vec2 30 30


( width, height ) =
    Vec2.toTuple dimension


center : Vec2
center =
    Vec2.scale 0.5 dimension


( centerX, centerY ) =
    Vec2.toTuple center


intersection : Float -> Float -> Maybe Vec2
intersection radius y =
    let
        max =
            (radius ^ 2) - (y ^ 2) |> sqrt
    in
    if isNaN max then
        Nothing

    else
        Just (vec2 -max max)


lines : List Polyline
lines =
    List.range 1 23
        |> List.map toFloat
        |> List.concatMap
            (\i ->
                let
                    y =
                        height * i / 24 - centerY
                in
                intersection (height / 2.5) y
                    |> Maybe.map
                        (\v ->
                            [ [ vec2 -centerX y
                              , vec2 (Vec2.getX v) y
                              ]
                            , [ vec2 (Vec2.getY v) y
                              , vec2 centerX y
                              ]
                            ]
                        )
                    |> Maybe.withDefault
                        [ [ vec2 -centerX y
                          , vec2 centerX y
                          ]
                        ]
            )
        |> List.map (List.map (Vec2.add center))
