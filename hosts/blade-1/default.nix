{
  kind = "blade";
  deployment = "nixos";
  system = "aarch64-linux";
  homeModule = ./home.nix;
  nixosModule = ./nixos.nix;
  diskoModule = ./disko.nix;
}
