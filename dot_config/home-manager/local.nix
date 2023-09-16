{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      yt-dlp
      neomutt
      weechat
      openai-whisper-cpp
      mpv
    ];
  };
}

