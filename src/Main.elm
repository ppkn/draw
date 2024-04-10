module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Events as Events
import Dict exposing (Dict)
import Html exposing (Html, div, fieldset, h1, input, label, main_, text)
import Html.Attributes exposing (checked, classList, for, id, name, type_, value)
import Html.Events exposing (onClick, onMouseDown, onMouseOver)
import Json.Decode



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { cells : Cells, penState : PenState, tool : Tool }


type alias Cells =
    Dict ( Int, Int ) CellState


type CellState
    = Empty
    | Filled


type PenState
    = Up
    | Down


type Tool
    = Pencil
    | Eraser


initialCells : Cells
initialCells =
    let
        indexes =
            List.range 0 7
                |> List.concatMap (\y -> List.range 0 7 |> List.map (\x -> ( x, y )))
    in
    indexes
        |> List.map (\index -> ( index, Empty ))
        |> Dict.fromList


init : () -> ( Model, Cmd Msg )
init _ =
    ( { cells = initialCells, penState = Up, tool = Pencil }, Cmd.none )



-- UPDATE


type Msg
    = MouseOverCell ( Int, Int )
    | MouseDownCanvas
    | MouseUp
    | SelectTool Tool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseOverCell index ->
            case model.penState of
                Up ->
                    ( model, Cmd.none )

                Down ->
                    let
                        newState =
                            if model.tool == Pencil then
                                Filled

                            else
                                Empty
                    in
                    ( { model | cells = model.cells |> Dict.insert index newState }, Cmd.none )

        MouseDownCanvas ->
            case model.penState of
                Up ->
                    ( { model | penState = Down }, Cmd.none )

                Down ->
                    ( model, Cmd.none )

        MouseUp ->
            case model.penState of
                Down ->
                    ( { model | penState = Up }, Cmd.none )

                Up ->
                    ( model, Cmd.none )

        SelectTool tool ->
            ( { model | tool = tool }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Events.onMouseUp (Json.Decode.succeed MouseUp)



-- VIEW


view : Model -> Html Msg
view model =
    main_ []
        [ h1 [] [ text "Draw" ]
        , viewCanvas model
        , viewToolbar model
        ]


viewCanvas : Model -> Html Msg
viewCanvas model =
    div [ id "canvas", onMouseDown MouseDownCanvas ]
        (viewCells model)


viewCells : Model -> List (Html Msg)
viewCells model =
    model.cells
        |> Dict.toList
        |> List.map viewCell


viewCell : ( ( Int, Int ), CellState ) -> Html Msg
viewCell ( index, state ) =
    div [ classList [ ( "cell", True ), ( "filled", state == Filled ) ], onMouseOver (MouseOverCell index) ]
        []


viewToolbar : Model -> Html Msg
viewToolbar { tool } =
    fieldset []
        [ input [ type_ "radio", name "tool", id "pencil", value "pencil", checked (tool == Pencil), onClick (SelectTool Pencil) ] []
        , label [ for "pencil" ] [ text "Pencil" ]
        , input [ type_ "radio", name "tool", id "eraser", value "eraser", checked (tool == Eraser), onClick (SelectTool Eraser) ] []
        , label [ for "eraser" ] [ text "Eraser" ]
        ]
