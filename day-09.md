## Day 9

Quick review of day 8:

Learned about `foldr` and `foldl`, which are like reduce.

Then did a bunch of tree traversing exercises. Nothing much here. Continuing with that today.

--- 

### Exercise 7 (continued)

> Try experimenting with different ways to traverse a tree: pre-order, in-order, post-order, depth-first, etc. More info at: http://en.wikipedia.org/wiki/Tree_traversal

Let's use `flatten` as an example.

#### Pre-order (NLR)

```
flattenNLR : Tree a -> List a
flattenNLR tree =
  case tree of
    Empty -> []
    Node v left right ->
      [v] ++ (flattenNLR left) ++ (flattenNLR right)
```

#### In-order (LNR)

```
flattenLNR : Tree a -> List a
flattenLNR tree =
  case tree of
    Empty -> []
    Node v left right ->
      (flattenLNR left) ++ [v] ++ (flattenLNR right)
```

#### Post-order (LRN)

```
flattenLRN : Tree a -> List a
flattenLRN tree =
  case tree of
    Empty -> []
    Node v left right ->
      (flattenLRN left) ++ (flattenLRN right) ++ [v]
```

---

Moving on to [Error Handling and Tasks](https://guide.elm-lang.org/error_handling/).

In this chapter we'll be looking at `Maybe`, `Result`, and `Task`.

### Maybe

`Maybe` in Elm is just another union type, defined like so:
```
type Maybe a = Nothing | Just a
```

This can be used as a type for any optional information, that might or might not exist. Kinda like optional in some languages, or null. Elm compiler will force you to write code that handles both `Nothing` and `Just` cases, as there's no other way to access this information.

One of the [examples](./errors-tasks/maybe.elm) was having a user profile, where user can choose to provide their age, or not:
```
type alias User =
  { name : String
  , age : Maybe Int
  }

sue : User
sue = { name = "Sue", age = Nothing }

tom : User
tom = { name = "Tom", age = Just 24 }
```

### Result

`Result` is like `Maybe`, but also provide an error message, in case an error occurs. So, it's meant for providing results for things that might fail, like making a network request, or converting a string into an int.

```
type Result error value
  = Err error
  | Ok value
```

An interesting basic example of using result in a case statement:

```
view userInputAge =
  case String.toInt userInputAge of
    Err msg ->
      span [class "error"] [text msg]
    
    Ok age ->
      text ("Cool, you're allegedly " ++ age ++ " years old.")
```

### Tasks

> These docs are getting updated for 0.18. They will be back soon! Until then, the docs will give a partial overview.

I turned to google and decided to read the first thing I find. Found Ossi Hanhinen's nice article named [Tasks in Modern Elm](http://ohanhi.com/tasks-in-modern-elm.html). Below are some takaways.

We've already used HTTP library with Elm, where you created a send command and gave it to Elm runtime to process. The HTTP library also allows you to convert the send command into a task. Why would you wanna do that? On its own it's not very useful, as you can convert a task back into a command and sent to Elm, but the cool thing with tasks is that you can **chain** them.

Chaining tasks allows you to execute tasks sequentually, passing a successful result of one task as a parameter to the next task.

For example, if you need to include a current time stamp inside a get request, how would you do that? You could chain `Time.now` and `Http.get` converted into a task. This way you don't need to save the result of `Time.now` into your application state. It will be simply passed into the `Http.get` request as an argument.

---

Next up Google offered me to read Bill Peregoy's article named [Tasks in Elm 0.18](https://becoming-functional.com/tasks-in-elm-0-18-2b64a35fd82e).

In the new version, the tasks are converted into commands by using either `Task.perform` for tasks that cannot fail:

```
Task.perform Success Time.now
```

or `Task.attempt` for tasks that can fail:

```
Task.attempt processTime Time.now
```

In the `attempt` example, the second argument is no longer a Msg, but a function that returns an appropriate Msg, depending on the result of the task. Example:

```
processTime : Result String Time -> Msg
processTime result =
    case result of
        Ok time ->
            Success time
        Err _ ->
            Failure
```

---

Today's time has run out, but I think I should give tasks more attention tomorrow. Should probably write some code that uses tasks, chains tasks, etc, to really grasp it. Peace out!