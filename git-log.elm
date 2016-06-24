import Html exposing (..)
import Html.App exposing (..)
import Json.Decode exposing (..)
import Http
import Task

testJson = "[{\"filename\":\"CHANGELOG.md\",\"count\":1316},{\"filename\":\"Gemfile.lock\",\"count\":243}]"

main =
  Html.App.program { init = init, subscriptions = \_ -> Sub.none, view = view, update = update }

fileCountDecoder : Decoder (List FileCount)
fileCountDecoder =
  list <| object2 FileCount
    ("filename" := string)
    ("count" := int)

-- MODEL

type alias Model = List FileCount

type alias FileCount = {
  filename : String,
  count : Int
}

init : (Model, Cmd Msg)
init = ([], getJson)

-- UPDATE

type Msg
  = FetchData
  | FetchSucceed Model
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    FetchData ->
      (model, getJson)

    FetchSucceed json ->
      (json, Cmd.none)

    FetchFail _ ->
      (model, Cmd.none)

getJson : Cmd Msg
getJson =
  let url = "http://localhost:9876/"

  in
    Task.perform FetchFail FetchSucceed (Http.get fileCountDecoder url)

-- VIEW

butts : FileCount -> Html a
butts fc =
  li [] [text <| fc.filename ++ ": " ++ (toString fc.count) ]

view : Model -> Html Msg
view model = ul [] <| List.map butts model
