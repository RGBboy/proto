module Two.Main exposing
  ( Model
  , init
  , Msg
  , update
  , subscriptions
  , view
  )

import AnimationFrame
import Color exposing (Color)
import Element as El
import Element.Attributes as A
import Html exposing (Html)
import Html.Attributes exposing (width, height)
import Http
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Result
import Task
import Time exposing (Time)
import WebGL exposing (Mesh, Shader)



-- MODEL

type alias Vertex =
  { color : Vec3
  , position : Vec3
  }

face : Color -> Vec3 -> Vec3 -> Vec3 -> Vec3 -> List (Vertex, Vertex, Vertex)
face rawColor a b c d =
  let
    color =
      let c = Color.toRgb rawColor in
      vec3
          (toFloat c.red / 255)
          (toFloat c.green / 255)
          (toFloat c.blue / 255)

    vertex position =
        Vertex color position
  in
    [ (vertex a, vertex b, vertex c)
    , (vertex c, vertex d, vertex a)
    ]

cube : Mesh Vertex
cube =
  let
    rft = vec3  1  1  1   -- right, front, top
    lft = vec3 -1  1  1   -- left,  front, top
    lbt = vec3 -1 -1  1
    rbt = vec3  1 -1  1
    rbb = vec3  1 -1 -1
    rfb = vec3  1  1 -1
    lfb = vec3 -1  1 -1
    lbb = vec3 -1 -1 -1
  in
    WebGL.triangles <| List.concat <|
      [ face Color.green  rft rfb rbb rbt   -- right
      , face Color.blue   rft rfb lfb lft   -- front
      , face Color.yellow rft lft lbt rbt   -- top
      , face Color.red    rfb lfb lbb rbb   -- bottom
      , face Color.purple lft lfb lbb lbt   -- left
      , face Color.orange rbt rbb lbb lbt   -- back
      ]

type alias Uniforms =
  { rotation : Mat4
  , perspective : Mat4
  , camera:Mat4
  , shade:Float
  }

uniforms : Time -> Uniforms
uniforms t =
  { rotation = Mat4.mul (Mat4.makeRotate (3 * t) (vec3 0 1 0)) (Mat4.makeRotate (2 * t) (vec3 1 0 0))
  , perspective = Mat4.makePerspective 45 1 0.01 100
  , camera = Mat4.makeLookAt (vec3 0 0 5) (vec3 0 0 0) (vec3 0 1 0)
  , shade = 0.8
  }

type alias VertexShader =
  Shader Vertex Uniforms { vcolor : Vec3 }

type alias FragmentShader =
  Shader {} Uniforms { vcolor : Vec3 }

type alias Model =
  { time : Time
  , shaders : Maybe (VertexShader, FragmentShader)
  }

loadShaders : Cmd Msg
loadShaders =
  let
    fragmentRequest = Http.getString "./Two/fragment.glsl"
      |> Http.toTask
      |> Task.map (WebGL.unsafeShader)
    vertexRequest = Http.getString "./Two/vertex.glsl"
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
          cube
          (uniforms (time / 5000))
      ]

view : Model -> El.Element () variation msg
view { time, shaders } =
  Maybe.map (entity time) shaders
    |> Maybe.withDefault El.empty
