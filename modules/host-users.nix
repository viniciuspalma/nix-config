{
  hostname,
  username,
  ...
}:
#############################################################
#
#  Host & Users configuration
#
#############################################################
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  # `system.defaults.smb.*` writes via `defaults` to a protected SystemConfiguration domain.
  # Current macOS rejects that write during activation, so keep host naming on scutil-backed options.

  system.primaryUser = username;

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];
}
