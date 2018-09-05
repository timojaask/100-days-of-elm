module NonNegativeInteger exposing (NonNegativeInteger, fromInt, inc, toInt)


type NonNegativeInteger
    = NonNegativeInteger Int


fromInt : Int -> NonNegativeInteger
fromInt int =
    if int < 0 then
        NonNegativeInteger 0

    else
        NonNegativeInteger int


toInt : NonNegativeInteger -> Int
toInt (NonNegativeInteger int) =
    int


inc : NonNegativeInteger -> NonNegativeInteger
inc (NonNegativeInteger int) =
    NonNegativeInteger (int + 1)
