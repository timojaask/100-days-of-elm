import UIKit

struct Model {
    let count: Int
    let textFieldValue: String
}

func initApp() -> Model {
    return Model(count: 0, textFieldValue: "")
}

enum Msg {
    case Decrement
    case Increment
    case TextChanged(value: String)
}

func update(msg: Msg, model: Model) -> Model {
    print("Main.update(\(msg))")
    switch msg {
    case .Increment:
        return Model(count: model.count + 1, textFieldValue: model.textFieldValue)
    case .Decrement:
        return Model(count: model.count - 1, textFieldValue: model.textFieldValue)
    case .TextChanged(let value):
        print("Value: \(value)")
        return Model(count: model.count, textFieldValue: value)
    }
}

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
