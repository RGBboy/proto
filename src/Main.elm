module Main exposing (main)

import AnimationFrame
import Element as El
import Element.Attributes as A
import Html exposing (Html)
import Html.Attributes exposing (width, height)
import Http
import Math.Vector2 as Vec2 exposing (vec2, Vec2)
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

type alias Vertex =
  { position : Vec2
  }

mesh : Mesh Vertex
mesh =
  WebGL.triangles
    [ ( Vertex (vec2 -3 -1)
      , Vertex (vec2 1 3)
      , Vertex (vec2 1 -1)
      )
    ]

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
    El.layout stylesheet
      <| El.row ()
          [ A.center
          , A.verticalCenter
          , A.width A.fill
          , A.height A.fill
          ]
          [ El.el ()
              [ A.width (A.px 320)
              , A.height (A.px 320)
              , A.inlineStyle
                  [ ( "background", "#DDDDDD" )
                  , ( "margin", "auto" )
                  ]
              ]
              content
          ]
