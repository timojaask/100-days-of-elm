## Day 43

Quick review of day 42:

Narrowing types - using type that's just narrow enough for a given function's arguments or return type is telling us a story of what this function needs and what it does. If a function is returning a `Model`, then we know that it can do any kinds of changes to anything that's inside of the `Model`. If function returns a subset of a model, say, `Session`, then we can guarantee that it doesn't modify any other parts of the model. This is useful for example if we're looking for something that modifies `Document`. We can safely disregard a function that returns `Session`, because we know it cannot possibly affect the document.

Enforcement arguments - sometimes we may use types to enforce certain behavior. For example, if the only way to get `Credentials` is to have user logged in, we can use it to our advantage. For example, if we want `viewFollowButton` function to be called only when logged in, we can make `Credentials` as one of the function arguments, making it impossible to call this function without logging in first. We can do this even before writing any view code. For example, the message that is being sent when the follow button is clicked can me `type Msg = ClickedFollow Credentials User | ...`. Here, we didn't write any view code yet, but still, simply by defining this data structure, we are already forcing the behavior we want -- it's impossible to create a Follow button without requiring logged in user, because the `button [ onClick (ClickedFollow cred user)] [ text "Follow" ]` function requires `Credentials` to be passed, and the compiler won't allow you to compile the code without it.

------------------------

### Using modules for modularity

Watching Richard Feldman's Advanced Elm workshop. He talks about the fact that in Elm the line count in a file doesn't really matter. Splitting things up into multiple files for the sake of reducing line count is not beneficial in Elm. It is beneficial in languages like JavaScript. The difference is that in Elm, functions are pure, and you can look at types and decide if a function changes a piece of model or not. In JavaScript, no matter what are the types going in or out of the function, any function can still change anything in its scope, meaning any variables that it has access to. So in JavaScript world it's good to have smaller files appropriately named, so you can find stuff easier, but in Elm, you can rely on types, and it's actually better to have stuff in one file, so you don't have to jump between files when looking for things.

In Elm it only makes sense to break code into separate files, or modules, when you already have a large file, and you identify code that represent conceptually a certain kind of information, and you could hide some of its implementation details from the rest of the code by moving it into its own module. That way you can enforce certain limitations on its usage, such as making sure that `Credentials` record can only be created via `login` function, and not by using its record constructor, by hiding that constructor inside of a module and not exposint it. So modules, just like types, can be used to enforce desirable behavior and reduce the amount of errors your program may have, caching them at compile time.

### Review of things discussed yesterday and today

The things discussed yesterday -- using types to enforce what usage, and modues -- to hide limit the ways you can initialize types -- these two things together make Elm extremely strong language, where you can enforce things to work a certain way even before you write your view code or update logic. These things will be enforced by the compiler, so you won't be able to ship code that breaks those rules.

I'm repeating myself, but repetition is good:

- Use module to limit the way that `Credentials` can be created -- hide the constructor and only allow to have a `Credentials` record as a result of a successful `login` function call, thus guaranteeing that whenever one has a `Credentials` record, it has for sure came as a result of a successful login.

- Use data types to force certain behaviors using those module limited types -- `Follow` message takes `Credentials` as an argument, thus when we write our view code, we cannot display a button that sends a `Follow` message, unless we have `Credentials` and the only way to get `Credentials` is to login first.

Another point discussed is the fact that if all our functions would take and return a top level `Model`, then every function would be a potential culpit for a bug that we may have. However, if we narrow the types down to use only the parts of the model that the function really need, then we can disregard any function that doesn't touch our data, thus making it easier to find the real culpits.