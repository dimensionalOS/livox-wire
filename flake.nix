{
  description = "livox-wire: the Livox SDK2 wire format (packets, pcap replay, point/IMU pipeline) as a Rust crate";

  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crate2nix.url = "github:nix-community/crate2nix";
    crate2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-filter, nixpkgs, flake-utils, crate2nix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        name = "livox-wire";
        src = nix-filter.lib { root = ./.; exclude = [ "target" "result" ]; };
        generated = crate2nix.tools.${system}.generatedCargoNix { inherit name src; };
        callWith = mode: import generated {
          inherit pkgs;
          buildRustCrateForPkgs = cratePkgs: crate:
            cratePkgs.buildRustCrate (crate // pkgs.lib.optionalAttrs (mode != null && crate.crateName == name) ({
              release = false;
            } // pkgs.lib.optionalAttrs (mode == "lint") {
              useClippy = true;
              capLints = "forbid";
              extraRustcOpts = (crate.extraRustcOpts or [ ]) ++ [ "-D" "warnings" ];
            }));
        };
      in {
        packages.default = (callWith null).rootCrate.build;
        checks.lint = ((callWith "lint").rootCrate.build).override { runTests = true; testCrateFlags = [ "--list" ]; };
        checks.tests = ((callWith "test").rootCrate.build).override { runTests = true; };
        devShells.default = pkgs.mkShell { packages = [ pkgs.cargo pkgs.rustc pkgs.clippy pkgs.rustfmt ]; };
      });
}
