module NonEmptyList exposing (NonEmptyList, dropOne, filter, head, init, tail, toList)


type NonEmptyList a
    = NonEmptyList
        { head : a
        , tail : List a
        }


init : a -> List a -> NonEmptyList a
init head_ tail_ =
    NonEmptyList { head = head_, tail = tail_ }


toList : NonEmptyList a -> List a
toList (NonEmptyList nonEmptyList) =
    nonEmptyList.head :: nonEmptyList.tail


head : NonEmptyList a -> a
head (NonEmptyList nonEmptyList) =
    nonEmptyList.head


tail : NonEmptyList a -> List a
tail (NonEmptyList nonEmptyList) =
    nonEmptyList.tail


dropOne : NonEmptyList a -> Maybe (NonEmptyList a)
dropOne (NonEmptyList nonEmptyList) =
    case List.head nonEmptyList.tail of
        Nothing ->
            Nothing

        Just newHead ->
            Just (NonEmptyList { head = newHead, tail = List.drop 1 nonEmptyList.tail })


filter : (a -> Bool) -> NonEmptyList a -> Maybe (NonEmptyList a)
filter fn nonEmptyList =
    let
        filteredList =
            List.filter fn (toList nonEmptyList)
    in
    case filteredList of
        [] ->
            Nothing

        head_ :: tail_ ->
            Just (init head_ tail_)
