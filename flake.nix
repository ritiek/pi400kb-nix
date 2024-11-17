{
  description = "Raw HID keyboard forwarder to turn the Pi 400 into a USB keyboard";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    pi400kb = {
      url = "git+https://github.com/Gadgetoid/pi400kb?submodules=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, pi400kb }: {
    system = "aarch64-linux";
    pkgs = import nixpkgs { system = self.system; };

    packages.${self.system}.default = self.pkgs.stdenv.mkDerivation {
      pname = "pi400kb";
      version = "0.0.1";
      src = pi400kb;
      buildInputs = [ self.pkgs.cmake ];
      nativeBuildInputs = [ self.pkgs.libconfig ];
      cmakeFlags = [ "-D HOOK_PATH=./hook.sh" ];
      installPhase = ''
        install -Dm755 pi400kb $out/bin/pi400kb
        install -Dm755 ../hook.sh $out/bin/hook.sh
      '';
      postFixup = ''
        substituteInPlace $out/bin/hook.sh --replace led0 PWR
      '';
    };

    nixosModules = {
      pi400kb = { config, lib, options, ... }: {
        options.services.pi400kb.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable the Raw HID keyboard forwarder to turn the Pi 400 into a USB keyboard service.";
        };

        config.systemd.services.pi400kb = {
          enable = config.services.pi400kb.enable;
          description = "pi400kb USB OTG Keyboard & Mouse forwarding";
          serviceConfig = {
            ExecStart = "${self.packages.${self.system}.default.out}/bin/pi400kb";
            User = "root";
            Group = "root";
            Type = "simple";
            Restart = "on-failure";
          };
          wantedBy = [ "multi-user.target" ];
        };
      };
    };

    # nixosConfigurations = {
    #   mySystem = nixpkgs.lib.nixosSystem {
    #     system = self.system;
    #     modules = [
    #       self.nixosModules.pi400kb
    #     ];
    #   };
    # };
  };
}
