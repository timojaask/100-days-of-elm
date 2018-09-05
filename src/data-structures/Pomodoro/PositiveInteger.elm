module PositiveInteger exposing (PositiveInteger, fromInt, toInt)


type PositiveInteger
    = PositiveInteger Int


fromInt : Int -> PositiveInteger
fromInt int =
    if int < 1 then
        PositiveInteger 1

    else
        PositiveInteger int


toInt : PositiveInteger -> Int
toInt (PositiveInteger int) =
    int
