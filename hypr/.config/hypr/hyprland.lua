-- Hyprland config (Lua, requires Hyprland >= 0.55)
-- Migrated from hyprland.conf

----------------
---- MONITORS ----
----------------

hl.monitor({ output = "DP-4",  mode = "3840x2160@120", position = "auto", scale = 1.5 })
hl.monitor({ output = "eDP-1", mode = "preferred",     position = "auto", scale = 1.5 })
hl.monitor({ output = "",      mode = "preferred",     position = "auto", scale = 1 })


------------------
---- CLAMSHELL ----
------------------

hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/clamshell_mode.sh open"),  { locked = true })
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd("~/.config/hypr/clamshell_mode.sh close"), { locked = true })

hl.on("monitor.added",   function(_) hl.exec_cmd("~/.config/hypr/clamshell_mode.sh rescan")  end)
hl.on("monitor.removed", function(_) hl.exec_cmd("~/.config/hypr/clamshell_mode.sh removed") end)


----------------
---- AUTOSTART ----
----------------

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/clamshell_mode.sh fallback")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("hyprctl setcursor breeze_cursors 24")
end)


-------------------------
---- ENV VARIABLES ----
-------------------------

hl.env("XCURSOR_SIZE",              "24")
hl.env("HYPRCURSOR_SIZE",           "24")
hl.env("XCURSOR_THEME",             "breeze_cursors")
hl.env("LIBVA_DRIVER_NAME",         "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("GDK_SCALE",                 "2")


----------------
---- LOOK & FEEL ----
----------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = "rgb(282828)",
            inactive_border = "rgb(171717)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    binds = {
        drag_threshold = 10,
    },

    decoration = {
        rounding       = 0,
        rounding_power = 0,
        blur = {
            enabled           = true,
            size              = 1,
            passes            = 4,
            vibrancy          = 0.1696,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = false,
    },

    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    input = {
        kb_layout    = "dk",
        kb_options   = "caps:swapescape",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
    },
})


----------------
---- KEYBINDS ----
----------------

local mainMod = "SUPER"

-- Terminal / launchers
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd([[rofi -show drun -theme-str 'entry { placeholder: "Search..."; }']]))
hl.bind(mainMod .. " + C",      hl.dsp.exec_cmd([[rofi -show calc -theme-str 'entry { placeholder: "Insert expression"; }']]))

-- Browser, clipboard, lock
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("zen"))
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd([[cliphist list | rofi -dmenu -theme-str 'entry { placeholder: "Select clipboard history element to copy"; }' | cliphist decode | wl-copy]]))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("hyprlock"))

-- Window mgmt
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + t", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Resize active
hl.bind(mainMod .. " + u", hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
hl.bind(mainMod .. " + p", hl.dsp.window.resize({ x = 40,  y = 0, relative = true }))
hl.bind(mainMod .. " + o", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }))
hl.bind(mainMod .. " + i", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }))

-- Swap
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "down" }))

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

-- Mouse drag/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshot
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

-- Keyboard backlight
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set +33%"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 33%-"), { locked = true, repeating = true })

-- Screen brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Volume & media
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),         { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Move current workspace between monitors
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.workspace.move({ monitor = "-1" }))


--------------------
---- WINDOW RULES ----
--------------------

-- Citrix: suppress XWayland ghost windows (Start menu / Search bar)
hl.window_rule({ match = { class = "^(Start)$" }, workspace = "special:citrix_junk silent" })
hl.window_rule({ match = { class = "^(Søg)$" },   workspace = "special:citrix_junk silent" })
