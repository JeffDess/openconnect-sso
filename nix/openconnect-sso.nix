{ lib, stdenv, openconnect, python3, python3Packages, poetry2nix, qt5
, wrapQtAppsHook }:

poetry2nix.mkPoetryApplication {
  projectDir = ../.;
  python = python3;
  checkGroups = [ ];
  buildInputs = [ python3Packages.setuptools ];
  nativeBuildInputs = [ wrapQtAppsHook ];

  propagatedBuildInputs = [ openconnect ]
    ++ lib.optional (stdenv.isLinux) qt5.qtwayland;

  dontWrapQtApps = true;
  preFixup = ''
    makeWrapperArgs+=(
      # Force the app to use QT_PLUGIN_PATH values from wrapper
      --unset QT_PLUGIN_PATH
      "''${qtWrapperArgs[@]}"
      # avoid persistant warning on starup
      --set QT_STYLE_OVERRIDE Fusion
    )
  '';

  overrides = [
    poetry2nix.defaultPoetryOverrides
    (self: super: {
      inherit (python3Packages)
        attrs colorama cryptography keyring lxml more-itertools prompt-toolkit
        pyotp pyqt5 pyqt5-sip pyqtwebengine pysocks pyxdg requests
        structlog toml six;

      coverage-enable-subprocess =
        super.coverage-enable-subprocess.overridePythonAttrs (old: {
          propagatedBuildInputs = (old.propagatedBuildInputs or [ ])
            ++ [ self.setuptools ];
        });
    })
  ];
}
