{
  hostname,
  ...
}: {
  networking.hostName = hostname;

  # Shared default that works on headless blades and can be reused on blade-2/3.
  networking.networkmanager.enable = true;
}
