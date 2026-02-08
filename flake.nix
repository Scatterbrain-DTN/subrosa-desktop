{
  description = "Flutter 3.32.0";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:fmeef/nixpkgs/botan3_android";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-master,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersion = "36.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [
            buildToolsVersion
            "36.0.0"
          ];
          platformVersions = [ "36" ];
          abiVersions = [
            "armeabi-v7a"
            "arm64-v8a"
          ];
        };
        unstable = import nixpkgs-unstable {
          inherit system;
        };
        master = import nixpkgs-master {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        androidSdk = androidComposition.androidsdk;
        isMacos = system == "aarch64-darwin" || system == "x86_64-darwin";
      in
      {
        devShell =
          with pkgs;
          (if isMacos then mkShellNoCC else mkShell) rec {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            buildInputs = [
              master.flutter
              androidSdk
              jdk17
              unstable.rustup
              fish
              cmake
              ninja
              meson
              protobuf
              unstable.llvm
              unstable.clang
              fontconfig
            ];
          };
      }
    );
}
