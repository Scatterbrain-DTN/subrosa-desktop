{
description = "Flutter 3.32.0";
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  flake-utils.url = "github:numtide/flake-utils";
};
outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs  {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      buildToolsVersion = "35.0.0";
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        buildToolsVersions = [ buildToolsVersion "35.0.0" ];
        platformVersions = [ "36"];
        abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
      };
      unstable = import nixpkgs-unstable {
	inherit system;
     };
      androidSdk = androidComposition.androidsdk;
    in
    {
      devShell =
        with pkgs; mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          buildInputs = [
            unstable.flutter
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
    });
}

