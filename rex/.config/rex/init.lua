-- Rex configuration, migrated from tmux, Herdr and WezTerm.

-- tmux (~/.config/tmux/tmux.conf), prefix ctrl+a
rex.bind("ctrl+a>r", "client.config.reload")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })

-- Send ctrl+a through to programs that use it themselves
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- Herdr (~/.config/herdr/config.toml), prefix ctrl+a
rex.bind("ctrl+a>,", "client.tab.rename")
rex.bind("ctrl+a>shift+7", "client.tab.close")

-- Herdr's resize mode
rex.mode("resize", { exclusive = true })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("ctrl+a>shift+r", "client.mode.enter", { name = "resize" })
rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
