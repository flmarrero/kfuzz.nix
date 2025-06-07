{ lib, stdenv, fetchgit, buildLinux, ... }:

buildLinux {
  version = "mainline";
  modDirVersion = "6.15.0";
  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
    rev = "v6.15";
    sha256 = "sha256-PQjXBWJV+i2O0Xxbg76HqbHyzu7C0RWkvHJ8UywJSCw=";
  };

  kernelPatches = [];

  extraMeta.branch = "mainline";
}