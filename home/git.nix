{
  lib,
  username,
  useremail,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = "openpgp";

    includes = [
      {
        # use diffrent email & name for work
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];

    ignores = [
      ".DS_Store"
      ".idea"
      ".vscode"
      ".direnv"
      ".envrc"
      ".nix-bin"
      ".codex"
    ];

    signing = {
      key = "C572BAB2A35C7EEF";
      signByDefault = true;
    };

    settings = {
      user = {
        # Personal identity is the safe default outside the work checkout.
        name = "viniciuspalma";
        email = useremail;
      };
      alias = {
        # common aliases
        br = "branch";
        co = "checkout";
        st = "status";
        ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
        ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        amend = "commit --amend -m";

        # aliases for submodule
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      # The longest match wins: the work organization takes its dedicated
      # identity before the personal default catches all other GitHub URLs.
      url."git@github-work:chocoapp/".insteadOf = [
        "git@github.com:chocoapp/"
        "ssh://git@github.com/chocoapp/"
        "https://github.com/chocoapp/"
      ];
      url."git@github-personal:".insteadOf = [
        "git@github.com:"
        "ssh://git@github.com/"
        "https://github.com/"
      ];
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "side-by-side";
    };
  };
}
