{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... } @ inputs:
    inputs.utils.lib.eachDefaultSystem (system: {
      devShells.default = let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues (import ./overlays.nix { inherit inputs; });
        };
      in pkgs.devshell.mkShell {
        imports = [
          (pkgs.devshell.importTOML ./devshell.toml)
        ];
      };
    });
}
