---
# Wezterm project switcher in Lua

**Created:** 3/8/2026, 10:16:52 PM
**Updated:** 3/8/2026, 10:47:27 PM

---

## User

You are a senior software engineer. You are a Lua expert and write clean code. 

I want to be able to switch between projects instantly. I also want to have persistent project sessions (ex: running DB or backend). I don't have use case for SSH multiplexing.

I'm using Wezterm as a terminal. See my config: @wezterm/.wezterm.lua. 
Rewrite tmux-sessionizer script (from ThePrimeagen) in Lua with native Wezterm multiplexing capabilities.

---

# 🚀 Wezterm Project Switcher - Implementation Plan

## Executive Summary

A native Wezterm-based project switcher replacing tmux-sessionizer functionality. Uses Wezterm workspaces for session persistence, Lua for configuration, and supports complex nested pane layouts with per-project startup commands.

---

## Architecture Overview

### File Structure
```
dotfiles/
└── wezterm/
    ├── .wezterm.lua                          # Main config (updated)
    └── .config/wezterm/
        ├── project-scanner.lua               # Scans for git repos/worktrees
        ├── workspace-manager.lua             # Creates/manages workspaces
        ├── project-config.lua                # Loads .wezterm-project.lua
        └── pane-builder.lua                  # Builds nested pane layouts
```

### Component Responsibilities

#### 1. **project-scanner.lua**
**Purpose:** Find all git repositories and worktrees

**API:**
```lua
local scanner = require("project-scanner")

-- Returns: { { path = "/full/path", name = "project1", icon = "📁" }, ... }
local projects = scanner.scan_projects({
  search_paths = { 
    wezterm.home_dir .. "/workspace",
    wezterm.home_dir .. "/dotfiles"  -- Special case
  },
  max_depth = 2
})
```

**Algorithm:**
1. Use `fd` to find `.git` directories/files in search paths
2. For `.git` directory → regular repo
3. For `.git` file → git worktree (read parent from file)
4. Load `.wezterm-project.lua` if exists to get custom icon
5. Return list with formatted names:
   - Regular: `"project-name"` → workspace: `project-name`
   - Worktree: `"parent/worktree-name"` → workspace: `parent/worktree-name`
   - Dotfiles: `"dotfiles"` → workspace: `dotfiles`

**Git Worktree Detection:**
```lua
-- Check if .git is a file (worktree) or directory (regular repo)
local git_path = path .. "/.git"
local f = io.open(git_path, "r")
if f then
  local first_line = f:read("*line")
  f:close()
  if first_line:match("^gitdir:") then
    -- It's a worktree, extract parent directory name
    -- Format: parent-name/worktree-name
  end
end
```

---

#### 2. **project-config.lua**
**Purpose:** Load and validate `.wezterm-project.lua` files

**API:**
```lua
local config_loader = require("project-config")

-- Returns config table or default config
local config = config_loader.load(project_path)
```

**Fallback Logic:**
1. Check `<project_path>/.wezterm-project.lua`
2. If worktree and not found, check parent directory
3. If still not found, return default config:
```lua
{
  icon = "📁",
  layout = {
    { label = "editor", cwd = ".", command = "nvim ." }
  }
}
```

**Config Schema Validation:**
```lua
-- Valid config structure
return {
  icon = "🚀",  -- Optional, defaults to 📁
  layout = {
    -- Option 1: Simple pane
    { label = "editor", cwd = ".", command = "nvim ." },
    
    -- Option 2: Container with direction
    {
      direction = "vertical",  -- or "horizontal"
      panes = {
        { label = "left", cwd = ".", command = "nvim .", size = 0.6 },
        {
          direction = "horizontal",
          panes = {
            { label = "top-right", command = "npm run dev" },
            { label = "bottom-right", command = "docker-compose up" }
          }
        }
      }
    }
  }
}
```

---

#### 3. **pane-builder.lua**
**Purpose:** Recursively build nested pane layouts

