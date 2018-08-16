## Day 10

Quick review of day 9:

Yesterday I finished the tree traversing exercises, nothing new there.

Learned about `Maybe`, which is a union type that can be either `Nothing` or `Just a`. Comes in handy when you want some information to be optional. In some languages it's represented as `null`, in some others as Optional. Whenever you want to read a value from Maybe, you need to use `case .. of` and handle both `Nothing` and `Just a` cases. When you return or assign a value of type `Maybe`, you must type either `Nothing` or `Just <your value here>`.

Also learned about `Result`, which is otherwise same as `Maybe`, but also carries an error message. Actually, the two options for `Result` are: `Err error` and `Ok value`. `Result` is usually used at times when things can fail. For example converting String to Int can fail, so that kind of function would return `Result` (`case String.toInt userInputAge of`).

Then I got into `Task`. Problem is, the chapter on tasks is completely missing, so I had to dig around google to find something on it.

Turns out tasks are used to define asynchronous actions in Elm. For example `Time.now` returns a `Task`, because reading time is not synchronous (I guess). In order to utilize that, you'd need to send a `Task.perform` command to the Elm runtime, which will then run it and send you a message with a result. `Task.perform` is used for tasks that are not supposed to fail (such as getting time), and `Task.attempt` is used for tasks that may fail (such as network request).

Now why would you ever want to use a `Task` for doing a network request, when you can just use `Http.send` directly with Elm? Turns out, tasks can be chained, and that's useful in situations where you need output of one task to be passed as a parameter to another task. For example, if you need to get current time and use it as a parameter in an HTTP request, you could chain the `Time.now`, with `Http.get`, passing first result into second. This is handy, because without task, you'd have to receive the time in your `update` function and that's just extra code.

---

Today I'm going to continue with Tasks, and actually write some code, just to test it out and get a feeling for it.

Source code in [task.elm](./errors-tasks/task.elm).

Let's actually write a request that takes time stamp as a parameter. I used `Task.andThen` to chain these two together in a creatively named function `chainedTasks`:
```
chainedTasks : Task Http.Error String
chainedTasks =
  Task.andThen
    (\time -> (titleTask (toString time)))
    Time.now
```

In the code above, the `Time.now` is going to be run first by Elm runtime, then, if successfult, the result (`time`) will be passed into the callback, and a second task, `titleTask`, will be run by Elm.

Of course the `chainedTasks` function doesn't actually run the tasks. It merely returns a `Task` object, which describes what Elm runtime needs to do.

---

In the same example, I got to practice how to send POST requests. Let's check that out quickly.

```
postsUrl : String
postsUrl = "https://jsonplaceholder.typicode.com/posts"

requestBody : String -> Http.Body
requestBody timeStr =
  Http.jsonBody 
    (Json.Encode.object [ ("title", Json.Encode.string timeStr) ] )

titleDecoder : Json.Decode.Decoder String
titleDecoder =
  Json.Decode.field "title" Json.Decode.string

titleRequest : String -> Http.Request String
titleRequest timeStr =
  Http.post postsUrl (requestBody timeStr) titleDecoder
```

This example is pretty contribed, but basically, we encode some JSON to be sent in request body, then we create a decoder which decodes a response JSON from the eventual response. I guess the interesting thing here is how JSON objects are created in Elm to be later used in an HTTP request:
```
Http.jsonBody 
  (Json.Encode.object
    [ ("name", Json.Encode.string "Bob")
    , ("age", Json.Encode.int 25)
    ]
  )
```

However, the next chapter in the guide book goes more in depth with decoding JSON. So tomorrow we'll continue with more of that.

