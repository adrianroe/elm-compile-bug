module Main exposing (..)

import NodeTypes exposing (..)
import NodeJson exposing (..)
import Html exposing (Html, text)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)


main : Html msg
main =
    text <| toString <| Json.Decode.decodeString decodeNode test_json


test_json : String
test_json =
    """
{
  "name": "The node",
  "nodes": []
}
"""
