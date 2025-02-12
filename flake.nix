{
  inputs = {
    # Nixpkgs - Unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Flake Utils - For fetching flake inputs
    flake-utils.url = "github:numtide/flake-utils";

    # Flake Compat - For compatibility with nix-legacy
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

    # Komodo source code
    komodo-src = {
      url = "github:moghtech/komodo/v1.16.12";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    komodo-src,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachSystem
    [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ]
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          crossSystem =
            if system == "aarch64-linux"
            then {config = "aarch64-unknown-linux-gnu";}
            else null;
          config.allowUnfreePredicate = pkg:
            builtins.elem (pkgs.lib.getName pkg) [
              "mongodb" # Explicitly allow MongoDB
            ];
        };
      in {
        packages = let
          komodo = pkgs.rustPlatform.buildRustPackage {
            pname = "komodo";
            version = "1.16.12";
            src = komodo-src;
            cargoLock.lockFile = "${komodo-src}/Cargo.lock";

            # Disable all tests
            # doCheck = false;

            # Skip documentation tests
            cargoTestFlags = ["--lib"];

            nativeBuildInputs = [
              pkgs.pkg-config
              pkgs.cmake
            ];

            buildInputs = [
              pkgs.openssl
              pkgs.libgit2
              pkgs.mongodb # Now allowed via predicate
              pkgs.dotenvy
            ];
          };
        in {
          inherit komodo;
          default = komodo;
        };

        # Legacy packages output for nix-build compatibility
        legacyPackages = {
          inherit (self.packages) komodo default;
        };

        apps = {
          periphery = {
            type = "app";
            program = "${self.packages.${system}.komodo}/bin/periphery";
          };
          core = {
            type = "app";
            program = "${self.packages.${system}.komodo}/bin/core";
          };
          komodo = {
            type = "app";
            program = "${self.packages.${system}.komodo}/bin/komodo";
          };
        };
      }
    );
}
