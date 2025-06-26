local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")

-- Function to sort the markdown table by the current column
function M.sort_markdown_table_by_current_column(reverse)
	local current_node = ts_utils.get_node_at_cursor()

	if current_node == nil or current_node:type() ~= "inline" then
		print("Node is not an inline node, exiting.")
		return
	end

	-- Save current column position
	local col_position = vim.fn.col(".")

	-- Go to start of current inline node
	local start_row, start_col = current_node:start()

	-- Get the root of the Tree-sitter tree
	local parser = vim.treesitter.get_parser(0, "markdown")
	local tree = parser:parse()[1]
	local root = tree:root()

	-- Find the cell node at the start position using descendant_for_range
	local cell_node = root:descendant_for_range(start_row, start_col, start_row, start_col)

	-- Get the parent of the cell node and check if it's a table row
	local row_node = cell_node and cell_node:parent()
	if not row_node or row_node:type() ~= "pipe_table_row" then
		print("No table row found, exiting.")
		return
	end

	-- Get the column cells for the current row
	local column_cells = ts_utils.get_named_children(row_node)

	-- Find the column index of the current inline node
	local col_index = -1
	for i, cell in ipairs(column_cells) do
		local sr, sc, _, ec = cell:range()
		if sr == start_row and sc <= col_position and col_position <= ec then
			col_index = i
			break
		end
	end

	if col_index == -1 then
		print("Could not determine column index")
		return
	end

	print("Column index: " .. col_index)

	-- Find the table parent
	local parent = row_node:parent()
	while parent and parent:type() ~= "pipe_table" do
		parent = parent:parent()
	end

	if not parent then
		print("No table parent found")
		return
	end

	-- Collect table rows
	local rows = {}
	for row in parent:iter_children() do
		if row:type() == "pipe_table_row" then
			table.insert(rows, row)
		end
	end

	-- Sort the rows based on the column index
	table.sort(rows, function(a, b)
		local field_a_arr = ts_utils.get_node_text(a:named_child(col_index - 1)) or ""
		local field_b_arr = ts_utils.get_node_text(b:named_child(col_index - 1)) or ""

		-- Ensure that field_a and field_b are strings
		local field_a = tostring(field_a_arr[1])
		local field_b = tostring(field_b_arr[1])

		-- Check if the fields are numeric
		local num_a = tonumber(field_a)
		local num_b = tonumber(field_b)

		if num_a and num_b then
			-- Numeric comparison
			if num_a == num_b then
				return a:start() < b:start()
			else
				if reverse then
					return num_a > num_b
				else
					return num_a < num_b
				end
			end
		else
			-- String comparison
			if field_a == field_b then
				return a:start() < b:start()
			else
				if reverse then
					return field_a > field_b
				else
					return field_a < field_b
				end
			end
		end
	end)

	-- Set the sorted lines back to the buffer, starting after the header and delimiter rows
	local new_lines = {}
	for i = 1, #rows do
		table.insert(new_lines, ts_utils.get_node_text(rows[i])[1])
	end
	local start_line = parent:start() + 3
	vim.fn.setline(start_line, new_lines)
end

function M.setup()
	-- Command to sort the table
	vim.api.nvim_create_user_command("SortTable", function(opts)
		require("markdown-table-sort").sort_markdown_table_by_current_column(opts.args)
	end, { nargs = 1 })
end

return M
