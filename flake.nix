{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    npmlock2nix = {
      url = "github:nix-community/npmlock2nix";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      npmlock2nix = import inputs.npmlock2nix { inherit pkgs; };

      esbuild = { mapping ? { }, entrypoint, nodeModulesPath, outfile }:
        pkgs.runCommand "esbuild"
          { buildInputs = [ pkgs.nodejs ]; }
          (
            let
              builder =
                builtins.toFile "esbuild.js" ''
                  const esbuild = require('esbuild');
                  const plugin = require('node-stdlib-browser/helpers/esbuild/plugin');
                  const stdLibBrowser = require('node-stdlib-browser');

                  esbuild.build({
                      entryPoints: [ "${entrypoint}" ],
                      nodePaths: [process.env.TARGET_NODE_PATH],
                      bundle: true,
                      write: false,
                      inject: [require.resolve('node-stdlib-browser/helpers/esbuild/shim')],
                      define: ${builtins.toJSON mapping},
                      plugins: [plugin(stdLibBrowser)]
                    }).then((result) => process.stdout.write(result.outputFiles[0].text));
                '';
            in
            ''
              mkdir $out
              # This is the node path for the package that we want to build
              export TARGET_NODE_PATH=${nodeModulesPath}
              # This is the node path required for the builder script
              NODE_PATH=${ (npmlock2nix.node_modules { src = ./builder; }) + /node_modules } \
                node ${builder} > $out/${outfile}
            ''
          );

      packageJSON = builtins.fromJSON (builtins.readFile ./package.json);
    in
    {
      packages.x86_64-linux.inject-browser-with-plugin =
        esbuild {
          entrypoint = ./src/main.js;
          nodeModulesPath = (npmlock2nix.node_modules { src = ./src; }) + /node_modules;
          outfile = "client.js";
        };

      packages.x86_64-linux.inject-browser =
        pkgs.runCommand
          "esbuild"
          { nativeBuildInputs = [ pkgs.esbuild ]; } ''
          cp ${./src/main.js} entrypoint.js
          mkdir -p $out
          export NODE_PATH=${(npmlock2nix.node_modules { src = ./src; }) + /node_modules}
          esbuild --bundle --outfile="$out/main.js" --log-limit=0 entrypoint.js
        '';
    };
}
