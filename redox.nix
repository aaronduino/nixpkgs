import ./default.nix {
    crossSystem = {
        config = "x86_64-unknown-redox";
        libc = "relibc";
        useRedoxPrebuilt = true;
    };
}