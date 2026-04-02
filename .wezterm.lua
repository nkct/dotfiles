local wezterm = require 'wezterm'
local config = wezterm.config_builder()

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 
    [[C:\WINDOWS\system32\wsl.exe]],
    "--cd", "~"
  }
end

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_frame = {
  font_size = 11.0,
}
config.font = wezterm.font 'Noto Sans Mono'
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = 'NeverPrompt'
config.audible_bell = 'Disabled'
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.initial_cols = 104
config.initial_rows = 21
config.enable_scroll_bar = true
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.show_tab_index_in_tab_bar = false

config.color_scheme = 'OneHalfDark'

config.launch_menu = {
  {
    args = { 'top' },
  },
}

config.tab_max_width = 20
config.use_fancy_tab_bar = true
wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local color = 'transparent'
    if tab.is_active then
      color = '#282c34'
    end

    local title = tab.active_pane.title:match("([^:]+)")

    return {
      { Background = { Color = color } },
      { Text = title },
    }
  end
)

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.Nop,
  },
  -- Disable default click without CTRL
  {
    event = { Down = { streak = 1, button = 'Left' } },
    action = wezterm.action.SelectTextAtMouseCursor("Cell"),
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    action = wezterm.action.Nop,
  },
}

config.keys = {
  {
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.CloseCurrentTab { confirm = false },
  },
  {
    key = 't',
    mods = 'CTRL',
    action = wezterm.action.SpawnTab 'DefaultDomain',
  },
  {
    key = 't',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ShowLauncher,
  },
  {
    key = 'n',
    mods = 'CTRL',
    action = wezterm.action.SpawnWindow,
  },
}

return config
