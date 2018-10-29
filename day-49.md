## Day 49

Now that I've implemented loading any board configuration via URL, I can write integration tests using Cypress.

One issue with running Cypress tests on 2048 is that we need to start local development server first before running tests. We can do this using NPM script, however, starting server might take a second or two, and the first scripts might fail.

To fix this, we can wait until the server is up before starting Cypress. To do this, we can use a tool like `wait-on`. The NPM script looks like this:

```
"test": "yarn start & wait-on http://localhost:8080 && cypress run"
```

This will start the server, wait until the page is available, and only then run cypress tests in command line.

The issue here is that the port `8080` must be available. Also the port is hard-coded in two places -- the `package.json` and `cypress.json`. I can probably improve this by passing the port as an argument to both http-server and Cypress. Or set up an environment variable.

The `yarn test` command should be used on CI, which will kill the `http-server` process after finishing. And if it doesn't kill it, then something needs to change probable, because each subsequent run will start up a new http-server process with next available port number.

For logcal development it's best not to use `yarn test`, and use `yarn start` and then `yarn test-dev` in a separate terminal tab.

Finally I started writing a decent integration test suite for 2048. Not much to write here, this is mostly an exercise in Cypress rather than Elm at this point.