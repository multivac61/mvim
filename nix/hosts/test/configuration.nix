{ inputs, perSystem, ... }:
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-cloud
  ];

  environment.systemPackages = [
    perSystem.self.mvim
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  users.users.test.isNormalUser = true;

  system.stateVersion = "24.05";
}
