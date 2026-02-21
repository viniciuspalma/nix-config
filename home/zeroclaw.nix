{pkgs, self, ...}: {
  home.packages = [
    self.packages.${pkgs.system}.zeroclaw
  ];

  home.shellAliases = {
    zc = "zeroclaw";
  };
}
