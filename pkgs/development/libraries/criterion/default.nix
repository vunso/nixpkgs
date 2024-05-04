{ lib, stdenv, fetchFromGitHub, boxfort, meson, libcsptr, pkg-config, gettext
, cmake, ninja, protobuf, libffi, libgit2, dyncall, nanomsg, nanopbMalloc
, python3Packages }:

let
  # follow revisions defined in .wrap files
  debugbreak = fetchFromGitHub {
    owner = "MrAnno";
    repo = "debugbreak";
    rev = "83bf7e933311b88613cbaadeced9c2e2c811054a";
    sha256 = "sha256-OPrPGBUZN73Nl5NMEf/nME843yTolt913yjut3rAos0=";
  };

  klib = fetchFromGitHub {
    owner = "attractivechaos";
    repo = "klib";
    rev = "cdb7e9236dc47abf8da7ebd702cc6f7f21f0c502";
    sha256 = "sha256-+GaI5nXz4jYI0rO17xDhNtFpLlGL2WzeSVLMfB6Cl6E=";
  };

in stdenv.mkDerivation rec {
  pname = "criterion";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "Snaipe";
    repo = "Criterion";
    rev = "v${version}";
    sha256 = "sha256-5GH7AYjrnBnqiSmp28BoaM1Xmy8sPs1atfqJkGy3Yf0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ meson ninja cmake pkg-config protobuf ];

  buildInputs = [
    boxfort.dev
    dyncall
    gettext
    libcsptr
    nanomsg
    nanopbMalloc
    libgit2
    libffi
  ];

  nativeCheckInputs = with python3Packages; [ cram ];

  doCheck = true;

  prePatch = ''
    cp -r ${debugbreak} subprojects/debugbreak
    cp -r ${klib} subprojects/klib

    for dep in "debugbreak" "klib"; do
      local meson="$dep/meson.build"

      chmod +w subprojects/$dep
      cp subprojects/packagefiles/$meson subprojects/$meson
    done
  '';

  postPatch = ''
    patchShebangs ci/isdir.py src/protocol/gen-pb.py
  '';

  outputs = [ "dev" "out" ];

  meta = with lib; {
    description = "A cross-platform C and C++ unit testing framework for the 21th century";
    homepage = "https://github.com/Snaipe/Criterion";
    license = licenses.mit;
    maintainers = with maintainers; [
      thesola10
      Yumasi
      sigmanificient
    ];
    platforms = platforms.unix;
  };
}
