{
  description = "DBCaml is a database library for OCaml";

  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    riot = {
      url = "github:riot-ml/riot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bytestring = {
      url = "github:riot-ml/bytestring";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    atacama = {
      url = "github:suri-framework/atacama";
    };
    serde = {
      url = "github:serde-ml/serde";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        # pkgs = nixpkgs.legacyPackages."${system}".extend (self: super: {
        #   ocamlPackages = super.ocaml-ng.ocamlPackages_5_1;
        # });
        inherit (pkgs) ocamlPackages mkShell;
        inherit (ocamlPackages) buildDunePackage;
        version = "dev";
      in {
        devShells = {
          default = mkShell {
            buildInputs = [
              ocamlPackages.dune_3
              ocamlPackages.ocaml
              ocamlPackages.utop
            ];
            inputsFrom = [
              self'.packages.default
            ];
            packages = builtins.attrValues {
              inherit (pkgs) clang_17 clang-tools_17 pkg-config;
            };
            dontDetectOcamlConflicts = true;
          };
        };
        packages = {
          default = buildDunePackage {
            inherit version;
            pname = "noodle";
            propagatedBuildInputs = with ocamlPackages; [
              inputs'.riot.packages.default
              alcotest
            ];
            src = ./.;
          };
        };
        formatter = pkgs.alejandra;
      };
    };
}
