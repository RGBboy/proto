module Main exposing
  ( Model
  , init
  , Msg
  , update
  , subscriptions
  , view
  )

import AnimationFrame
import Color exposing (Color)
import Components as C
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



-- 3D Lambert Shading

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
  { position : Vec3
  , normal : Vec3
  }

-- Note: Faces must be declared in a clockwise order to calculate the
-- normal in the correct direction.
face : Vec3 -> Vec3 -> Vec3 -> Vec3 -> List (Vertex, Vertex, Vertex)
face a b c d =
  let
    u = Vec3.sub b a
    v = Vec3.sub c a
    normal = Vec3.normalize (Vec3.cross u v)
  in
  [ (Vertex a normal, Vertex b normal, Vertex c normal)
  , (Vertex c normal, Vertex d normal, Vertex a normal)
  ]


cube : Mesh Vertex
cube =
  let
    rft = vec3  1  1  1 -- right, front, top
    lft = vec3 -1  1  1 -- left, front, top
    lbt = vec3 -1 -1  1 -- left, back, top
    rbt = vec3  1 -1  1 -- right, back, top
    rbb = vec3  1 -1 -1 -- right, back, bottom
    rfb = vec3  1  1 -1 -- right, front, bottom
    lfb = vec3 -1  1 -1 -- left, front, bottom
    lbb = vec3 -1 -1 -1 -- left, back, bottom
  in
    WebGL.triangles <| List.concat <|
      [ face rft rbt rbb rfb -- right
      , face lft rft rfb lfb -- front
      , face lbt rbt rft lft -- top
      , face rbb lbb lfb rfb -- bottom
      , face lbt lft lfb lbb -- left
      , face rbt lbt lbb rbb -- back
      ]

type alias Uniforms =
  { projection : Mat4
  , view : Mat4
  , model : Mat4
  }

uniforms : Float -> Uniforms
uniforms t =
  { projection = Mat4.makePerspective 45 1 0.01 100
  , view = Mat4.makeLookAt (vec3 0 0 5) (vec3 0 0 0) (vec3 0 1 0)
  , model = Mat4.mul (Mat4.makeRotate (3 * t) (vec3 0 1 0)) (Mat4.makeRotate (2 * t) (vec3 1 0 0))
  }

type alias VertexShader =
  Shader Vertex Uniforms { vNormal : Vec3, vViewPosition : Vec3 }

type alias FragmentShader =
  Shader {} Uniforms { vNormal : Vec3, vViewPosition : Vec3 }

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

view : Model -> Html msg
view { time, shaders } =
  let
    content = Maybe.map (entity time) shaders
      |> Maybe.withDefault C.loading
  in
    C.layout <| C.item content
