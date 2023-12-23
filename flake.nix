{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    forester = { url = "/home/kento/projects/ocaml-forester"; };
  };
  outputs = { self, flake-utils, nixpkgs, forester }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ forester.packages.${system}.default ];
        };
      });
}
