{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  name = "test-fetchurl";
  src = pkgs.fetchurl {
    url = "https://nix-test.zebradil.dev:8443/payload.txt";
    hash = "";
    curlOpts = "-v";
  };

  buildPhase = ''
    mkdir -p $out
    cp $src $out/
  '';

  unpackPhase = "true";
}
