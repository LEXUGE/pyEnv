{
  description = "Nix Flake for Python Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/x86_64-linux";
    utils.url = "github:numtide/flake-utils";
    utils.inputs.systems.follows = "systems";

    devenv.url = "github:cachix/devenv";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      devenv,
      ...
    }@inputs:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells = {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              (
                { pkgs, config, ... }:
                {
                  # marimo wants node
                  languages.javascript.enable = true;
                  languages.python = {
                    enable = true;
                    uv = {
                      enable = true;
                      sync.enable = true;
                    };
                    venv.enable = true;
                  };

                  # NOTE: uv pip sync will remove the dependencies specified...
                  enterShell = ''
                    uv pip install -r requirements.txt
                  '';
                }
              )
            ];
          };
        };
      }
    );
}
