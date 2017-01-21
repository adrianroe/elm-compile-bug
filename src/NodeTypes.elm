module NodeTypes exposing (..)


type alias Node =
    { name : String
    , nodes : Nodes
    }


type Nodes
    = Nodes (List Node)
