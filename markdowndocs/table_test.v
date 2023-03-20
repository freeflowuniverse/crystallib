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
	assert table.alignments == [.left, .left, .left]
	assert table.rows == []
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |

'
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
	assert table.alignments == [.left, .left, .left]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"]
	]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |

'
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
	assert table.alignments == [.left, .left, .left]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |
| Row2Col1 | Row2Col2 | Row2Col3 |

'
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
	assert table.alignments == [.left, .left, .left]
	assert table.rows == [
		["Row1Col1", "", ""],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 |  |  |
| Row2Col1 | Row2Col2 | Row2Col3 |

'
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
	assert table.alignments == [.left, .left, .left]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |
| Row2Col1 | Row2Col2 | Row2Col3 |

'
}

fn test_table_two_rows_weird_format_yet_valid() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3 |
-|--------------------------|--
|   Row1Col1  | Row1Col2     | Row1Col3
Row2Col1  | Row2Col2     | Row2Col3       

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.header == ["Column1", "Column2", "Column3"]
	assert table.alignments == [.left, .left, .left]
	assert table.rows == [
		["Row1Col1", "Row1Col2", "Row1Col3"],
		["Row2Col1", "Row2Col2", "Row2Col3"]
	]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |
| Row2Col1 | Row2Col2 | Row2Col3 |

'
}

fn test_table_one_row_alignment_left() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|:------------|:-------------|:-----------|
|   Row1Col1  | Row1Col2     | Row1Col3   |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.alignments == [.left, .left, .left]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |

'
}


fn test_table_one_row_alignment_right() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|------------:|-------------:|-----------:|
|   Row1Col1  | Row1Col2     | Row1Col3   |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.alignments == [.right, .right, .right]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| --: | --: | --: |
| Row1Col1 | Row1Col2 | Row1Col3 |

'
}

fn test_table_one_row_alignment_center() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    |
|:-----------:|:------------:|:----------:|
|   Row1Col1  | Row1Col2     | Row1Col3   |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 3
	assert table.alignments == [.center, .center, .center]
	assert table.wiki() == '| Column1 | Column2 | Column3 |
| :-: | :-: | :-: |
| Row1Col1 | Row1Col2 | Row1Col3 |

'
}

fn test_table_one_row_alignment_mixed() {
	mut docs := new(content: '
|   Column1   | Column2      | Column3    | Column4   |
|:------------|:------------:|-----------:|-----------|
|   Row1Col1  | Row1Col2     | Row1Col3   | Row1Col4  |

')!
	assert docs.items.len == 1
	assert docs.items[0] is Table
	table := docs.items[0] as Table
	assert table.num_columns == 4
	assert table.alignments == [.left, .center, .right, .left]
	assert table.wiki() == '| Column1 | Column2 | Column3 | Column4 |
| :-- | :-: | --: | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 | Row1Col4 |

'
}
