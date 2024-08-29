{ pkgs, ... }:

{
  config = {
    # Packages useful at home
    home.packages = with pkgs; [
      yt-dlp
      neomutt
      weechat
      openai-whisper-cpp
      mpv
      hugo
    ];
  };
}

