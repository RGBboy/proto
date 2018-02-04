module Main exposing (main)

import AnimationFrame
import Array exposing (Array)
import Components as C
import Element as El
import Html exposing (Html)
import Html.Attributes exposing (width, height)
import Http
import Json.Decode as Decode exposing (Decoder)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Result
import Task
import Time exposing (Time)
import WebGL exposing (Mesh, Shader)


-- 3D Normal Shading

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
face : Vec3 -> Vec3 -> Vec3 -> (Vertex, Vertex, Vertex)
face a b c =
  let
    u = Vec3.sub b a
    v = Vec3.sub c a
    normal = Vec3.normalize (Vec3.cross u v)
  in
    (Vertex a normal, Vertex b normal, Vertex c normal)

type alias Uniforms =
  { projection : Mat4
  , view : Mat4
  , model : Mat4
  }

uniforms : Float -> Uniforms
uniforms t =
  { projection = Mat4.makePerspective 45 1 0.01 100
  , view = Mat4.makeLookAt (vec3 0 10 20) (vec3 0 4 0) (vec3 0 1 0)
  , model = Mat4.makeRotate (2 * t) (vec3 0 1 0)
  }

type alias VertexShader =
  Shader Vertex Uniforms { vNormal : Vec3 }

type alias FragmentShader =
  Shader {} Uniforms { vNormal : Vec3 }

type alias Model =
  { time : Time
  , shaders : Maybe (Mesh Vertex, VertexShader, FragmentShader)
  }

loadShaders : Cmd Msg
loadShaders =
  let
    meshRequest = Http.getString "/bunny.json"
      |> Http.toTask
      |> Task.map (toMesh)
    vertexRequest = Http.getString "./vertex.glsl"
      |> Http.toTask
      |> Task.map (WebGL.unsafeShader)
    fragmentRequest = Http.getString "./fragment.glsl"
      |> Http.toTask
      |> Task.map (WebGL.unsafeShader)
  in
    Task.map3 (,,) meshRequest vertexRequest fragmentRequest
      |> Task.attempt ((Result.map Load) >> (Result.withDefault None))

decodeVec3 : Decoder Vec3
decodeVec3 =
  Decode.map3 Vec3.vec3
    (Decode.index 0 Decode.float)
    (Decode.index 1 Decode.float)
    (Decode.index 2 Decode.float)

decodeCell : Decoder (Int, Int, Int)
decodeCell =
  Decode.map3 (,,)
    (Decode.index 0 Decode.int)
    (Decode.index 1 Decode.int)
    (Decode.index 2 Decode.int)

decodeCells : Decoder (List (Int, Int, Int))
decodeCells =
  Decode.at ["cells"] (Decode.list decodeCell)

decodePositions : Decoder (Array Vec3)
decodePositions =
  Decode.at ["positions"] (Decode.array decodeVec3)

origin : Vec3
origin =
  Vec3.vec3 0 0 0

toFace : Array Vec3 -> (Int, Int, Int) -> (Vertex, Vertex, Vertex)
toFace positions (indexA, indexB, indexC) =
  let
    a = Array.get indexA positions |> Maybe.withDefault origin
    b = Array.get indexB positions |> Maybe.withDefault origin
    c = Array.get indexC positions |> Maybe.withDefault origin
  in
    face a b c

toFaces : Array Vec3 -> List (Int, Int, Int) -> Mesh Vertex
toFaces positions cells =
  List.map (toFace positions) cells
    |> WebGL.triangles

decodeMesh : Decoder (Mesh Vertex)
decodeMesh =
  Decode.map2 toFaces decodePositions decodeCells

emptyMesh : Mesh Vertex
emptyMesh =
  WebGL.triangles <| []

toMesh : String -> Mesh Vertex
toMesh json =
  Decode.decodeString decodeMesh json
    |> Result.withDefault emptyMesh

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
  | Load (Mesh Vertex, VertexShader, FragmentShader)
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

entity : Time -> (Mesh Vertex, VertexShader, FragmentShader) -> El.Element () variation msg
entity time (mesh, vertexShader, fragmentShader) =
  El.html <|
    WebGL.toHtml
      [ width 320
      , height 320
      ]
      [ WebGL.entity
          vertexShader
          fragmentShader
          mesh
          (uniforms (time / 5000))
      ]

view : Model -> Html msg
view { time, shaders } =
  let
    content = Maybe.map (entity time) shaders
      |> Maybe.withDefault C.loading
  in
    C.layout <| C.item "#EEE" content
