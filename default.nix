{ stdenv
, util-linux
, python3
, libertine
, ghostscript
, imagemagick
, gnuplot
}:

stdenv.mkDerivation {
  pname = "paw-atm-2023-westerhout";
  version = "1.0";

  src = ./.;

  dontConfigure = true;
  buildPhase = ''
    python3 crawl.py
    python3 analyze.py
    python3 spinpack.py

    gnuplot plot-blockHashed.gnu
    gnuplot plot-enumerateStates.gnu
    gnuplot plot-matrixVectorProduct.gnu
    gnuplot plot-spinpack.gnu
  '';

  installPhase = ''
    mkdir -p $out/share
    cp -r assets $out/share/
  '';

  nativeBuildInputs = [
    (python3.withPackages (ps: with ps; [ numpy pandas ]))
    libertine
    util-linux
    ghostscript
    gnuplot
    imagemagick
  ];
}
