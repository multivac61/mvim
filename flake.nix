{
  description = "❄️";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable&shallow=1";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      prefix = "nix/";
    };
}
