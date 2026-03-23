local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_frame = {
  font_size = 11.0,
}

config.color_scheme = 'OneHalfDark'

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

config.default_prog = { 
  [[C:\WINDOWS\system32\wsl.exe]],
  "--distribution-id", "{d8505407-7664-4768-b9a3-5781fee81454}"
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
}

return config

