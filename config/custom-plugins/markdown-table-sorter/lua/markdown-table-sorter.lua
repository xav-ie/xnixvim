local ts_utils = require("nvim-treesitter.ts_utils")

-- Function to log node information
-- local function log_node_info(node, description)
--   local row, col = node:start()
--   local end_row, end_col = node:end_()
--   local type = node:type()
--   print(string.format("%s: Type=%s, Range=[(%d, %d) - (%d, %d)]", description, type, row, col, end_row, end_col))
-- end

-- Function to sort the markdown table by the current column
function sort_markdown_table_by_current_column(reverse)
	local current_node = ts_utils.get_node_at_cursor()

	if current_node:type() ~= "inline" then
		print("Node is not an inline node, exiting.")
		return
	end

	-- log_node_info(current_node, "Initial inline node")

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

	-- log_node_info(row_node, "Table row node")

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
		-- log_node_info(parent, "Parent node")
		parent = parent:parent()
	end

	if not parent then
		print("No table parent found")
		return
	end

	-- log_node_info(parent, "Table parent node")

	-- Collect table rows
	local rows = {}
	for row in parent:iter_children() do
		if row:type() == "pipe_table_row" then
			table.insert(rows, row)
		end
	end

	-- Sort the rows based on the column index
	table.sort(rows, function(a, b)
		local field_a = ts_utils.get_node_text(a:named_child(col_index - 1)) or ""
		local field_b = ts_utils.get_node_text(b:named_child(col_index - 1)) or ""

		-- Ensure that field_a and field_b are strings
		field_a = tostring(field_a[1])
		field_b = tostring(field_b[1])

		-- Check if the fields are numeric
		local num_a = tonumber(field_a)
		local num_b = tonumber(field_b)

		-- Log the values being compared
		-- print(string.format("Comparing: field_a='%s', field_b='%s'", field_a, field_b))

		if num_a and num_b then
			-- Numeric comparison
			if reverse then
				return num_a > num_b
			else
				return num_a < num_b
			end
		else
			-- String comparison
			if reverse then
				return field_a > field_b
			else
				return field_a < field_b
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

-- Command to sort the table
vim.cmd([[
          command! -nargs=1 SortTable lua sort_markdown_table_by_current_column(<f-args>)
        ]])
