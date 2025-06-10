{ 
  pkgs
}:

let
  kernel = pkgs.linuxPackages_testing.kernel;
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
in
stdenv.mkDerivation {
  pname = "kfuzz-test-driver";
  version = "0.0.0-dev";

  src = ./.;

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" "format" ];

  makeFlags = kernel.makeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildFlags = [ "modules" ];
}
