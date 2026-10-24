{
  description = "JieLi AC79 SDK and toolchain for FM1 firmware builds";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      # Toolchain is x86_64-linux only (JieLi ships x86_64 binaries).
      # On aarch64-linux it works via qemu-user-static but that's not
      # modeled here: use the GitHub Action or Taskfile for ARM hosts.
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      owner = "DimmKirr";
      repo = "setup-fm1-toolchain";

      sdkVersion = "1.2.14_2026-10-13";
      toolchainVersion = "20260730.1";

      sdk = pkgs.fetchurl {
        url = "https://github.com/${owner}/${repo}/releases/download/sdk-${sdkVersion}/sdk-${sdkVersion}.tar.xz";
        # Run vendor-sync, then: nix-prefetch-url --type sha256 <url>
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      toolchain = pkgs.fetchurl {
        url = "https://github.com/${owner}/${repo}/releases/download/toolchain-${toolchainVersion}/toolchain-${toolchainVersion}.tar.xz";
        # Run vendor-sync, then: nix-prefetch-url --type sha256 <url>
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      fm1-sdk = pkgs.stdenvNoCC.mkDerivation {
        pname = "fm1-sdk";
        version = sdkVersion;
        src = sdk;
        sourceRoot = ".";
        dontConfigure = true;
        dontBuild = true;
        unpackPhase = ''
          tar -xJf $src
        '';
        installPhase = ''
          mv sdk $out
        '';
      };

      fm1-toolchain = pkgs.stdenvNoCC.mkDerivation {
        pname = "fm1-toolchain";
        version = toolchainVersion;
        src = toolchain;
        sourceRoot = ".";
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ pkgs.stdenv.cc.cc.lib ];
        dontConfigure = true;
        dontBuild = true;
        unpackPhase = ''
          tar -xJf $src
        '';
        installPhase = ''
          mkdir -p $out
          cp -r toolchain/* $out/
        '';
      };

      fm1-env = pkgs.buildEnv {
        name = "fm1-dev-env";
        paths = [
          fm1-toolchain
          (pkgs.python3.withPackages (ps: [ ps.pillow ps.fonttools ps.mido ]))
        ];
      };

      devShell = pkgs.mkShell {
        packages = [
          fm1-env
          pkgs.gnumake
          pkgs.harfbuzz
          pkgs.fribidi
        ];
        shellHook = ''
          export JIELI_TOOLCHAIN="${fm1-toolchain}"
          export AC79_SDK="${fm1-sdk}"
          export PATH="${fm1-toolchain}/pi32v2/bin:$PATH"
        '';
      };

    in {
      packages.${system} = {
        inherit fm1-sdk fm1-toolchain;
        default = fm1-env;
      };

      devShells.${system}.default = devShell;
    };
}
