{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "wallpapers";
  version = "1.0";
  src = builtins.path {
    path = ./.;
    name = "wallpapers";
  };
  # Copy all wallpaper files into the output
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p "$out"
    # Copy all wallpapers from the source directory into the output
    cp -r ./* "$out/"
  '';
  meta = with pkgs.lib; {
    description = "Collection of wallpapers";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
