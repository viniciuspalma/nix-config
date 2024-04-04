_: {
  programs.go = {
    enable = true;
    goPrivate = [
      "github.com/goflink/**"
    ];
  };
}
