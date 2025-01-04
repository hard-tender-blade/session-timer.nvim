local defaultSessionTimerConfiguration = {
    sessionTimeSeconds = 60,
    showSessionEndWindow = true,
    onSessionStart = function() end,
    onSessionEnd = function() end,
    onSessionKill = function() end,
    events = {
        {
            secondsBeforeSessionTimerEnds = 3,
            hook = function()
                print("Session will end in 3 seconds")
            end
        },
        {
            secondsBeforeSessionTimerEnds = 2,
            hook = function()
                print("Session will end in 2 seconds")
            end
        },
        {
            secondsBeforeSessionTimerEnds = 1,
            hook = function()
                print("Session will end in 1 second")
            end
        }
    }
}
local function create_floating_window(opts)
    opts = opts or {}
    local width = 37
    local height = 3

    -- Calculate the position to the center of the window
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create a buffer
    local buf = vim.api.nvim_create_buf(false, true) -- no file, scratch buffer

    -- Define window configuration
    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        title = "Session Ended",
        title_pos = "center",
        footer = "Press <Esc> / q to close",
        footer_pos = "center",
        style = "minimal", -- no statusline, no tabline, no borders
        border = "rounded",
    }

    -- Create a new window with buf attached
    local win = vim.api.nvim_open_win(buf, true, win_config)

    -- Add keymaps to escape the window
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<Cmd>q<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<leader>", "<Cmd>q<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<Cmd>q<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<enter>", "<Cmd>q<CR>", { noremap = true, silent = true })

    return {
        buf = buf,
        win = win,
    }
end

local convertSeondsToHumanReadable = function(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return minutes .. "m " .. remainingSeconds .. "s"
end

local M = {}

M.timer = nil
M.eventTimers = {}
M.sessionStartTimestamp = nil
M.opts = defaultSessionTimerConfiguration

M.setup = function(opts)
    opts = opts or {}

    M.opts = {
        sessionTimeSeconds = opts.sessionTimeSeconds or defaultSessionTimerConfiguration.sessionTimeSeconds,
        showSessionEndWindow = opts.showSessionEndWindow or defaultSessionTimerConfiguration.showSessionEndWindow,
        onSessionStart = opts.onSessionStart or defaultSessionTimerConfiguration.onSessionStart,
        onSessionEnd = opts.onSessionEnd or defaultSessionTimerConfiguration.onSessionEnd,
        onSessionKill = opts.onSessionKill or defaultSessionTimerConfiguration.onSessionKill,
        events = opts.events or defaultSessionTimerConfiguration.events
    }
end

M.cleanTimer = function()
    if M.timer then
        M.timer:stop()
        M.timer:close()
        M.timer = nil
    end
    if #M.eventTimers > 0 then
        for _, eventTimer in ipairs(M.eventTimers) do
            eventTimer:stop()
            eventTimer:close()
        end
        M.eventTimers = {}
    end
end


M.showSessionEndWindow = function()
    local floating_win = create_floating_window()
    vim.api.nvim_buf_set_lines(floating_win.buf, 0, -1, false, {
        "                                     ",
        "█        Let’s take a break..        ",
        "                                     ",
    })
end

M.startSession = function()
    M.cleanTimer() -- Stop any existing timr to avoid conflicts

    M.opts.onSessionStart()

    ---@diagnostic disable-next-line: undefined-field
    M.timer = vim.loop.new_timer()
    M.timer:start(
        M.opts.sessionTimeSeconds * 1000,
        0, -- One-shot timer
        vim.schedule_wrap(function()
            M.cleanTimer()
            M.opts.onSessionEnd()
            if M.opts.showSessionEndWindow then
                M.showSessionEndWindow()
            end
        end)
    )
    M.sessionStartTimestamp = os.time()

    --- Remove events that have a greater time than the session time
    local validEvents = {}
    for _, event in ipairs(validEvents) do
        if event.secondsBeforeSessionTimerEnds < M.opts.sessionTimeSeconds then
            table.insert(validEvents, event)
        end
    end

    for _, event in ipairs(M.opts.events) do
        ---@diagnostic disable-next-line: undefined-field

        local eventTimer = vim.loop.new_timer()
        eventTimer:start(
            (M.opts.sessionTimeSeconds - event.secondsBeforeSessionTimerEnds) * 1000,
            0, -- One-shot timer
            vim.schedule_wrap(function()
                event.hook()
            end)
        )
        table.insert(M.eventTimers, eventTimer)
    end
end

M.killSession = function()
    M.cleanTimer()
    M.opts.onSessionKill()
end


vim.api.nvim_create_user_command("STSessionStart", function()
    M.startSession()
end, {})

vim.api.nvim_create_user_command("STSessionKill", function()
    M.killSession()
end, {})

vim.api.nvim_create_user_command("STSessionTimeLeft", function()
    if M.sessionStartTimestamp then
        local timeLeft = M.opts.sessionTimeSeconds - (os.time() - M.sessionStartTimestamp)
        vim.notify("Time left: " .. convertSeondsToHumanReadable(timeLeft))
    else
        vim.notify("No session is running")
    end
end, {})

return M
