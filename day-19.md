## Day 19

Quick review of day 18:

Yesterday I was listening to a [talk by Evan Czaplicki](https://www.youtube.com/watch?v=XpDsk374LDE) about growth and organization of code that he usually does.

He talked about how JS developers are trying to write shorter files, because when files get big, the possiblity of some state mutating without you realizing gets too big and causes bugs, which is not the case in Elm, so the files can be generally larger without the drawbacks. Also that in JS people are trying to get the architecture right from the start, because if they don't, then it would be very difficult in a mature project. However, that's not a problem in Elm, because refactoring in Elm is fairly safe, so Evan suggests to not worry about it from the start. Just write code and refactor as needed.

As a side note, I watched another talk by Evan's colleague, in which he warned that even though refactoring in Elm is less risky, it's still a lot of work if you build update logic and the UI. So he suggests to design the data model well before writing everything else, otherwise it'll still cost you time in then end when you decide to change the data structure.

A point that Evan was trying to make in this talk was that in Elm, the code structure should be growing around data structures, not UI components. He gave an example of two similar looking UI's with checkboxes, which could have been implemented as one component, but turned out that the data structures and the logic behind them is quite different. He suggests focusing on designing the data structures that represent the requirements as close as possible, and truing to make impossible states impossible. When data structure itself cannot provide this kind of restriction, then he suggests to build helper functions around it that would restrict the use of the data structure in the desirable way, again, so that it would be impossible to produce weird states.

Once you have distinct pieces of data structures that come with their own set of restricting functions, you could break that structure out of the file into its own module.

According to Evan, it's not a problem to have 600 lines of code in one file when writing Elm. One should really think about what does it mean to have that much code in a file and whether it would actually be better to break it apart or not, suggesting to break only when data structures become distinct from each other.

---

Today I'll continue the video from the point where he started building a data structure that can't fulfil all the requirements without having additional helper logic restricting the use of the data in certain ways. This is where he's writing helper function to narrow down the ways the data can be used to allow only the possible scenarios.

So finally he breaks the data structure out of the main file and into its own module, to hide various implementation details.

To conclude, you should try to enforce rules by using data structures as much as possible, but there are rules ("maximum two fruits can be selected at a time and should remember last selected fruit") that cannot be enforced entirely by only using data structures. That's when it's nice to have a module that hides the implementation detail and maintain the rule safely, even thought we couldn't do it with just data.

Also "don't overdo it". Split code into modules only when necessary -- e.g. only when code becomes confusing enough, that it would benefit from splitting it. Also writing getters and setters is apparently a code smell.

---

Next video I'm gonna go through is [Making Impossible States Impossible by Richard Feldman](https://www.youtube.com/watch?v=IcgmSRJHu_8).

Richard starts off with an example of a CSS library that he designed. Part of it is to allow users to write charset, import, and namespace statments, in addition to the CSS body. CSS spec is very strict regarding the placement and order of these statements, and Richard had some difficulties deciding on how to make sure users of his library don't mess it up. Until he asked his colleague Evan, who suggested to make it simply impossible to insert these statements in a wrong order.

So Richard re-designed the data structure to make it absolutely impossible to mess with the order.

Interesting note on writing tests: before he had to write tests to make sure his logic sorts the CSS statements in correct order in all the cases, in order to generate a valid stylesheet. But then, once he made it impossible to even declare invalid order by re-designing the data structre, he didn't even need the tests anymore, because, well, it's impossible! And I love this quote from the talk:

> Testing is good, impossible is better.

Indeed!

Next he gives an example of how to rewrite a seemingly okay data structure into a better one that makes some impossible states impossible. This is a data structure for a questionnaire:

```
type alias Model =
  { prompts : List String
  , responses : List (Maybe String)
  }
```

A valid state for this data structure could be:

```
{ prompts =
  [ "What's your favorite color?"
  , "What did you eat for breakfast?"
  ]
, responses =
  [ Just "Blue"
  , Nothing
  ]
}
```

However, we can also put this data into an impossible state:

```
{ prompts = []
, responses = [ Just "LOL" ]
}
```

If we end up in this kind of state, the application has obviously failed in some way. Since this sort of state should be impossible, it would be better if it wasn't possible to achieve this in the first place, by structuring the data structure. A simple way to fix this particular example is:

```
type alias Question =
  { prompt : String
  , response : Maybe String
  }
type alias Model =
  { questions : List Question }
```

Now we can't have a response without a question. But what if we needed to navigate from one question to the next? We'd need to represent the current question in some way. Let's say we name this piece of data structure `History`, and pull it out of the model, and add current question to it:

```
type alias History =
  { questions : List Question
  , current : Question
  }
```

A valid state for this could be:

```
{ questions = [ cake, pie, cookies ]
, current = pie
}
```

However, now we can get into an impossible state, such as:

```
{ questions = []
, current = pie
}
```

We could pull the first question out of the list, and since Elm can't have null or undefined values, we would be forced to have at least one question, so we avoid the problem:

```
type alias History =
  { first : Question
  , others : List Question
  
  , current : Question
  }

-- To get the full list of questions:
-- (first :: others)
```

So a valid state for this could be:

```
{ first = cake
, others = [ pie, cookies ]

, current = pie
}
```

However, this could still end up in an impossible state, such as:

```
{ first = cake
, others = [ pie, cookies ]

, current = iceCream
}
```

We can again make that impossible by using what is apparently called a zip list:

```
type alias History =
  { previous : List Question
  , current : Question
  , remaining : List Question
  }
```

A valid state for this could be:

```
{ previous = []
, current = pie
, remaining = []
}

-- OR

{ previous = [ cake, pie ]
, current = cookies
, remaining = [ iceCream ]
}

-- To get the full list of questions:
-- previous ++ [ current ] ++ remaining
```

This data structure is now much better, because it makes the impossible states impossible to achieve! To work with it, we could use some helper functions (I think this is how it could be -- not tested, not even compiled!):

```
-- NOTE: UNTESTED CODE!

back : History -> History
back { previous, current, remaining } =
  if List.length previous > 0 then
    History
      ( List.tail previous )
      ( List.head previous )
      ( [ current ] ++ remaining )
  else
    history

forward : History -> History
forward { previous, current, remaining } =
  if List.length remaining > 0 then
    History
      ( [ current ] ++ previous )
      ( List.head remaining )
      ( List.tail remaining )
  else
    history

answer : String -> History -> History
answer text history =
  if List.length remaining > 0 then
    History
      ( [ { current | response = Just text } ] ++ previous )
      ( List.head remaining )
      ( List.tail remaining )
  else
    History
      previous
      { current | response = Just text }
      remaining


init : Question -> List Question -> History
init current remaining =
  History
    []
    current
    remaining
```

Moving all this code into its own module can have some additional benefits -- so that people wouldn't be accessing the internal structure of the data type, e.g. by addressing `history.current` directly, we could hide it. You know, because previously we had a version where we had `history.questions`, but now we changed internal structure and that thing is no longer accessible. Ideally, users of this API should know about internal changes that don't actually change the functionality. So we could actually not expose the `History` type alias to the outside world at all, so they wouldn't even know how it's made!

What we could do here, is instead of exposing `History` as a type alias, we could wrap it into a union type, which has *only one constructor*:

```
type History =
  History
    { previous : List Question
    , current : Question
    , remaining : List Question
    }
```

This would require us to access the `History` a bit differently internally. We could use `case` statement, or a shortcut, since we only have one case:

```
back : History -> History
back (History { previous, current, remaining }) =
 ...
```

This way we can pull the three fields out of the union type without typing the while `case ... of` thing, since we only have one case.

Now, we could expose this module in the following way:

```
module Question exposing
  (back, forward, answer, init, History(..))
```

But this would expose the constructor of History, so the user would actually know about its contents (previous, current, and remaining), which we want to avoid, because we might change that in future, and we don't wanna be worrying about that.

So instead, we could choose to expose the `History` type, but not expose its constructors. So people can still use the type, but not construct it:

```
module Question exposing
  (back, forward, answer, init, History)
```

Great! Now no one can see the insides of our `History` type. But then how do people access the questions, etc? Well, we will allow people to do it in a controlled way, which should remain unchanged, even after the internals of our module change in the future:

```
questions : History -> List Question
questions { previous, current, remaining } =
  (previous ++ [ current ] ++ remaining)

currentQuestion : History -> Question
currentQuestion { current } =
  current
```

Great! This is a great module, that allows us to use the list of questions easily, without worrying how they are implemented internally. And internally we can use a zip list to guarrantee that things cannot go wrong with it.

Now let's say that back in the main module we wanna write a code that would represent a status bar with some status text:

```
type alias Model =
  { status : Maybe String
  , ... the rest of the model ...
  }
```

This could say either nothing, or "Question created!", or "Question deleted!". And it would be convenient if question is deleted, we'd be able to undo it: "Question deleted. **[undo]**". So we need to store the deleted question somewhere, so we can restore it if so needed:

```
type alias Model =
  { status : Maybe String
  , questionToRestore : Maybe Question
  }
```

Some states that we could have:

```
{ status : Just "Question created!"
, questionToRestore : Nothing
}

{ status : Just "Question deleted!"
, questionToRestore : Just someQuestion
}

{ status : Nothing
, questionToRestore = Just someQuestion
}

{ status : Just "Question deleted!"
, questionToRestore = Nothing
}
```

As you can see, the first two are valid states, but the last two should be impossible! So how do we make sure that we avoid that? Let's replace the two `Maybe`s with one union type:

```
type Status
  = NoStatus
  | TextStatus String
  | DeletedStatus String Question
```

This way we avoid both impossible states and we are forced to treat all the correct states in our application.

So something to consider here:

> Two Maybes often means that we should consider a union type.
> Do we want two lists, or do we want one list with two fields per element?
> Can we revise our implementation without breaking builds? Has to be considered *ahead of time*.