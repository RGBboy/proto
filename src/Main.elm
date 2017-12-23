module Main exposing (main)

import AnimationFrame
import Element as El
import Element.Attributes as A
import Html exposing (Html)
import Html.Attributes exposing (width, height)
import Http
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Result
import Style exposing (StyleSheet)
import Task
import Time exposing (Time)
import WebGL exposing (Mesh, Shader)



main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , subscriptions = subscriptions
    , update = update
    }



-- MODEL

type alias Uniforms =
  { time : Float }

type alias VertexShader =
  Shader Vertex Uniforms { vpos : Vec2, vtime : Float }

type alias FragmentShader =
  Shader {} Uniforms { vpos : Vec2, vtime : Float }

type alias Model =
  { time : Time
  , shaders : Maybe (VertexShader, FragmentShader)
  }

loadShaders : Cmd Msg
loadShaders =
  let
    fragmentRequest = Http.getString "./fragment.glsl"
      |> Http.toTask
      |> Task.map (WebGL.unsafeShader)
    vertexRequest = Http.getString "./vertex.glsl"
      |> Http.toTask
      |> Task.map (WebGL.unsafeShader)
  in
    Task.map2 (,) vertexRequest fragmentRequest
      |> Task.attempt ((Result.map Load) >> (Result.withDefault None))

init : (Model, Cmd Msg)
init =
  ( { time = 0
    , shaders = Nothing
    }
  , loadShaders
  )



-- UPDATE

type Msg
  = Tick Time
  | Load (VertexShader, FragmentShader)
  | None

update : Msg -> Model -> (Model, Cmd msg)
update message model =
  case message of
    Tick dt ->
      ( { model | time = dt + model.time }
      , Cmd.none
      )
    Load shaders ->
      ( { model | shaders = Just shaders }
      , Cmd.none
      )
    None -> (model, Cmd.none)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
  AnimationFrame.diffs Tick



-- VIEW

stylesheet : StyleSheet () variation
stylesheet =
  Style.styleSheet
    [ Style.style () [] ]

entity : Time -> (VertexShader, FragmentShader) -> El.Element () variation msg
entity time (vertexShader, fragmentShader) =
  El.html <|
    WebGL.toHtml
      [ width 320
      , height 320
      ]
      [ WebGL.entity
          vertexShader
          fragmentShader
          mesh
          { time = time / 1000 }
      ]

view : Model -> Html msg
view { time, shaders } =
  let
    content =
      Maybe.map (entity time) shaders
        |> Maybe.withDefault El.empty
  in
    -- need to add margin auto to flex item to make overflow on small screens work
    El.layout stylesheet
      <| El.el ()
          [ A.center
          , A.verticalCenter
          , A.width A.content
          , A.height A.content
          ]
          content



-- MESH

type alias Vertex =
  { position : Vec3
  , color : Vec3
  }

mesh : Mesh Vertex
mesh =
  WebGL.triangles
    [ ( Vertex (vec3 -3 -1 0) (vec3 1 0 0)
      , Vertex (vec3 1 3 0) (vec3 0 1 0)
      , Vertex (vec3 1 -1 0) (vec3 0 0 1)
      )
    ]



-- SHADERS



-- vertexShader : Shader Vertex Uniforms { vcolor : Vec3, vtime : Float }
-- vertexShader =
--   [glsl|
--
--     attribute vec3 position;
--     attribute vec3 color;
--     uniform float time;
--     varying vec3 vcolor;
--     varying float vtime;
--
--     void main () {
--       gl_Position = vec4(position, 1.0);
--       vcolor = color;
--       vtime = time;
--     }
--
--   |]

-- fragmentShader : FragmentShader
-- fragmentShader =
--   [glsl|
--
--     precision mediump float;
--     varying vec3 vcolor;
--     varying float vtime;
--
--     void main () {
--       gl_FragColor = vec4(vcolor, 1.0);
--     }
--
--   |]
