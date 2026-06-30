{
  description = "dangreco/os";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.git-hooks.flakeModule ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        { config, pkgs, ... }:
        let
          __zed = pkgs.writers.writeJSON "settings.json" {
            languages.YAML = {
              formatter = "language_server";
              format_on_save = "on";
            };
          };
          tools = with pkgs; [
            go-task
            podman
            buildah
            skopeo
            cosign
            yamlfmt
            yamllint
            shfmt
            shellcheck
          ];
        in
        {
          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            yamlfmt.enable = true;
            yamllint.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
          };

          devShells = {
            default = pkgs.mkShell {
              packages = tools;
              shellHook = ''
                mkdir -p .zed
                ln -sf ${__zed} .zed/settings.json
                ${config.pre-commit.shellHook}
              '';
            };
            ci = pkgs.mkShell {
              packages = tools;
              shellHook = config.pre-commit.shellHook;
            };
          };
        };
    };
}
