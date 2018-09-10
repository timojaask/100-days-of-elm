module SelectedItemList exposing (SelectedItemList, init, map, selectedItem, toList)


type SelectedItemList a
    = SelectedItemList
        { firstItems_ : List a
        , selectedItem_ : a
        , lastItems_ : List a
        }


init : List a -> a -> List a -> SelectedItemList a
init firstItems_ selectedItem_ lastItems_ =
    SelectedItemList
        { firstItems_ = firstItems_
        , selectedItem_ = selectedItem_
        , lastItems_ = lastItems_
        }


selectedItem : SelectedItemList a -> a
selectedItem (SelectedItemList selectedItemList) =
    selectedItemList.selectedItem_


toList : SelectedItemList a -> List a
toList (SelectedItemList { firstItems_, selectedItem_, lastItems_ }) =
    firstItems_ ++ (selectedItem_ :: lastItems_)


map : (Bool -> a -> b) -> SelectedItemList a -> List b
map fn (SelectedItemList { firstItems_, selectedItem_, lastItems_ }) =
    List.map (fn False) firstItems_
        ++ (fn True selectedItem_
                :: List.map (fn False) lastItems_
           )


selectItemDefault : a -> a -> SelectedItemList a -> SelectedItemList a