**API:**
```lua
local builder = require("pane-builder")

-- Build layout in current window
builder.build_layout(window, pane, layout_config, project_path)
```

**Algorithm:**
```lua
function build_layout(window, parent_pane, layout, base_path)
  if layout.direction then
    -- Container node: split recursively
    for i, child in ipairs(layout.panes) do
      if i == 1 then
        -- Use parent pane for first child
        build_layout(window, parent_pane, child, base_path)
      else
        -- Split to create new pane
        local direction = layout.direction == "vertical" and "Right" or "Bottom"
        local new_pane = parent_pane:split({
          direction = direction,
          size = child.size or (1.0 / (#layout.panes - i + 1))
        })
        build_layout(window, new_pane, child, base_path)
      end
    end
  else
    -- Leaf node: execute command
    local cwd = resolve_path(base_path, layout.cwd or ".")
    parent_pane:send_text(string.format("cd %s && %s\n", cwd, layout.command))
  end
end
```

**Size Calculation:**
If `size` not specified, split remaining space equally among siblings.

---

#### 4. **workspace-manager.lua**
**Purpose:** Manage workspace lifecycle

**API:**
```lua
local manager = require("workspace-manager")

-- Switch to or create workspace
manager.switch_to_project(project_path, project_name, config)
```

**Workflow:**
```lua
function switch_to_project(path, name, config)
  -- 1. Check if workspace already exists
  local workspaces = get_active_workspaces()
  if workspaces[name] then
    -- Switch to existing workspace
    activate_workspace(name)
    return
  end
  
  -- 2. Create new workspace
  local window = spawn_new_window({
    workspace = name,
    cwd = path
  })
  
  -- 3. Set workspace title to show in UI
  window:set_title(config.icon .. " " .. name)
  
  -- 4. Build pane layout
  local root_pane = window:active_pane()
  pane_builder.build_layout(window, root_pane, config.layout, path)
end

function get_active_workspaces()
  -- Parse output of: wezterm cli list --format json
  -- Extract unique workspace names
end
```

---

#### 5. **Updated .wezterm.lua**
**Purpose:** Wire everything together with keybinding

**Key Changes:**
```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Import modules
local scanner = require("project-scanner")
local workspace_manager = require("workspace-manager")
local config_loader = require("project-config")

-- Existing config...
config.font = wezterm.font("MesloLGS Nerd Font Mono")
-- ... etc ...

-- Enable tab bar to show workspace name
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Show workspace name in tab bar
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local workspace = tab.active_pane.workspace
  local icon = "📁"  -- TODO: Get from project config cache
  return {
    { Text = " " .. icon .. " " .. workspace .. " " }
  }
end)

-- Project switcher keybinding
config.keys = {
  {
    key = "f",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      -- Scan for projects
      local projects = scanner.scan_projects({
        search_paths = {
          wezterm.home_dir .. "/workspace",
          wezterm.home_dir .. "/dotfiles"
        },
        max_depth = 2
      })
      
      -- Build launcher menu choices
      local choices = {}
      for _, proj in ipairs(projects) do
        table.insert(choices, {
          id = proj.path,
          label = proj.icon .. " " .. proj.name
        })
      end
      
      -- Show launcher menu
      window:perform_action(
        wezterm.action.InputSelector({
          title = "Switch to Project",
          choices = choices,
          fuzzy = true,
          action = wezterm.action_callback(function(window, pane, id, label)
            if not id then return end  -- User cancelled
            
            -- Find selected project
            local selected = nil
            for _, proj in ipairs(projects) do
              if proj.path == id then
                selected = proj
                break
              end
            end
            
            -- Load project config
            local proj_config = config_loader.load(selected.path)
            
            -- Switch/create workspace
            workspace_manager.switch_to_project(
              selected.path,
              selected.name,
              proj_config
            )
          end)
        }),
        pane
      )
    end)
  }
}

return config
```

