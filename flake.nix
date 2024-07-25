{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls-overlay.url = "github:zigtools/zls";
  };

  outputs = { 
    self, 
    nixpkgs,
    zig-overlay,
    zls-overlay,
    ...
  }: 
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    zig = zig-overlay.packages.x86_64-linux.master;
    zls = zls-overlay.packages.x86_64-linux.zls.overrideAttrs ( old: {
      nativeBuildInputs = [ zig ]; 
    });
  in
  {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = with pkgs; [
        zls
        zig
        zmqpp
      ];
    };
  };
}
