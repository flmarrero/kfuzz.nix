{ config, pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (import ./kernel.nix {
        inherit (pkgs) lib stdenv fetchgit buildLinux;
    });

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPatches = [{
      name = "fuzzing-kernel-config";
      patch = null;
      extraConfig = ''
        # Coverage & Debugging
        KCOV y
        KCOV_INSTRUMENT_ALL y
        DEBUG_INFO y
        DEBUG_KERNEL y
        DEBUG_LIST y
        DEBUG_OBJECTS y
        DEBUG_SLAB y
        DEBUG_VM y
        STACKTRACE y
        GDB_SCRIPTS y

        # Address Sanitizer
        KASAN y
        KASAN_INLINE y
        KASAN_STACK y

        # Race Detector
        KCSAN y
        KCSAN_REPORT_ONCE y

        # Lockup Detection
        LOCKUP_DETECTOR y
        HARDLOCKUP_DETECTOR y
        SOFTLOCKUP_DETECTOR y
        DETECT_HUNG_TASK y

        # Crash Dumps
        CRASH_DUMP y
        PROC_VMCORE y
        VMCOREINFO y

        # Panic handling
        PANIC_ON_OOPS y
        BUG y
        SCHED_STACK_END_CHECK y

        # Other useful options
        MAGIC_SYSRQ y
        DEBUG_FS y
        FAULT_INJECTION y
        FAULT_INJECTION_DEBUG_FS y
      '';
    }];
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
}
