module Main exposing (main)

import Element as El
import Element.Attributes as A
import Html exposing (Html)
import Style exposing (StyleSheet)
import One.Main as One
import Two.Main as Two



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
  , two : Two.Model
  }

init : (Model, Cmd Msg)
init =
  let
    (oneModel, oneCmd) = One.init
    (twoModel, twoCmd) = Two.init
  in
  ( { one = oneModel
    , two = twoModel
    }
  , Cmd.batch
    [ Cmd.map OneMessage oneCmd
    , Cmd.map TwoMessage twoCmd
    ]
  )



-- UPDATE

type Msg
  = OneMessage One.Msg
  | TwoMessage Two.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    OneMessage message ->
      let
        (oneModel, oneCmd) = One.update message model.one
      in
        ( { model | one = oneModel
          }
        , Cmd.map OneMessage oneCmd
        )
    TwoMessage message ->
      let
        (twoModel, twoCmd) = Two.update message model.two
      in
        ( { model | two = twoModel
          }
        , Cmd.map OneMessage twoCmd
        )



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map OneMessage <| One.subscriptions model.one
    , Sub.map TwoMessage <| Two.subscriptions model.two
    ]



-- VIEW

stylesheet : StyleSheet () variation
stylesheet =
  Style.styleSheet
    [ Style.style () [] ]

item : El.Element () variation msg -> El.Element () variation msg
item content =
  El.el ()
      [ A.width (320 |> A.px)
      , A.height (320 |> A.px)
      , A.inlineStyle
          [ ( "background", "#DDDDDD" )
          ]
      ]
      content

view : Model -> Html msg
view model =
  El.layout stylesheet
    <| El.row ()
        [ A.center
        , A.verticalCenter
        , A.width A.fill
        , A.height A.fill
        ]
        [ El.column ()
            [ A.spacingXY 0 32
            , A.clipY
            , A.inlineStyle
                [ ( "margin", "auto" )
                ]
            ]
            [ item <| One.view model.one
            , item <| Two.view model.two
            ]
        ]
