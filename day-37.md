## Day 37

So today is going to be a little different. I'm not actually going to write any Elm, but instead try to implement Elm architecture in Swift on iOS platform. Why? Because why not.

So I've been trying a few things, but the last version of the code I ended up with is at [SwiftElmArchitecture](./src/swift/SwiftElmArchitecture/).

Quick run through it:

`Main.swift` is like the entry file in an Elm project. Contains the familiar `Model` and `Msg` types, the `initApp: () -> Model` function (here I called it `initApp` because `init` is a reserved keyword in Swift), also `update: Msg -> Model -> Model` and `render: Model -> ElmUIComponent<Msg>`.

Now we're not rendering HTML here, so `Html` got replaced with `ElmUIComponent`. Where I would normally use a union type in Elm, I'm using enum in Swift, which is very similar, and has some of the same great properties.

So what is `ElmUIComponent<Msg>`? All the Elm stuff that is not the app is sitting in `Elm.swift`. The different supported components are defined in the `ElmUIComponent<MsgType>` enum:

```
enum ElmUIComponent<MsgType> {
    case View(attributes: [ElmUIAttributes], children: [ElmUIComponent])
    case Label(text: String, attributes: [ElmUIAttributes])
    case Button(title: String, attributes: [ElmUIAttributes], events: [ElmUIEvents<MsgType>])
}
```

There are only three of them so far, but of course more can be added as needed. Attributes and events are also described as enums:

```
enum ElmUIAttributes {
    case BackgroundColor(_: UIColor)
    case ForegroundColor(_: UIColor)
    case Frame(_: CGRect)
}

enum ElmUIEvents<MsgType> {
    case TouchUpInside(msg: MsgType)
}
```

So that's what the render function in the `Main.swift` is supposed to return. Here's how a increment/decrement example could look like:

```
func render(model: Model) -> ElmUIComponent<Msg> {
    let w = 300
    let h = 300
    return .View(
        attributes: [
            .BackgroundColor(.white),
            .Frame(CGRect(x: 0, y: 0, width: w, height: h))
        ],
        children: [
            .Button(
                title: "Decrement",
                attributes: [
                    .ForegroundColor(.black),
                    .Frame(CGRect(x: 0, y: 0, width: w, height: h/3))],
                events: [
                    .TouchUpInside(msg: .Decrement)
                ]
            ),
            .Label(
                text: "Count: \(model.count)",
                attributes: [
                    .ForegroundColor(.black),
                    .Frame(CGRect(x: 0, y: h/3, width: w, height: h/3))
                ]
            ),
            .Button(
                title: "Increment",
                attributes: [
                    .ForegroundColor(.black),
                    .Frame(CGRect(x: 0, y: h/3 * 2, width: w, height: h/3))],
                events: [
                    .TouchUpInside(msg: .Increment)
                ]
            )
        ]
    )
}
```

So this is pretty similar to the way Elm does it, but with some more brackets. The downside of this is having to use frames to define component size and position. It's like we're back in 90's. But I just wanted to make this work, for fun, so we'll see if I do anything about it.

Then there's `class ElmRuntime<MsgType, ModelType>`, which runs the show. It internally holds a pointer to the app's root view controller, so it can output stuff to it's `view`. It also takes in `initApp`, `update`, and `render` functions, so it can setup the initial model, update it, and render the component tree.

The `render` function returns `ElmUIComponent<Msg>`, so that needs to be translated into something that UIKit can understand. So in `Elm.swift` there are functions that traverse `ElmUIComponent<Msg>` tree and turn that into a UIView hierarchy, creating `UIView`, `UILabel`, `UIButton` object, setting their attributes and wiring up event handlers. The event handlers eventually dispatch messages by calling the passed in `update` function, which returns a new `Model`, and then that is used to call `render` function, and so the cycle goes.

There's a `UIControlExtensions.swift` which has an extension that adds ability to use closure for UIControl's target-action pattern.

---

Right now this doesn't do tree diffing, so it re-renders the entire UI on each render cycle. This is obviously very poor, since TextField would lose focus when you're typing. So next I might try to implement some sort of diffing and partial UI update.