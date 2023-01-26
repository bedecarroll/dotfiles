{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      youtube-dl
      neomutt
      weechat
    ];
  };
}