---

## Per-Project Configuration

### Example Configs

#### Simple Single Pane (Default)
```lua
-- ~/dotfiles/.wezterm-project.lua
return {
  icon = "🔧",
  layout = {
    { label = "editor", cwd = ".", command = "nvim ." }
  }
}
```

#### Vertical Split (Editor + Server)
```lua
-- ~/workspace/my-webapp/.wezterm-project.lua
return {
  icon = "⚛️",
  layout = {
    direction = "vertical",
    panes = {
      { label = "editor", cwd = ".", command = "nvim .", size = 0.6 },
      { label = "dev-server", cwd = ".", command = "npm run dev", size = 0.4 }
    }
  }
}
```

#### Complex Nested Layout
```lua
-- ~/workspace/fullstack-app/.wezterm-project.lua
return {
  icon = "🔥",
  layout = {
    direction = "vertical",
    panes = {
      -- Left: Editor (60%)
      { label = "editor", cwd = ".", command = "nvim .", size = 0.6 },
      
      -- Right: Split horizontally (40%)
      {
        direction = "horizontal",
        size = 0.4,
        panes = {
          { label = "backend", cwd = "./backend", command = "npm run start:dev" },
          { label = "frontend", cwd = "./frontend", command = "npm run dev" },
          { label = "database", cwd = ".", command = "docker-compose up postgres" }
        }
      }
    }
  }
}
```

**Visual Result:**
```
┌─────────────┬─────────────┐
│             │  backend    │
│             ├─────────────┤
│   Editor    │  frontend   │
│   (60%)     ├─────────────┤
│             │  database   │
│             │             │
└─────────────┴─────────────┘
```

#### Worktree Example
```lua
-- ~/workspace/myproject-worktrees/.wezterm-project.lua
-- Shared by all worktrees (feature-a, feature-b, etc.)
return {
  icon = "🌿",
  layout = {
    direction = "vertical",
    panes = {
      { label = "editor", command = "nvim .", size = 0.7 },
      { label = "shell", command = "zsh", size = 0.3 }
    }
  }
}
```

---

## Implementation Steps

### Phase 1: Core Infrastructure
1. **Create directory structure**
   ```bash
   mkdir -p ~/dotfiles/wezterm/.config/wezterm
   ```

2. **Implement project-scanner.lua**
   - `scan_projects()` function
   - Git repo detection with `fd`
   - Worktree detection logic
   - Name formatting (parent/worktree-name)

3. **Implement project-config.lua**
   - `load()` function with fallback chain
   - Config validation
   - Default config generation

4. **Test scanner independently**
   ```bash
   wezterm -e lua ~/dotfiles/wezterm/.config/wezterm/project-scanner.lua
   ```

### Phase 2: Workspace Management
5. **Implement workspace-manager.lua**
   - `get_active_workspaces()` using `wezterm cli list`
   - `switch_to_project()` function
   - Workspace creation with `wezterm cli spawn`

6. **Test workspace switching manually**
   ```bash
   wezterm cli spawn --new-window --workspace test --cwd ~/dotfiles
   wezterm cli rename-workspace default test2
   ```

### Phase 3: Pane Layout Builder
7. **Implement pane-builder.lua**
   - Recursive `build_layout()` function
   - Size calculation logic
   - Command execution via `pane:send_text()`

8. **Test with simple layouts first**
   - Single pane
   - Two vertical panes
   - Two horizontal panes
   - Then test nested layouts

### Phase 4: Integration
9. **Update .wezterm.lua**
   - Add module requires
   - Add CTRL+F keybinding
   - Wire up InputSelector
   - Add workspace title formatting

10. **Test end-to-end flow**
    - Press CTRL+F
    - Select project
    - Verify workspace created
    - Verify panes created
    - Verify commands executed

### Phase 5: Polish
11. **Add error handling**
    - Invalid config files
    - Missing projects
    - Failed command execution

