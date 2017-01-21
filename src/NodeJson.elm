module NodeJson exposing (..)

import NodeTypes exposing (..)
import Json.Decode exposing (string, list, lazy, Decoder)
import Json.Decode.Pipeline exposing (decode, required)


decodeNode : Decoder Node
decodeNode =
    decode Node
        |> required "name" string
        |> required "nodes" nodesDecoder


nodesDecoder : Decoder Nodes
nodesDecoder =
    Json.Decode.map Nodes (list (lazy (\_ -> decodeNode)))
