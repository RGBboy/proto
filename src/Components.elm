module Components exposing
  ( item
  , layout
  , loading
  )

import Element as El
import Element.Attributes as A
import Html exposing (Html)
import Style exposing (StyleSheet)

-- VIEW

stylesheet : StyleSheet () variation
stylesheet =
  Style.styleSheet
    [ Style.style () [] ]

layout : El.Element () variation msg -> Html msg
layout child =
  El.layout stylesheet
    <| El.column ()
        [ A.spacingXY 0 32
        , A.center
        , A.width A.fill
        , A.clipY
        ]
        [ links
        , child
        ]

item : El.Element () variation msg -> El.Element () variation msg
item content =
  El.el ()
      [ A.width (320 |> A.px)
      , A.height (320 |> A.px)
      , A.inlineStyle
          [ ( "background", "#EEE" )
          ]
      ]
      content

loading : El.Element () variation msg
loading =
  El.el ()
    [ A.center
    , A.verticalCenter
    ]
    <| El.text "Loading..."

links : El.Element () variation msg
links =
  El.column ()
    [ A.inlineStyle
        [ ( "text-align", "center" )
        ]
    ]
    [ El.link "/" <|
        El.text "Proto"
    , El.link "/One" <|
        El.text "One"
    , El.link "/Two" <|
        El.text "Two"
    , El.link "/Three" <|
        El.text "Three"
    , El.link "/Four" <|
        El.text "Four"
    , El.link "/Five" <|
        El.text "Five"
    ]
