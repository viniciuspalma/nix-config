_: {
  programs.go = {
    enable = true;
    env.GOPRIVATE = "github.com/goflink/**,github.com/code-visionary/**";
  };
}
