{ pkgs, lib, config, ... }: {

  options = {
    personal.enable = lib.mkEnableOption "packages that are only useful on home computers";
  };

  config = lib.mkIf config.personal.enable {
    home.packages = with pkgs; [
      hugo
      mpv
      neomutt
      openai-whisper-cpp
      weechat
      yt-dlp
    ];
  };
}

