module markdowndocs

fn test_table_no_rows() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.header == ["Column1", "Column2", "Column3"]
	assert table.rows == [
	]
}

fn test_table_one_row() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | Row1Col2     | Row1Col3   |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.header == ["Column1", "Column2", "Column3"]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"]
	]
}

fn test_table_two_rows() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | Row1Col2     | Row1Col3   |
|   Row2Col1  | Row2Col2     | Row2Col3   |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.header == ["Column1", "Column2", "Column3"]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
}

fn test_table_two_rows_one_is_half_filled() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | 
|   Row2Col1  | Row2Col2     | Row2Col3   |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.header == ["Column1", "Column2", "Column3"]
	assert table.rows == [
		["Row1Col1", "", ""],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
}

fn test_table_two_rows_one_is_filled_too_much() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | Row1Col2     | Row1Col3   | Row1Col4 |
|   Row2Col1  | Row2Col2     | Row2Col3   |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.header == ["Column1", "Column2", "Column3"]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
}

fn test_table_two_rows_weird_format_yet_valid() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3 |
-------------|--------------|------------
|   Row1Col1  | Row1Col2     | Row1Col3
Row2Col1  | Row2Col2     | Row2Col3       

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.header == ["Column1", "Column2", "Column3"]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
}