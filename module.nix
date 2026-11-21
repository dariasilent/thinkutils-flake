self: { config, lib, pkgs, ... }:
let
  cfg = config.programs.thinkutils;
in {
  options.programs.thinkutils = {
    enable = lib.mkEnableOption "ThinkUtils, with its passwordless fan helper rule";
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The ThinkUtils package to use.";
    };
    fanControl = lib.mkEnableOption "the thinkpad_acpi fan_control=1 module option" // { default = true; };
    sysfsPermissions = lib.mkEnableOption "persistent write access to CPU and battery sysfs controls for the wheel group";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = [ cfg.package ];
      security.polkit.enable = true;
      environment.etc."polkit-1/rules.d/50-thinkutils.rules".source =
        "${cfg.package}/share/polkit-1/rules.d/50-thinkutils.rules";
    }
    (lib.mkIf cfg.fanControl {
      boot.extraModprobeConfig = "options thinkpad_acpi fan_control=1";
    })
    (lib.mkIf cfg.sysfsPermissions {
      systemd.services.thinkutils-sysfs = {
        description = "Make ThinkPad sysfs controls writable for the wheel group";
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.coreutils ];
        serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
        script = ''
          for f in \
            /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor \
            /sys/devices/system/cpu/intel_pstate/no_turbo \
            /sys/devices/system/cpu/cpufreq/boost \
            /sys/class/power_supply/BAT*/charge_control_start_threshold \
            /sys/class/power_supply/BAT*/charge_control_end_threshold \
            /sys/class/power_supply/BAT*/charge_start_threshold \
            /sys/class/power_supply/BAT*/charge_stop_threshold; do
            if [ -e "$f" ]; then
              chgrp wheel "$f"
              chmod 664 "$f"
            fi
          done
        '';
      };
    })
  ]);
}
