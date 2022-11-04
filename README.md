I've created the following minimal example which you can refer to to understand what my issue is:
https://github.com/marijanp/browser-injection

In my project I'm using a transitive dependency which requires `path` equivalent to this projects `main.js`, this
means that I don't have access to this package and I can't refactor it. And there is not just one of those dependencies rather many, so refactoring is also not feasible.

The build phase in my project looks similar to what happens in `packages.x86_64-linux.inject-browser` in the `flake.nix`.
I export the `node_modules` which I get using `npmlock2nix` and I call `esbuild`.

You can run `nix build .#inject-browser` to see the error message that is thrown, that it doesn't know about the dependency and whether I want to use `node`.

And obviously if I add `--platform=node` the `esbuild` call in the `flake.nix` the build succeeds.
But I actually want to build for the browser, not for node. How do I achieve this?
