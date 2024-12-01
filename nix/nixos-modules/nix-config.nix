{ ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
    ];
    trusted-users = [ "@wheel" ];
  };
  programs.nh = {
    enable = true;
    flake = "/home/bc/.local/share/chezmoi";
  };
  # Needed for lua_ls in nvim etc
  programs.nix-ld.enable = true;
}
