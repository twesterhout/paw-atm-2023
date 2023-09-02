{
  description = "PAW-ATM 2023";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      packages = { };
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          tectonic
          texlab
          python3Packages.pygments
        ];
      };
      formatter = pkgs.nixpkgs-fmt;
    }
  );
}
