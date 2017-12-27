module Main exposing (main)

import Element as El
import Element.Attributes as A
import Html exposing (Html)
import Style exposing (StyleSheet)
import One.Main as One



main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , subscriptions = subscriptions
    , update = update
    }



-- MODEL

type alias Model =
  { one : One.Model
  }

init : (Model, Cmd Msg)
init =
  let
    (one, command) = One.init
  in
  ( { one = one
    }
  , Cmd.map OneMessage command
  )



-- UPDATE

type Msg
  = OneMessage One.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update (OneMessage message) model =
  let
    (one, command) = One.update message model.one
  in
    ( { model | one = one
      }
    , Cmd.map OneMessage command
    )



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  One.subscriptions model.one
    |> Sub.map OneMessage



-- VIEW

stylesheet : StyleSheet () variation
stylesheet =
  Style.styleSheet
    [ Style.style () [] ]

view : Model -> Html msg
view model =
  let
    content =
      One.view model.one
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
