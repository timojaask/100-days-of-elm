# Issues with Elm

This document contains a list of things that I felt were difficult or frustrating as I was learning the language and the ecosystem surrounding it. The issues are not necessarily bad, but at least I don't know yet what are the good ways of dealing with them. I'm hoping it's just my incompetence and inexperince, rather than actual issues.

I guess Elm doesn't want to be opinionated about the surrounding tooling, but at the same time I like using opinionated tools, such as Gatsby. I want to be creating websites, not fighting with tools and trying to choose between seemingly equally bad hacks in order to add a PNG image on my website. And it's a shame, because I love Elm as a language and I love the way it lets me write pure, testable, composable functions, without having to worry too much about all the dirty work that the Elm runtime is doing for me.

So here is a list of issues I struggled with so far. Next time I am going to write a document that lists the same issues and various solutions that I find to them. So here's the negative stuff, but stay tuned for the (hopefully) positive solutions!

## Styling the document

One of the first things I do when I make a new website is often setting the background color for the `body` element. I mean, I have the design, it has a green background, so I'm gonna set it. However, it seems like there's no good way of doing that in Elm. Elm doesn't control the `body` element, and this you can't just go ahead and change it's style. Workarounds seem to be many, but they are just that -- workarounds.

## Building and deployment tools

You know how easy it is to setup and deploy a Gatsby project? If you haven't tried Gatsby, let me tell you - it is incredibly easy. You create a project by running `gatsby new` and you get the whole thing set up for you. Deploying to any cloud provider is then as easy as fetching sources from git and running `yarn build` on the CI machine.

I understand that perhaps Elm maintainers don't want to tell you what tools to use for such things and leave it to community to decide, but it doesn't help beginners getting strated. There are some community attempts to make the process easier, such as [create-elm-app](https://www.github.com/halfzebra/create-elm-app), which, however, seems to require ejecting before you can use it on a third-party CI, such as Netlify (I really hope to be proven wrong here!). Another popular one is [elm-webpack-starter](https://github.com/elm-community/elm-webpack-starter), but for some reason it comes bundled with stuff like jQuery and some other JS libraries that seem like an odd choice to be in such a generic starter project. I know I can clean it up myself, but wouldn't it have been better the other way around? As in, a user would add a jQuery library if they need it. There are some other ones that I might look into soon: [elm-app-boilerplate](https://github.com/gkubisa/elm-app-boilerplate) and [elm-starter](https://github.com/splodingsocks/elm-starter).

## Bundling images

This perhaps belongs to the "Building and deployment tools" section, but I feel like it's so important that it requires its own section. I think it's undeniable that adding images to a web page is pretty important. Most websites include some sort of graphics, be it a png, jpg, or svn. But the official Elm documentation doesn't really tell you how to do that. Yeah, you can use the `src` attribute in the `img` tag, but that only helps for the most basic example. Of course you could do just that -- hard code the relative paths of the images into your Elm code, then make sure that when you build your code, it copies the image assets into the right relative paths in the output folder, so they also work in production, but this sounds like a step backward, at least compared to mature tools such as React or Gatsby, which uses React.

Once again, there are multiple workarounds for image bundling, but all of them feel kind of hacky.