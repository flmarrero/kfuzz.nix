{ config, pkgs, lib, ... }:
let testmod = import ./test { inherit pkgs; };
in
{
  boot = {
    kernelPackages = pkgs.linuxPackagesFor
      (pkgs.linuxPackages_testing.kernel.override {
        structuredExtraConfig = with lib.kernel; {
          # Coverage & Debugging
          KCOV = yes;
          KCOV_INSTRUMENT_ALL = yes;
          DEBUG_INFO = yes;
          DEBUG_KERNEL = yes;
          DEBUG_LIST = yes;
          DEBUG_OBJECTS = yes;
          DEBUG_SLAB = yes;
          DEBUG_VM = yes;
          STACKTRACE = yes;
          GDB_SCRIPTS = yes;

          # Address Sanitizer
          KASAN = yes;
          KASAN_INLINE = yes;
          KASAN_STACK = yes;
          KCSAN = yes;
          KCSAN_REPORT_ONCE = yes;

          # Lockup Detection
          LOCKUP_DETECTOR = yes;
          HARDLOCKUP_DETECTOR = yes;
          SOFTLOCKUP_DETECTOR = yes;
          DETECT_HUNG_TASK = yes;

          # Crash Dumps
          CRASH_DUMP = yes;
          PROC_VMCORE = yes;
          VMCOREINFO = yes;

          # Panic handling
          PANIC_ON_OOPS = yes;
          BUG = yes;
          SCHED_STACK_END_CHECK = yes;

          # Other useful options
          MAGIC_SYSRQ = yes;
          DEBUG_FS = yes;
          FAULT_INJECTION = yes;
          FAULT_INJECTION_DEBUG_FS = yes;
        };
        ignoreConfigErrors = true;
      });

    extraModulePackages = [ testmod ];

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  users.extraUsers.root.initialHashedPassword = "";

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  networking = {
    firewall.enable = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.100.2";
      prefixLength = 24;
    }];
  };

  system.stateVersion = "25.05";
}
