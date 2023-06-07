{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      yt-dlp
      neomutt
      weechat
      topgrade
      openai-whisper-cpp
      ffmpeg
      mpv
    ];
  };
}

