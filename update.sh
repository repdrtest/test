#cat << 'EOF' > ~/dotfiles/update.sh
#!/usr/bin/env bash
# ~/dotfiles/update.sh
# Instant updater for SNOW Dotfiles - Updates Hyprland Lua, Quickshell & fixes any errors

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Starting SNOW Dotfiles Quick Update..."

R="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Update Hyprland Lua & colors
mkdir -p "$HOME/.config/hypr"

cat << 'LUA' > "$HOME/.config/hypr/hyprland.lua"
-- ~/.config/hypr/hyprland.lua
-- SNOW Hyprland Native Lua Configuration

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true
        },
        sensitivity = 0
    },
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        layout = "dwindle"
    },
    decoration = {
        rounding = 14,
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true,
            xray = true
        },
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3
        }
    },
    animations = {
        enabled = true
    }
})

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell -p ~/.config/quickshell/snow")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("dunst")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
end)

local mainMod = "SUPER"

-- Core Window Management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({}))
hl.bind(mainMod .. " + V", hl.dsp.window.float({}))
hl.bind(mainMod .. " + M", hl.dsp.exit())

-- Quickshell Pop-Up Menus
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/snow -d launcher"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/snow -d quicksettings"))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/snow -d apps"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/snow -d power"))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/snow -d clock"))

-- Applications & Terminal
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("zen-browser-bin"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))

-- Screenshots
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("bash ~/.config/snow/bin/screenshot.sh area"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("bash ~/.config/snow/bin/screenshot.sh screen"))

-- Focus Navigation
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Volume & Brightness Keys (OSD triggers)
hl.bind(", XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && quickshell -p ~/.config/quickshell/snow -d volume"))
hl.bind(", XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && quickshell -p ~/.config/quickshell/snow -d volume"))
hl.bind(", XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && quickshell -p ~/.config/quickshell/snow -d volume"))
hl.bind(", XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+ && quickshell -p ~/.config/quickshell/snow -d brightness"))
hl.bind(", XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%- && quickshell -p ~/.config/quickshell/snow -d brightness"))
LUA
echo -e "${GREEN}✓${NC} Deployed updated hyprland.lua"

# 2. Backup & remove deprecated hyprland.conf
if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
    mv "$HOME/.config/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf.bak.$(date +%s)" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Cleaned up deprecated hyprland.conf"
fi

# 3. Live reload Hyprland
echo -e "${BLUE}==>${NC} Reloading Hyprland..."
if command -v hyprctl &>/dev/null; then
    hyprctl reload || true
    echo -e "${GREEN}✓${NC} Hyprland reloaded successfully!"
fi

echo
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}  SNOW Dotfiles Updated Successfully!         ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "Your keybindings are now active:"
echo -e "  • ${YELLOW}SUPER + SPACE${NC}  -> App Launcher"
echo -e "  • ${YELLOW}SUPER + A${NC}      -> QuickSettings"
echo -e "  • ${YELLOW}SUPER + T${NC}      -> Kitty Terminal"
echo -e "  • ${YELLOW}SUPER + Q${NC}      -> Close Window"
echo -e "  • ${YELLOW}SUPER + 1..9${NC}   -> Switch Workspaces"
echo
EOF

bash ~/dotfiles/update.sh
