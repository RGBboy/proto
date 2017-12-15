module Main exposing (main)

import AnimationFrame
import Html exposing (Html)
import Html.Attributes exposing (width, height, style)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Time exposing (Time)
import WebGL exposing (Mesh, Shader)



main : Program Never Time Time
main =
  Html.program
    { init = init
    , view = view
    , subscriptions = subscriptions
    , update = update
    }



-- MODEL

type alias Model = Time

init : (Model, Cmd msg)
init = (0, Cmd.none)



-- UPDATE

type alias Msg = Time

update : Msg -> Model -> (Model, Cmd msg)
update elapsed currentTime =
  ( elapsed + currentTime
  , Cmd.none
  )



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ = AnimationFrame.diffs identity



-- VIEW

view : Time -> Html msg
view t =
    WebGL.toHtml
        [ width 400
        , height 400
        , style [ ( "display", "block" ) ]
        ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            mesh
            { time = t / 1000 }
        ]


perspective : Float -> Mat4
perspective t =
  Mat4.makeLookAt (vec3 0 0 1) (vec3 0 0 0) (vec3 0 1 0)



-- MESH


type alias Vertex =
  { position : Vec3
  , color : Vec3
  }


mesh : Mesh Vertex
mesh =
  WebGL.triangles
    [ ( Vertex (vec3 -2.5 -0.5 0) (vec3 1 0 0)
      , Vertex (vec3 0.5 2.5 0) (vec3 0 1 0)
      , Vertex (vec3 0.5 -0.5 0) (vec3 0 0 1)
      )
    ]



-- SHADERS


type alias Uniforms =
  { time : Float }


vertexShader : Shader Vertex Uniforms { vcolor : Vec3, vtime : Float }
vertexShader =
  [glsl|

    attribute vec3 position;
    attribute vec3 color;
    uniform float time;
    varying vec3 vcolor;
    varying float vtime;

    void main () {
      gl_Position = vec4(position, 1.0);
      vcolor = color;
      vtime = time;
    }

  |]


fragmentShader : Shader {} Uniforms { vcolor : Vec3, vtime : Float }
fragmentShader =
  [glsl|

    precision mediump float;
    varying vec3 vcolor;
    varying float vtime;

    void main () {
      gl_FragColor = vec4(vcolor, 1.0) * sin(vtime);
    }

  |]
