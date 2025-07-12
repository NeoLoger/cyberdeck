{ config, pkgs, ... }:

let
  rofi-power-menu = pkgs.writeShellScriptBin "rofi-power-menu" ''
    #! /usr/bin/env sh
    
    # Find full paths to binaries to ensure they run
    SYSTEMCTL_PATH=$(command -v systemctl)
    HYPRCTL_PATH=$(command -v hyprctl)
    SWAYLOCK_PATH=$(command -v swaylock)

    # Define the theme string for a small menu in the top-right.
    # This is the key to making it a "tooltip menu".
    THEME_STR="
      window {
        location: north east;
        anchor: north east;
        x-offset: -10px;
        y-offset: 40px; /* Adjust this to match your bar's height */
        width: 180px;
        border-radius: 8px;
        background-color: #1a1b26; /* Tokyo Night background */
      }
      mainbox {
        children: [ listview ];
      }
      listview {
        lines: 5;
        columns: 1;
        scrollbar: false;
        background-color: transparent;
      }
      element {
        padding: 8px;
        border-radius: 6px;
      }
      element-text {
        background-color: inherit;
        text-color: inherit;
      }
      element.normal.normal {
        background-color: #1a1b26; /* Tokyo Night background */
        text-color: #c0caf5; /* Tokyo Night foreground */
      }
      element.selected.normal {
        background-color: #7aa2f7; /* Tokyo Night blue for selection */
        text-color: #1a1b26;
      }
    "

    # Use printf for a reliable, multi-line string
    OPTIONS="Lock\nLogout\nSuspend\nReboot\nShutdown"

    # Run Rofi with the theme string
    SELECTED_OPTION=$(printf "$OPTIONS" | rofi -dmenu -i -p "Power" -theme-str "$THEME_STR")
    
    # Execute command based on selection
    case "$SELECTED_OPTION" in
      "Lock")
        exec $SWAYLOCK_PATH
        ;;
      "Logout")
        $HYPRCTL_PATH dispatch exit
        ;;
      "Suspend")
        $SYSTEMCTL_PATH suspend
        ;;
      "Reboot")
        $SYSTEMCTL_PATH reboot
        ;;
      "Shutdown")
        $SYSTEMCTL_PATH poweroff
        ;;
    esac
  '';
in 

{
  home.username = "neologer";
  home.homeDirectory = "/home/neologer";
  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    shellAliases = {
       btw = "echo I sue nixos with Home Manager btw!";
    };
    initExtra = ''
      export PS1='\[\e[38;5;31m\]\u\[\e[0m\] \[\e[38;5;50;1m\]in\[\e[0m\]\w \\$ '
    '';
  };

  home.packages = with pkgs; [
    networkmanager   # Provides nmcli for the network module
    upower           # Provides upower for the battery module
    dbus             # Provides dbus-update-activation-environment
    fastfetch
    bat
    rofi
    mesa             # Provides glxinfo
    pavucontrol      # GUI for volume control
    waybar           # The status bar
    rofi-power-menu  # My custome power menue
    swaylock
    ags              # Aylur's Gtk Shell (for bar, widgets, etc.)
    hyprcursor
    zsh
    oh-my-posh
    lsd
    obsidian
    gimp
    krita
    blender
    vlc
    imv
    amberol
    superfile
    #vesktop
  ];

  programs.neovim.enable = true;

  gtk = {
    enable = true;
    theme.name = "Tokyo-Night-Dark-B";
    iconTheme.name = "Papirus-Dark";
  };

  
  wayland.windowManager.hyprland = {
  enable = true;
  settings = {
    # Set the main modifier key
    "$mod" = "SUPER";

    # --- Initial Setup & Autostart ---
    # Execute something on launch
    exec-once = "waybar"; # Example: start a status bar

    # --- LAYOUT ENGINE CONTROL ---
    general = {
        # This is the key setting. Change from the default "dwindle" to "master".
        layout = "master";
        gaps_in = 2;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
    };

    # --- MASTER LAYOUT SPECIFIC SETTINGS ---
    master = {
	new_status = "inherit";
	# When you create a new window, the split is on the right side of the master
	new_on_top = false;
	# Size of the master area (0.5 means 50% of the screen)
	mfact = 0.55;
    };

    # --- Look and Feel ---
    decoration = {
      # Rounded corners
      rounding = 4;
    };

    animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
    };

    # --- Keybindings ---
    bind = [
      # Your requested bindings
      "$mod, RETURN, exec, kitty"   # Open terminal
      "$mod, Q, killactive,"        # Close active window
      "$mod, B, exec, brave"        # Open Brave

      # Popular suggestion: Application Launcher (Rofi)
      "$mod, D, exec, rofi -show drun" # 'drun' shows desktop applications

      # Window Management
      "$mod, F, fullscreen,"              # Toggle fullscreen
      "$mod, SPACE, togglefloating,"      # Toggle window between tiling/floating
      "$mod SHIFT, C, killactive,"        # Alternative close window binding
      "$mod, P, pseudo,"                  # Toggles pseudotiling on a window

      # Resize the current split
      "$mod, +, layoutmsg, splitratio, +0.05"
      "$mod, -, layoutmsg, splitratio, -0.05"

      # Toggle the next split direction manually if you want
      "$mod, J, layoutmsg, orientationnext"

      # Moving focus
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Moving windows
      "$mod SHIFT, left, movewindow, l"
      "$mod SHIFT, right, movewindow, r"
      "$mod SHIFT, up, movewindow, u"
      "$mod SHIFT, down, movewindow, d"

      # Workspace Management
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      # Move active window to a workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      # Scroll through existing workspaces
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"

      # Exit Hyprland session
      "$mod SHIFT, E, exit,"
    ];

    # Mouse bindings
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
 };

  programs.waybar = {
    enable = true;
     style = ''
      * {
          border: none;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 14px;
	  min-height: 0;
      }
      window#waybar {
          background-color: rgba(26, 27, 38, 0.8);
          color: #c0caf5;
      }
      #workspaces, #clock, #pulseaudio, #network, #battery, #custom-power {
          padding: 0 5px;
          margin: 0 3px;
      }
      #workspaces button.active {
          background-color: #7aa2f7;
          color: #1a1b26;
	  border-radius: 5px;
      }
      #pulseaudio:hover, #network:hover, #battery:hover, #custom-power:hover {
          background-color: #414868;
	  border-radius: 5px;
      }
      #battery.charging, #battery.plugged {
      color: #9ece6a; /* Green for charging */
      }
      #battery.critical:not(.charging) {
          color: #f7768e; /* Red for critical */
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }
      @keyframes blink {
          to {
              background-color: #f7768e;
              color: #1a1b26;
          }
      }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "battery" "pulseaudio" "custom/power" ]; # This reference is correct

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = { "default" = ""; };
        };
      
        "clock" = {
          format = "{:%H:%M }";
        };

        # --- NEW WIFI MODULE ---
        "network" = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname} ";
          format-disconnected = "Disconnected ";
          tooltip-format-wifi = "Signal: {signalStrength}% at {frequency}MHz\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}";
        };

        # --- NEW BATTERY MODULE ---
        "battery" = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;

          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% 󰂄";
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        };

        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-icons.default = ["" "" ""];
          "on-click" = "pavucontrol";
        };

        "custom/power" = {
          format = "";
          tooltip = false;
          "on-click" = "rofi-power-menu";
        };
      };
    };
  };
}
