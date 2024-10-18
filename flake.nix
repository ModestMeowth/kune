{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";

    hooks.url = "github:cachix/git-hooks.nix";

    parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { ... }@inputs:
    let
      genPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues (import ./overlays.nix { inherit inputs; });
        };
    in
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [
        inputs.devshell.flakeModule
        inputs.hooks.flakeModule
        inputs.treefmt.flakeModule
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = genPkgs system;

          treefmt.config = {
            projectRootFile = "flake.nix";

            programs.nixfmt.enable = true;
            programs.taplo.enable = true;
            programs.yamlfmt.enable = true;

            settings.global.excludes = [ "*.sops.*" ];
          };

          pre-commit.settings.hooks = {
            treefmt.enable = true;
            pre-commit-hook-ensure-sops = {
              enable = true;
              files = "^\w+\.sops\.";
            };
          };

          devShells.default = pkgs.devshell.mkShell {
            imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          };
        };
    };
}
