{ flake, ... }:
{
  home.stateVersion = "25.05";
  imports = [ flake.homeModules.default ];
}
