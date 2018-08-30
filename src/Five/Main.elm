module Main exposing (main)

import AnimationFrame
import Components as C
import Element as El
import Html exposing (Html)
import Html.Attributes exposing (height, width)
import Http
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Result
import Task
import Time exposing (Time)
import WebGL exposing (Mesh, Shader)



-- Signed Distance Fields


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
    { time : Float
    , resolution : Vec2
    }


type alias VertexShader =
    Shader Vertex Uniforms {}


type alias FragmentShader =
    Shader {} Uniforms {}


type alias Model =
    { time : Time
    , shaders : Maybe ( VertexShader, FragmentShader )
    }


loadShaders : Cmd Msg
loadShaders =
    let
        fragmentRequest =
            Http.getString "./fragment.glsl"
                |> Http.toTask
                |> Task.map WebGL.unsafeShader

        vertexRequest =
            Http.getString "./vertex.glsl"
                |> Http.toTask
                |> Task.map WebGL.unsafeShader
    in
    Task.map2 (,) vertexRequest fragmentRequest
        |> Task.attempt (Result.map Load >> Result.withDefault None)


init : ( Model, Cmd Msg )
init =
    ( { time = 0
      , shaders = Nothing
      }
    , loadShaders
    )



-- UPDATE


type Msg
    = Tick Time
    | Load ( VertexShader, FragmentShader )
    | None


update : Msg -> Model -> ( Model, Cmd msg )
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

        None ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    AnimationFrame.diffs Tick



-- VIEW


entity : Time -> ( VertexShader, FragmentShader ) -> El.Element () variation msg
entity time ( vertexShader, fragmentShader ) =
    El.html <|
        WebGL.toHtml
            [ width 320
            , height 320
            ]
            [ WebGL.entity
                vertexShader
                fragmentShader
                mesh
                { time = time / 1000
                , resolution = vec2 320 320
                }
            ]


view : Model -> Html msg
view { time, shaders } =
    let
        content =
            Maybe.map (entity time) shaders
                |> Maybe.withDefault C.loading
    in
    C.layout <| C.item "#EEE" content
