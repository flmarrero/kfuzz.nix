{
  description = "NixOS based syzkaller setup";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default =
          pkgs.mkShell { nativeBuildInputs = with pkgs; [ nixfmt syzkaller clang-tools ]; };
      });
}
