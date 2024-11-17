{ config, pkgs, ... }:

{
  options.services.pi400kb.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable the Raw HID keyboard forwarder to turn the Pi 400 into a USB keyboard service.";
  };

  systemd.services.pi400kb = {
    enable = config.services.pi400kb.enable;
    description = "pi400kb USB OTG Keyboard & Mouse forwarding";
    serviceConfig = {
      ExecStart = "${pkgs.pi400kb}/pi400kb";
      User = "root";
      Group = "root";
      Type = "simple";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
