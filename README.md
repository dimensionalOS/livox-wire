# livox-wire

The Livox SDK2 wire format as a Rust crate: packet parsing (`wire`), pcap replay (`pcap`), and the point/IMU
pipeline (`pipeline`). One copy shared by [dimos](https://github.com/dimensionalOS/dimos)' Mid-360 driver, Point-LIO and
virtual Mid-360 modules.

```toml
livox-wire = { git = "https://github.com/jeff-hykin/livox-wire", rev = "<commit>" }
```

`nix flake check` builds it and runs its tests and clippy.
