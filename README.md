I want to use the `node_modules` provided by `npmlock2nix` to be aware of the `browser` attribute in `package.json`.
In my project I'm using a transitive dependency which requires `path` equivalent to this projects `main.js`, this
means that I don't have access to this package and I can't refactor it.
The build phase for my project looks similar to what happens in `packages.x86_64-linux.inject-browser`.
I export the `node_modules` which I get using `npmlock2nix` and I call `esbuild`.

You can run `nix build .#inject-browser` to see the error message that is thrown.
However if you add `--platform=node` the `esbuild` call in the `flake.nix` the build succeeds.
But I actually want to build for the browser, not for node. How do I achieve this?
