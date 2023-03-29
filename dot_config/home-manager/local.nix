{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      yt-dlp
      youtube-dl
      neomutt
      weechat
      topgrade
    ];
  };
}

