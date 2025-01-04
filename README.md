# session-timer.nvim

A simple and lightweight Neovim plugin to help manage work sessions, preventing burnout by encouraging breaks.

## Idea

The idea behind this plugin is to help me take regular breaks for physical exercise or to relax my eyes. You can easily customize the plugin to fit your own time limits.

## Installation

### Lazy.nvim

```lua
return {
    {
        "hard-tender-blade/session-timer.nvim",
        config = function()
            require("session-timer").setup()
        end
    }
}
```

## Usage

Here’s a configuration I prefer. I use `notify` to receive notifications. I work in 45-minute intervals, followed by a 10-minute break. Additionally, I get a notification 10 minutes before a session ends to wrap up my work, and 3-1 seconds before the window pops up, so I’m prepared.

```lua
return {
    {
        dir = "hard-tender-blade/session-timer.nvim",
        dependencies = {
            "rcarriga/nvim-notify",
        },
        config = function()
            require("session-timer").setup({
                sessionTimeSeconds = 2700, -- 45 minutes
                showSessionEndWindow = true,
                onSessionStart = function()
                    require("notify")("Session started", "info")
                    -- if you dont use notify:
                    -- vim.notify("Session started")
                end,
                onSessionEnd = function() end,
                onSessionKill = function()
                    require("notify")("Session killed", "info")
                    -- if you dont use notify:
                    -- vim.notify("Session killed")
                end,
                events = {
                    {
                        secondsBeforeSessionTimerEnds = 600, -- 10 minutes
                        hook = function()
                            require("notify")("Ending session in 10m", "info")
                            -- if you dont use notify:
                            -- vim.notify("Ending session in 10m")
                        end
                    },
                    {
                        secondsBeforeSessionTimerEnds = 300, -- 5 minutes
                        hook = function()
                            require("notify")("Ending session in 5m", "info")
                        end
                    },
                    {
                        secondsBeforeSessionTimerEnds = 3,
                        hook = function()
                            require("notify")("Ending session in 3s", "info")
                        end
                    },
                    {
                        secondsBeforeSessionTimerEnds = 2,
                        hook = function()
                            require("notify")("Ending session in 2s", "info")
                        end
                    },
                    {
                        secondsBeforeSessionTimerEnds = 1,
                        hook = function()
                            require("notify")("Ending session in 1s", "info")
                        end
                    }
                }
            })
        end
    }
}
```

## Commands

There are also three commands you can use to control the plugin:
- `:STSessionStart` – Starts the session (will automatically kill the previous timer).
- `:STSessionKill` – Kills the session.
- `:STSessionTimeLeft` – Displays the time remaining in the current session.

You can bind these commands to keys like so:

```lua
vim.api.nvim_set_keymap("n", "<leader>ss", ":STSessionStart<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>sk", ":STSessionKill<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>sl", ":STSessionTimeLeft<CR>", { noremap = true, silent = true })
```

## TODO

- [ ] Make the timer work even after restarting Neovim.
- [ ] Allow configuration with human-readable time formats (e.g., 45m 30s).
- [ ] Add more window customization options.
- [ ] Add more event hooks.

## Feedback & Contributions
Feedback and contributions are always welcome! If you have any suggestions, bug reports, or want to improve the plugin, feel free to open an issue or submit a pull request. 

## License

MIT
