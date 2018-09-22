import UIKit

enum ElmUIAttributes {
    case BackgroundColor(_: UIColor)
    case ForegroundColor(_: UIColor)
    case Frame(_: CGRect)
}

enum ElmUIEvents<MsgType> {
    case TouchUpInside(msg: MsgType)
}

enum ElmUIComponent<MsgType> {
    case View(attributes: [ElmUIAttributes], children: [ElmUIComponent])
    case Label(text: String, attributes: [ElmUIAttributes])
    case Button(title: String, attributes: [ElmUIAttributes], events: [ElmUIEvents<MsgType>])
}

class ElmRuntime<MsgType, ModelType> {
    
    let rootViewController: UIViewController
    let update: (MsgType, ModelType) -> ModelType
    let render: (ModelType) -> ElmUIComponent<MsgType>
    
    var model: ModelType
    
    init(rootViewController: UIViewController, initApp: () -> ModelType, update: @escaping (MsgType, ModelType) -> ModelType, render: @escaping (ModelType) -> ElmUIComponent<MsgType>) {
        self.rootViewController = rootViewController
        self.update = update
        self.render = render
        self.model = initApp()
        
        self.rootViewController.view = elmRender(component: render(self.model))
    }
    
    func sendMessage(message: MsgType) {
        self.model = update(message, model)
        self.rootViewController.view = elmRender(component: render(self.model))
    }
    
    func elmRender(component: ElmUIComponent<MsgType>) -> UIView {
        switch component {
        case .View(let attributes, let children):
            return renderView(attributes: attributes, children: children)
        case .Label(let text, let attributes):
            return renderLabel(text: text, attributes: attributes)
        case .Button(let title, let attributes, let events):
            return renderButton(title: title, attributes: attributes, events: events)
        }
    }
    
    func renderView(attributes: [ElmUIAttributes], children: [ElmUIComponent<MsgType>]) -> UIView {
        let view = UIView(frame: CGRect.null)
        attributes.forEach { (attribute) in
            switch attribute {
            case .BackgroundColor(let color):
                view.backgroundColor = color
            case .ForegroundColor(_):
                // Not a valid attribute for UIView
                break
            case .Frame(let frame):
                view.frame = frame
            }
        }
        children.forEach { (child) in
            view.addSubview(elmRender(component: child))
        }
        return view
    }
    
    func renderLabel(text: String, attributes: [ElmUIAttributes]) -> UIView {
        let view = UILabel(frame: CGRect.null)
        view.text = text
        attributes.forEach { (attribute) in
            switch attribute {
            case .BackgroundColor(let color):
                view.backgroundColor = color
            case .ForegroundColor(let color):
                view.textColor = color
            case .Frame(let frame):
                view.frame = frame
            }
        }
        return view
    }
    
    func renderButton(title: String, attributes: [ElmUIAttributes], events: [ElmUIEvents<MsgType>]) -> UIView {
        let view = UIButton(frame: CGRect.null)
        view.setTitle(title, for: .normal)
        attributes.forEach { (attribute) in
            switch attribute {
            case .BackgroundColor(let color):
                view.backgroundColor = color
            case .ForegroundColor(let color):
                view.setTitleColor(color, for: .normal)
            case .Frame(let frame):
                view.frame = frame
            }
        }
        events.forEach { (event) in
            switch event {
            case .TouchUpInside(let msg):
                view.addAction(for: .touchUpInside) { [weak self] in
                    self?.sendMessage(message: msg)
                }
            }
        }
        return view
    }
}




