return {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    config = function()
        local os_name = vim.loop.os_uname().sysname
        local agenda_files = ''
        local notes_file = ''

        -- Linux
        if os_name == 'Linux' then
            agenda_files = '~/notes/org/**/*'
            notes_file = '~/notes/org/refile.org'

            -- macOS
        elseif os_name == 'Darwin' then
            agenda_files = '~/ben/notes/org/**/*'
            notes_file = '~/ben/notes/org/refile.org'

            -- Windows
        elseif os_name == 'Windows_NT' then
            agenda_files = 'C:/Users/YourUsername/orgfiles/**/*'
            notes_file = 'C:/Users/YourUsername/orgfiles/refile.org'
        else
            vim.notify('Unknown OS for orgmode config')
        end

        require('orgmode').setup({
            org_agenda_files = agenda_files,
            org_default_notes_file = notes_file,
        })
    end,
}
