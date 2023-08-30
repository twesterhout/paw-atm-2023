{
  description = "Support scripts for our PAW-ATM 2023 submission";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    let
      pkgs-for = system: import inputs.nixpkgs { inherit system; };

      # Our Python dependencies
      my-python-packages = ps: with ps; [ numpy pandas ];
    in
    {
      packages = inputs.flake-utils.lib.eachDefaultSystemMap (system:
        with (pkgs-for system); {
          default = callPackage ./default.nix { };
        });
      devShells = inputs.flake-utils.lib.eachDefaultSystemMap (system:
        with (pkgs-for system); {
          default = mkShell {
            nativeBuildInputs = [
              (python3.withPackages my-python-packages)
              ghostscript
              gnuplot
              imagemagick
              nodePackages.pyright
              prettierd
              python3Packages.black
              python3Packages.grip
            ];
            shellHook = ''
              export PROMPT_COMMAND=""
              export PS1='🐍 Python ${python3.version} \w $ '
            '';
          };
        });
    };
}
