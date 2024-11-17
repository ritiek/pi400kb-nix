{
  description = "Raw HID keyboard forwarder to turn the Pi 400 into a USB keyboard ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    pi400kb = {
      url = "git+https://github.com/Gadgetoid/pi400kb?submodules=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, pi400kb }:
    let
      pkgs = import nixpkgs { system = "aarch64-linux"; };
    in {
      packages.aarch64-linux.default = pkgs.stdenv.mkDerivation {
        pname = "pi400kb";
        version = "0.0.1";

        src = pi400kb;

        buildInputs = with pkgs; [
          cmake
        ];

        nativeBuildInputs = with pkgs; [
          libconfig
        ];

        cmakeFlags = [
          "-D HOOK_PATH=./hook.sh"
          # FIXME: Find a workaround to refer to $out and have it evaluate
          # correctly. Currently, $out gets treated as a literal here.
          # "-D HOOK_PATH=$out/hook.sh"
        ];

        installPhase = ''
          install -Dm755 pi400kb $out/pi400kb
          install -Dm755 ../hook.sh $out/hook.sh
        '';

        # Replace "led0" by "PWR" to comply with upstream changes.
        postFixup = ''
          substituteInPlace $out/hook.sh --replace led0 PWR
        '';
      };

      nixosConfigurations = {
        mySystem = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./pi400kb-service.nix 
          ];
        };
      };
    };
}
