{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    forester = { url = "sourcehut:~kentookura/ocaml-forester/nvim-support"; };
  };
  outputs = { self, flake-utils, nixpkgs, forester }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            teseq
            forester.packages.${system}.default
            tree-sitter
            asciinema
            asciinema-agg
            nodePackages.livedown
            nodePackages.katex
            nodejs
            scrot
            gh-markdown-preview
            imagemagick
            gcc
            tree-sitter
          ];
          shellHook = "export PATH=$PATH:./node_modules/.bin";
        };
      });
}
