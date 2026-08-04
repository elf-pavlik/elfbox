{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "mindwalk";
  version = "0.4.0";

  src = fetchurl {
    url = "https://github.com/cosmtrek/mindwalk/releases/download/v${version}/mindwalk_linux_amd64.tar.gz";
    hash = "sha256-T4YbHrF57YUg7ZTxO8q6hm02k+D1nIH8zVJxf/SfI+4=";
  };
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/mindwalk
  '';

  meta = {
    description = "Visualize and explore your codebase";
    homepage = "https://github.com/cosmtrek/mindwalk";
    mainProgram = "mindwalk";
    platforms = [ "x86_64-linux" ];
  };
}
