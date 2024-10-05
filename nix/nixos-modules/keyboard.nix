{ ... }:
{
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;
}
