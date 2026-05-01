local git_cache = {
  branch = "",
  stats = "",
  time = 0,
  root = nil,
}

-- safely find git root once per buffer
local function git_root()
  if git_cache.root ~= nil then
    return git_cache.root
  end

  local result = vim.fn.system("git rev-parse --show-toplevel 2>nul")

  if vim.v.shell_error ~= 0 then
    git_cache.root = false
    return nil
  end

  local root = result:gsub("%s+", "")

  if root == "" then
    git_cache.root = false
    return nil
  end

  git_cache.root = root
  return root
end

-- safe git command runner
local function git_cmd(cmd)
  local root = git_root()
  if not root then
    return ""
  end

  local full = string.format('git -C "%s" %s 2>nul', root, cmd)
  return vim.fn.system(full)
end

-- update cached git info (throttled)
local function update_git_cache()
  local now = vim.loop.now()
  if now - git_cache.time < 1000 then
    return
  end
  git_cache.time = now

  local root = git_root()
  if not root then
    git_cache.branch = ""
    git_cache.stats = ""
    return
  end

  -- branch
  local branch = git_cmd("branch --show-current"):gsub("%s+", "")
  if branch == "" then
    branch = "(detached)"
  end
  git_cache.branch = branch

  -- ONLY + and - stats
  local status = git_cmd("status --porcelain")

  local added, deleted = 0, 0

  for line in status:gmatch("[^\n]+") do
    local x = line:sub(1, 1)
    local y = line:sub(2, 2)

    if x == "A" or y == "A" then
      added = added + 1
    elseif x == "D" or y == "D" then
      deleted = deleted + 1
    end
  end

  if added > 0 or deleted > 0 then
    git_cache.stats = string.format(" +%d -%d", added, deleted)
  else
    git_cache.stats = ""
  end
end

-- mode display
local function mode()
  local m = vim.fn.mode()

  local modes = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    c = "COMMAND",
    R = "REPLACE",
    t = "TERMINAL",
  }

  return " " .. (modes[m] or m) .. " "
end

-- git display
local function git_status()
  update_git_cache()

  if git_cache.branch == "" then
    return ""
  end

  return "⎇  " .. git_cache.branch .. git_cache.stats .. " "
end

-- statusline
function _G.customStatusLine()
  local git = git_status()

  if git == "" then
      git = "⎇  None"
  end
  return mode() .. "| " .. git .. "| ".. "%t" .. "%=" .. "Line: %l" .. " | " .. "Col: %c"
end

-- Neovim settings
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.statusline = "%!v:lua.customStatusLine()"
