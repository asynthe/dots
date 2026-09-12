{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cmake ninja pkg-config qt6.wrapQtAppsHook
  ];
  buildInputs = with pkgs; [
    qt6.qtbase qt6.qtdeclarative qt6.qt5compat
    qt6.qtwayland qt6.qtconnectivity qt6.qtsvg
    libGL wayland vulkan-loader
  ];
  shellHook = ''
    export TIDE_QT5COMPAT_QML=${pkgs.qt6.qt5compat}/lib/qt-6/qml
  '';
}
