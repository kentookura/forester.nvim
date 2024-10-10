{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    forest-server.url = "github:kentookura/forest-server";
    forester = {
      # url = "sourcehut:~jonsterling/ocaml-forester";
      url = "/home/kento/ocaml-forester/?ref=iri";
    };
  };
  outputs =
    {
      self,
      forest-server,
      flake-utils,
      nixpkgs,
      forester,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            act
            teseq
            forester.packages.${system}.default
            tree-sitter
            asciinema
            asciinema-agg
            nodePackages.livedown
            nodePackages.katex
            nodejs
            scrot
            imagemagick
            gcc
            screenkey
            tree-sitter
            forest-server.packages.${system}.default
          ];
        };
      }
    );
}
