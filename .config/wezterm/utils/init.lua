local M = {}

function M.apply(config)
	require("utils.save_output").apply(config)
	require("utils.smart_splits_req").apply()
	require("utils.find_pane")
end

return M
