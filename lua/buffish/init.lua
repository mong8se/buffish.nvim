local open = function() require("buffish.session").open_session_buffer() end

return {
  setup = function()
    vim.api.nvim_create_user_command("Buffish", open, {nargs = 0})
    vim.api.nvim_create_user_command("BuffishFollow", function(opts)
      require("buffish.shortcuts").follow(opts.args)
    end, {nargs = "?"})
  end,
  open = open
}
