{ pkgs, ...}: {

##########################################################################
# 
#  Install all apps and packages here.
#
#  NOTE: Your can find all available options in:
#    https://daiderd.com/nix-darwin/manual/index.html
# 
# TODO Fell free to modify this file to fit your needs.
#
##########################################################################

# Install packages from nix's official package repository.
#
# The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
# But on macOS, it's less stable than homebrew.
#
# Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    git
      coreutils-full
      findutils
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
# 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [
      "homebrew/cask-fonts"
	"homebrew/services"
	"homebrew/cask-versions"
	"cfergeau/crc"
    ];

# `brew install`
# TODO Feel free to add your favorite apps here.
    brews = [
      "vfkit"
    ];

# `brew install --cask`
# TODO Feel free to add your favorite apps here.
    casks = [
      "google-chrome"
	"1password"
	"postman"
	"wifiman"

# IM & audio & remote desktop & meeting
	"telegram"
	"discord"

	"anki"
	"iina" # video player
	"raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
	"stats" # beautiful system monitor

# Development
	"insomnia" # REST client
	"wireshark" # network analyzer
    ];
  };
	      }
