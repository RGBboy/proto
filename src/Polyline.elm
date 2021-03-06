module Polyline exposing
    ( Polyline
    , draw
    , square
    , transform
    )

import Html exposing (Html)
import Math.Matrix3 as Mat3 exposing (Mat3)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (Svg)
import Svg.Attributes as A



-- To Do:
--
-- intersect : Shape -> List Polyline -> (List Polyline, List Polyline)
-- where left is the lines inside the shape, right is the lines outside
-- add : Shape -> Shape -> Shape
-- eg. square 1 1 |> add (circle 1 1)


type alias Polyline =
    List Vec2


transform : Mat3 -> Polyline -> Polyline
transform m line =
    List.map (Mat3.transform m) line


square : Float -> Polyline
square size =
    let
        min =
            -size / 2

        max =
            size / 2
    in
    [ vec2 min min
    , vec2 max min
    , vec2 max max
    , vec2 min max
    , vec2 min min
    ]


draw : List Polyline -> Html msg
draw lines =
    Svg.svg
        [ A.width "320"
        , A.height "320"
        , A.viewBox "0 0 30 30"
        ]
    <|
        List.map polyline lines


polyline : Polyline -> Svg msg
polyline line =
    Svg.polyline
        [ A.fill "none"
        , A.stroke "black"
        , A.strokeWidth "0.1"
        , A.points <| List.foldl collectPoints "" line
        ]
        []


collectPoints : Vec2 -> String -> String
collectPoints p acc =
    acc ++ " " ++ point p


point : Vec2 -> String
point p =
    let
        ( x, y ) =
            Vec2.toTuple p
    in
    toString x ++ ", " ++ toString y
