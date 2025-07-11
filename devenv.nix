{ pkgs, lib, config, ... }: {
  packages = with pkgs; [
    vscode
    vscode-extensions.myriad-dreamin.tinymist
    act
  ];

  languages = {
    typst.enable = true;
  };
}