12. **Add config caching**
    - Cache scanned projects for 30s
    - Avoid repeated `fd` calls

13. **Create example configs**
    - Add `.wezterm-project.lua` to dotfiles
    - Add example to one workspace project

---

## Known Limitations & Caveats

### 1. **Pane Command Execution**
Wezterm's Lua API doesn't have native "spawn command in pane" - we use `pane:send_text()` which:
- ✅ Works like typing in terminal
- ❌ Can't detect if command failed
- ❌ May conflict with shell hooks (e.g., starship prompt)

**Mitigation:** Add slight delay between pane creation and command execution.

### 2. **Workspace Persistence**
Workspaces only persist while Wezterm is running:
- ✅ Survives window closing
- ❌ Lost on Wezterm restart
- ❌ No automatic save/restore (unlike tmux-resurrect)

**Future Enhancement:** Could implement workspace serialization to JSON file.

### 3. **Config Reload**
Changes to `.wezterm-project.lua` require:
- Reopening the workspace (not just reloading Wezterm config)
- Or manually killing workspace and recreating

**Mitigation:** Add "Refresh Layout" keybinding.

### 4. **Nested Layout Complexity**
Very deep nesting (>3 levels) becomes hard to visualize:
- Pane sizes may be too small to be useful
- Complex configs are harder to debug

**Recommendation:** Keep layouts 2 levels deep max.

### 5. **FZF Integration**
Not implementing FZF mode in v1 because:
- Wezterm Lua can't easily spawn FZF and capture result
- Would need shell script wrapper + complex IPC
- Launcher menu with `fuzzy = true` provides similar UX

**Future:** Could use `wezterm.action.SpawnCommandInNewWindow` + custom shell script.

---

## Testing Plan

### Unit Tests (Manual)
```lua
-- Test scanner
local scanner = require("project-scanner")
local projects = scanner.scan_projects({...})
assert(#projects > 0, "Should find projects")
assert(projects[1].path ~= nil, "Should have path")

-- Test config loader
local loader = require("project-config")
local config = loader.load("/nonexistent")
assert(config.icon == "📁", "Should return default config")
```

### Integration Tests
1. **Empty workspace** → Should create with nvim .
2. **Simple layout** → Verify 2 panes created
3. **Nested layout** → Verify 3+ panes with correct sizes
4. **Worktree** → Verify parent config used
5. **Switch existing** → Verify no duplicate workspace
6. **Invalid config** → Verify graceful fallback

### Manual Test Scenarios
```bash
# 1. Create test projects
mkdir -p ~/workspace/test-simple
git init ~/workspace/test-simple

mkdir -p ~/workspace/test-complex
git init ~/workspace/test-complex
echo 'return { icon = "🧪", layout = {...} }' > ~/workspace/test-complex/.wezterm-project.lua

# 2. Open Wezterm
# 3. Press CTRL+F
# 4. Verify both projects appear
# 5. Select test-simple → verify opens with nvim
# 6. Press CTRL+F again
# 7. Select test-complex → verify multiple panes created
# 8. Switch back to test-simple → verify reuses workspace
```

---

## Stow Integration

Since configs go in `wezterm/.config/wezterm/`, stow will create symlinks:
```bash
# After implementation:
cd ~/dotfiles
stow -R wezterm

# Results in:
~/.wezterm.lua -> ~/dotfiles/wezterm/.wezterm.lua
~/.config/wezterm/ -> ~/dotfiles/wezterm/.config/wezterm/
```

**Important:** The `wezterm/.config/wezterm/` directory doesn't exist yet, so we'll create it during implementation.

---

## Future Enhancements

### 1. **FZF Mode**
Add alternative selector using FZF:
```lua
config.keys = {
  { key = "f", mods = "CTRL", action = ... },  -- Launcher (existing)
  { key = "f", mods = "CTRL|SHIFT", action = ... }  -- FZF mode (future)
}
```

