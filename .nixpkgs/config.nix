with import <nixpkgs> {};
let
  vim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig.customRC = ''
      if filereadable($HOME . "/.vimrc")
        source ~/.vimrc
      endif
    '';
    vimrcConfig.packages.nixbundle = with pkgs.vimPlugins; {
      # loaded on launch
      start = [
        youcompleteme
        #deoplete-nvim
        #deoplete-jedi
        #clang_complete
        vim-trailing-whitespace
        nerdtree-git-plugin
        syntastic
        gitgutter
        airline
        nerdtree
        colors-solarized
        ack-vim
        vim-go
        vim-scala
        vim-polyglot
        syntastic
        # delimitMate
        editorconfig-vim
        ctrlp
        rust-vim
      ];
    };
  };

  latexApps = [
    rubber
    (texlive.combine {
      inherit (texlive)
      scheme-basic

      # awesome cv
      xetex
      xetex-def
      unicode-math
      ucharcat
      collection-fontsextra
      fontspec

      collection-binextra
      collection-fontsrecommended
      collection-genericrecommended
      collection-latex
      collection-latexextra
      collection-latexrecommended
      collection-science
      collection-langgerman
      IEEEtran;
    })
  ];

  rubyApps = [ bundler bundix rubocop ];

  desktopApps = [
    dino
    libreoffice
    dropbox
    #android-studio
    gimp
    inkscape
    mpd
    mpv
    firefox
    chromium
    thunderbird
    transmission_gtk
    rxvt_unicode-with-plugins
    aspell
    aspellDicts.de
    aspellDicts.fr
    aspellDicts.en
    hunspell
    hunspellDicts.en-gb-ise
    scrot
    (gajim.overrideDerivation (old: {
      patches = (old.patches or []) ++ [
        ./0001-remove-outer-paragraph.patch
      ];
    }))
    arandr
    lxappearance
    xorg.xev
    xorg.xprop
    xclip
    copyq
    xautolock
    i3lock
    zeroad
    keepassx-community
    pavucontrol
    evince
    pcmanfm
    gpodder
    valauncher
    youtube-dl
    ncmpcpp
    xclip
    screen-message
    scrot
    alacritty
  ] ++ (with gnome3; [
    gvfs
    eog
    gedit
    gnome_themes_standard
    adwaita-icon-theme
  ]);

  nixDevApps = [
    nix-prefetch-scripts
    pypi2nix
    go2nix
    mercurial # go2nix
    bundix
    nox
    nix-repl
    nix-review
  ];

  debuggingBasicsApps = [
    gdb
    strace
  ];
  debuggingApps = [ binutils gperftools valgrind ];

  userPackages = name: paths: buildEnv {
    inherit ((import <nixpkgs/nixos> {}).config.system.path)
      pathsToLink ignoreCollisions postBuild;
    extraOutputsToInstall = [ "man" "debug" ];
    inherit paths name;
  };
in {
  allowUnfree = true;
  pulseaudio = true;
  chromium = {
    enablePepperFlash = true;
    enablePepperPDF = true;
  };
  packageOverrides = pkgs: with pkgs; {
    all = userPackages "all" ([]
      #++ desktopApps
      #++ latexApps
      #++ rubyApps
      #++ rustApps
      #++ pythonDataLibs
      ++ debuggingApps
      ++ debuggingBasicsApps
      ++ nixDevApps
      ++ [
        vim
        gitAndTools.diff-so-fancy
        gitAndTools.hub
        gitAndTools.git-octopus
        gitAndTools.git-crypt
        gitFull
        tig
        sshfsFuse
        sshuttle
        jq
        httpie
        cloc
        mosh
        cheat
        graphicsmagick
        gnupg1compat
        direnv
        ghostscript
        tree
        fzf
        exa
        bench
      ]);

    staging = buildEnv {
      name = "staging";
      paths = [
      ];
    };

    rustApps = [
      rustc
      cargo
      rustfmt
      rustracer
      (pkgs.writeScriptBin "rust-doc" ''
         #! ${pkgs.stdenv.shell} -e
         browser="$BROWSER"
         if [ -z "$browser" ]; then
           browser="$(type -P xdg-open || true)"
           if [ -z "$browser" ]; then
             browser="$(type -P w3m || true)"
             if [ -z "$browser" ]; then
               echo "$0: unable to start a web browser; please set \$BROWSER"
               exit 1
             fi
           fi
         fi
         exec "$browser" "${rustc.doc}/share/doc/rust/html/index.html"
      '')
    ];

    pythonDataLibs = with python3Packages; [
      ipython
      numpy
      scipy
      matplotlib
      pandas
      seaborn
    ];
  };
}
