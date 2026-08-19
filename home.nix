{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  opSshSign = if isDarwin
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else "/opt/1Password/op-ssh-sign";
  onePasswordAgent = if isDarwin
    then "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "$HOME/.1password/agent.sock";
  onePasswordIdentityAgent = if isDarwin
    then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else "~/.1password/agent.sock";
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCoSWtk4fb/3z5j7wvMt+A9kpCCWlaPm9Y9j64RlvYA";
  dockerConfig = builtins.toJSON {
    credsStore = if isDarwin then "osxkeychain" else "secretservice";
    credHelpers = {
      "asia.gcr.io" = "gcloud";
      "cgr.dev" = "cgr";
      "eu.gcr.io" = "gcloud";
      "gcr.io" = "gcloud";
      "marketplace.gcr.io" = "gcloud";
      "staging-k8s.gcr.io" = "gcloud";
      "us-east1-docker.pkg.dev" = "gcloud";
      "us.gcr.io" = "gcloud";
    };
  };
in {
  home = {
    username = "jan0ski";
    homeDirectory = if isDarwin then "/Users/jan0ski" else "/home/jan0ski";
    stateVersion = "25.11";

    packages = with pkgs; [
      _1password-cli
      ast-grep
      awscli2
      buf
      delta
      docker
      docker-credential-helpers
      fd
      gh
      git-lfs
      go
      golangci-lint
      google-cloud-sdk
      gopls
      gotools
      jq
      kubectl
      nodejs
      opentofu
      python3
      ripgrep
      rustup
      starpls
      terraform-ls
      tombi
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ ghostty ];

    sessionPath = [
      "$HOME/.amp/bin"
      "$HOME/.bun/bin"
      "$HOME/.cargo/bin"
      "$HOME/.krew/bin"
      "$HOME/.local/bin"
      "$HOME/go/bin"
    ] ++ lib.optionals isDarwin [
      "$HOME/Library/pnpm"
      "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ "$HOME/.local/share/pnpm" ];

    sessionVariables = {
      EDITOR = "hx";
      ENABLE_LSP_TOOL = "1";
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    };

    file = {
      ".actrc".source = ./actrc;
      ".config/amp/settings.json".source = ./amp/settings.json;
      ".config/AGENTS.md".source = ./agents/AGENTS.md;
      ".config/git/ignore".source = ./git/ignore;
      ".config/ghostty/config".source = ./ghostty/config;
      ".config/nono/profiles/custom-claude-code.json".source = ./nono/profiles/custom-claude-code.json;
      ".agents/.skill-lock.json".source = ./agents/skill-lock.json;
      ".claude/CLAUDE.md".source = ./agents/AGENTS.md;
      ".claude/settings.json".source = ./claude/settings.json;
      ".claude/skills/codebase-security-audit".source = ./claude/skills/codebase-security-audit;
      ".claude/statusline-command.sh" = {
        source = ./claude/statusline-command.sh;
        executable = true;
      };
    };
  };

  home.activation.configureDocker = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    docker_dir="${config.home.homeDirectory}/.docker"
    docker_config="$docker_dir/config.json"

    if [ -z "$DRY_RUN_CMD" ]; then
      ${pkgs.coreutils}/bin/mkdir -p "$docker_dir"
      ${pkgs.coreutils}/bin/chmod 700 "$docker_dir"

      if [ ! -e "$docker_config" ]; then
        ${pkgs.coreutils}/bin/printf '{}\n' > "$docker_config"
      fi

      if [ -L "$docker_config" ]; then
        echo "Refusing to replace symlinked Docker configuration: $docker_config" >&2
        exit 1
      fi

      docker_tmp=$(${pkgs.coreutils}/bin/mktemp "$docker_dir/config.json.XXXXXX")
      ${pkgs.jq}/bin/jq --argjson managed '${dockerConfig}' \
        '. * $managed | .credHelpers = ((.credHelpers // {}) + $managed.credHelpers)' \
        "$docker_config" > "$docker_tmp"
      ${pkgs.coreutils}/bin/chmod 600 "$docker_tmp"
      ${pkgs.coreutils}/bin/mv "$docker_tmp" "$docker_config"
    else
      echo "Would update Docker credential helpers in $docker_config"
    fi
  '';

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Tommy McCormick";
        email = "mccormickt9@gmail.com";
        signingKey = signingKey;
      };
      url."git@github.com:".insteadOf = "https://github.com/";
      core = {
        autocrlf = "input";
        editor = "hx";
        pager = "cat";
      };
      init.defaultBranch = "main";
      commit.gpgSign = true;
      gpg = {
        format = "ssh";
        ssh.program = opSshSign;
      };
      push.autoSetupRemote = true;
      pull.rebase = true;
      color.ui = "auto";
      pager.log = "more";
      credential = {
        "https://github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
        "https://gist.github.com".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      };
    };
    includes = [
      {
        condition = "gitdir:~/adversarial/";
        path = "~/adversarial/.gitconfig";
      }
      { path = "~/.gitconfig-local"; }
    ];
  };
  home.file.".gitconfig".text = config.xdg.configFile."git/config".text;

  programs.gh = {
    enable = true;
    settings = {
      aliases.co = "pr checkout";
      git_protocol = "ssh";
      pager = "cat";
      prompt = "enabled";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Tommy McCormick";
        email = "mccormickt9@gmail.com";
      };
      signing = {
        behavior = "drop";
        backend = "ssh";
        key = signingKey;
        backends.ssh.program = opSshSign;
      };
      ui = {
        editor = "hx";
        default-command = "log";
      };
      git.sign-on-push = true;
      remotes.origin.auto-track-bookmarks = "glob:*";
      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "closest_pushable(to)" = "heads(::to & ~description(exact:\"\") & (~empty() | merges()))";
      };
      aliases = {
        tug = [ "bookmark" "move" "--from" "closest_bookmark(@)" "--to" "closest_pushable(@)" ];
        spr = [ "util" "exec" "--" "jj-spr" ];
      };
      "--scope" = [
        {
          "--when".repositories = [ "~/adversarial" ];
          user.email = "tommy@adversarial.com";
        }
        {
          "--when".commands = [ "status" ];
          ui.paginate = "never";
        }
        {
          "--when".commands = [ "diff" "show" ];
          ui.pager = "delta";
        }
      ];
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        auto-format = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
        };
        file-picker.hidden = false;
        lsp.display-inlay-hints = true;
      };
    };
    languages = {
      language-server = {
        rust-analyzer.config = {
          inlayHints = {
            maxLength = 24;
            bindingModeHints.enable = true;
            discriminantHints.enable = "fieldless";
            lifetimeElisionHints = {
              enable = "skip_trivial";
              useParameterNames = true;
            };
            closureReturnTypeHints.enable = "always";
          };
          check = {
            command = "clippy";
            workspace = true;
          };
        };
        terraform-ls.config = {
          terraform.path = "${pkgs.opentofu}/bin/tofu";
          experimentalFeatures.prefillRequiredFields = true;
        };
        gopls.config = {
          "formatting.gofumpt" = true;
          hints = {
            assignVariableTypes = true;
            compositeLiteralFields = true;
            constantValues = true;
            functionTypeParameters = true;
            parameterNames = true;
            rangeVariableTypes = true;
          };
        };
        starpls = {
          command = "starpls";
          args = [ "server" ];
        };
      };
      language = [
        { name = "hcl"; formatter = { command = "tofu"; args = [ "fmt" "-" ]; }; }
        { name = "toml"; auto-format = true; language-servers = [ "tombi" ]; }
        { name = "bash"; auto-format = true; }
        { name = "typescript"; auto-format = true; }
        { name = "tsx"; auto-format = true; }
        { name = "jsx"; auto-format = true; }
        { name = "javascript"; auto-format = true; }
        { name = "svelte"; auto-format = true; }
        { name = "python"; auto-format = true; }
        {
          name = "protobuf";
          auto-format = true;
          formatter = { command = "buf"; args = [ "format" "-" ]; };
        }
        {
          name = "starlark";
          language-servers = [ "starpls" ];
          file-types = [
            "bzl" "bazel" "star"
            { glob = "BUILD"; }
            { glob = "BUILD.*"; }
            { glob = "BUCK"; }
            { glob = "Tiltfile"; }
            { glob = "WORKSPACE"; }
          ];
        }
      ];
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = true;
        IdentityAgent = onePasswordIdentityAgent;
      };
      aphrodite = { HostName = "aphrodite.jan0ski.net"; User = "root"; Port = 22; };
      plex = { HostName = "plex.jan0ski.net"; User = "root"; Port = 22; };
      freenas = { HostName = "freenas.jan0ski.net"; User = "root"; Port = 22; };
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = "set -g @catppuccin_flavor 'mocha'";
      }
    ];
    extraConfig = ''
      bind-key C-a send-prefix
      bind-key h split-window -c "#{pane_current_path}"
      bind-key v split-window -h -c "#{pane_current_path}"
      bind-key j split-window -c "#{pane_current_path}"
      bind-key k split-window -h -c "#{pane_current_path}"
      bind-key c new-window -c "#{pane_current_path}"
      bind-key m set mouse off
      set-option -g renumber-windows on
      set-option -g automatic-rename on
      set-option -g set-titles on
      set-option -g focus-events on
      set-option -g default-terminal "xterm-256color"
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = false;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;
    plugins = with pkgs.vimPlugins; [
      vim-pandoc vim-pandoc-syntax vim-markdown jedi-vim rustaceanvim
      latex-box neomake vim-go vim-hcl vim-terraform fastfold vim-fugitive
      vim-sleuth vim-sensible vim-surround vim-repeat tabular nerdtree
      nerdtree-git-plugin ale vim-solarized8 onedark-vim
    ];
    extraConfig = builtins.readFile ./nvim/init.vim;
  };
  xdg.configFile."nvim/after/ftplugin/rust.lua".source = ./nvim/after/ftplugin/rust.lua;

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-pandoc vim-pandoc-syntax vim-markdown jedi-vim rust-vim latex-box
      neomake vim-go vim-hcl vim-terraform fastfold vim-fugitive vim-sleuth
      vim-sensible vim-surround vim-repeat tabular nerdtree nerdtree-git-plugin
      ale vim-solarized8 onedark-vim
    ];
    extraConfig = builtins.readFile ./vimrc;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "gallifrey";
      plugins = [ "git" "aws" "kubectl" "direnv" ];
    };
    shellAliases = {
      ".." = "cd ..";
      c = "clear";
      k = "kubectl";
      python = "python3";
      terraform = "tofu";
      vim = "nvim";
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux { ls = "ls -F"; };
    initContent = ''
      if [[ -z "$SSH_TTY" && -S "${onePasswordAgent}" ]]; then
        export SSH_AUTH_SOCK="${onePasswordAgent}"
      fi
    '' + builtins.readFile ./zshrc;
  };
}