### 2. **Session Persistence**
Save/restore workspaces across Wezterm restarts:
```lua
-- On shutdown: serialize active workspaces to ~/.wezterm-sessions.json
-- On startup: restore workspaces from file
```

### 3. **Recent Projects**
Track last-used projects:
```lua
-- Show recent projects at top of list
-- Add "Clear recent" option
```

### 4. **Project Templates**
Generate `.wezterm-project.lua` from templates:
```bash
wezterm-project init --template node-fullstack
```

### 5. **Status Bar Integration**
Show project status in tab bar:
```lua
-- Green dot = all commands running
-- Red dot = command failed
-- Gray dot = workspace idle
```

---

## Summary

**Files to Create:**
- `wezterm/.config/wezterm/project-scanner.lua` (~100 lines)
- `wezterm/.config/wezterm/project-config.lua` (~80 lines)
- `wezterm/.config/wezterm/workspace-manager.lua` (~120 lines)
- `wezterm/.config/wezterm/pane-builder.lua` (~150 lines)

**Files to Modify:**
- `wezterm/.wezterm.lua` (add ~80 lines)

**Total:** ~530 lines of Lua code

**Estimated Implementation Time:** 3-4 hours (with testing)

**Tool: todowrite**

**Input:**
```json
{
  "todos": [
    {
      "content": "Research Wezterm workspace and pane APIs",
      "status": "completed",
      "priority": "high"
    },
    {
      "content": "Design project scanner for git repos and worktrees",
      "status": "completed",
      "priority": "high"
    },
    {
      "content": "Design workspace manager with nested pane layouts",
      "status": "completed",
      "priority": "high"
    },
    {
      "content": "Design project config loader with fallback logic",
      "status": "completed",
      "priority": "high"
    },
    {
      "content": "Create final implementation plan document",
      "status": "completed",
      "priority": "high"
    }
  ]
}
```

**Output:**
```
[
  {
    "content": "Research Wezterm workspace and pane APIs",
    "status": "completed",
    "priority": "high"
  },
  {
    "content": "Design project scanner for git repos and worktrees",
    "status": "completed",
    "priority": "high"
  },
  {
    "content": "Design workspace manager with nested pane layouts",
    "status": "completed",
    "priority": "high"
  },
  {
    "content": "Design project config loader with fallback logic",
    "status": "completed",
    "priority": "high"
  },
  {
    "content": "Create final implementation plan document",
    "status": "completed",
    "priority": "high"
  }
]
```

---

## Assistant (Plan · claude-sonnet-4-5 · 11.4s)

---

## Questions Before Implementation

I've completed the comprehensive plan above. Before I proceed with implementation, I want to confirm a few final details:

1. **Tab bar visibility:** I've enabled the tab bar to show workspace names (hidden when only one tab). Is this okay, or do you want to keep `enable_tab_bar = false` and show workspace names elsewhere?

2. **Command execution delay:** When creating multiple panes, should I add a small delay (e.g., 100ms) between pane creation and command execution to avoid race conditions with shell initialization?

3. **Default split behavior:** For layouts without explicit `direction`, should I:
   - Default to vertical (side-by-side) splits?
   - Default to horizontal (stacked) splits?
   - Automatically choose based on terminal dimensions?

4. **Icon style:** For the default icon (when not specified in config), do you prefer:
   - 📁 (folder) - generic
   - 💼 (briefcase) - professional
   - 🔨 (hammer) - work/project
   - Or something else?

5. **Error handling UX:** When a project config is invalid, should I:
   - Show notification popup in Wezterm
   - Fall back to default silently
   - Log to Wezterm debug console only

6. **Implementation approach:** Would you like me to:
   - Implement all files in one go (all 5 files)
   - Implement incrementally (scanner → config → workspace → pane → integration)
   - Start with a minimal working version (just scanner + basic switching, no complex layouts)

Let me know your preferences and I'll proceed with the implementation!

