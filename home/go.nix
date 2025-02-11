_: {
  programs.go = {
    enable = true;
    goPrivate = [
      "github.com/goflink/**"
      "github.com/code-visionary/**"
    ];
  };
}
