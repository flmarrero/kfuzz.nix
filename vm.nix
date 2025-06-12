{ pkgs, lib, linux, ... }:
let testmod = import ./test { inherit pkgs linux; };
in {
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (linux.kernel.override {
      structuredExtraConfig = with lib.kernel; {
        # To enable coverage collection, which is extremely important for effective fuzzing:
        KCOV = yes;
        KCOV_INSTRUMENT_ALL = yes;
        KCOV_ENABLE_COMPARISONS = yes;
        DEBUG_FS = yes;

        # To detect memory leaks using the Kernel Memory Leak Detector (kmemleak):
        DEBUG_KMEMLEAK = yes;

        DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = yes;

        # For detection of enabled syscalls and kernel bitness:
        KALLSYMS = yes;
        KALLSYMS_ALL = yes;

        # For better sandboxing:
        NAMESPACES = yes;
        UTS_NS = yes;
        IPC_NS = yes;
        PID_NS = yes;
        NET_NS = yes;
        CGROUP_PIDS = yes;
        MEMCG = yes;

        # For namespace sandbox:
        USER_NS = yes;

        CONFIGFS_FS = yes;
        SECURITYFS = yes;

        RANDOMIZE_BASE = no;
        CMDLINE_BOOL = yes;
        CMDLINE = "net.ifnames=0";

        # Enable KASAN for use-after-free and out-of-bounds detection:
        KASAN = yes;
        KASAN_INLINE = yes;

        # For testing with fault injection enable the following configs (syzkaller will pick it up automatically):
        FAULT_INJECTION = yes;
        FAULT_INJECTION_DEBUG_FS = yes;
        FAULT_INJECTION_USERCOPY = yes;
        FAILSLAB = yes;
        FAIL_PAGE_ALLOC = yes;
        FAIL_MAKE_REQUEST = yes;
        FAIL_IO_TIMEOUT = yes;
        FAIL_FUTEX = yes;

        # Any other debugging configs, the more the better, here are some that proved to be especially useful:
        LOCKDEP = yes;
        PROVE_LOCKING = yes;
        DEBUG_ATOMIC_SLEEP = yes;
        PROVE_RCU = yes;
        DEBUG_VM = yes;
        REFCOUNT_FULL = yes;
        FORTIFY_SOURCE = yes;
        HARDENED_USERCOPY = yes;
        LOCKUP_DETECTOR = yes;
        SOFTLOCKUP_DETECTOR = yes;
        HARDLOCKUP_DETECTOR = yes;
        BOOTPARAM_HARDLOCKUP_PANIC = yes;
        DETECT_HUNG_TASK = yes;
        WQ_WATCHDOG = yes;

        # Increase hung/stall timeout to reduce false positive rate:
        DEFAULT_HUNG_TASK_TIMEOUT = 140;
        RCU_CPU_STALL_TIMEOUT = 100;
      };
      ignoreConfigErrors = true;
    });

    #extraModulePackages = [ testmod ];
  };

  users.extraUsers.root = {
    initialHashedPassword = "";
    openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
  };

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  networking.firewall.enable = false;

  environment.systemPackages = [ pkgs.syzkaller ];

  system.stateVersion = "25.05";
}
