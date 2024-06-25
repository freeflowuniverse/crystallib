module markdownparser

import freeflowuniverse.crystallib.data.markdownparser.elements { Table }

fn test_table_no_rows_invalid() {
	mut content := '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
'
	if _ := new(content: content) {
		assert true
	} else {
		assert false
	}

	content = '
|   Column1   | Column2      | Column3    |
'
	if doc := new(content: content) {
		// this shouldn't be parsed as table since it is only single row
		assert doc.children.len == 1
		elem := doc.children[0]
		assert elem !is Table
	}
}

fn test_table_one_row() {
	mut docs := new(
		content: '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | Row1Col2     | Row1Col3   |
'
	)!
	assert docs.children.len == 2
	table := docs.children[1]
	if table is Table {
		assert table.num_columns == 3
		assert table.header.len == 3
		assert table.header_markdown()! == '| Column1 | Column2 | Column3 |
'
		assert table.alignments == [.left, .left, .left]
		assert table.rows.len == 1

		// assert table.rows == [
		// 	Row{
		// 		cells: ['Row1Col1', 'Row1Col2', 'Row1Col3']
		// 	},
		// ]
		assert table.markdown()! == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |
'
	}
}

fn test_table_two_rows() {
	mut docs := new(
		content: '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | Row1Col2     | Row1Col3   |
|   Row2Col1  | Row2Col2     | Row2Col3   |
'
	)!
	assert docs.children.len == 2
	table := docs.children[1]
	if table is Table {
		assert table.num_columns == 3
		assert table.header.len == 3
		assert table.header_markdown()! == '| Column1 | Column2 | Column3 |
'
		assert table.alignments == [.left, .left, .left]
		assert table.rows.len == 2
		// assert table.rows == [
		// 	Row{
		// 		cells: ['Row1Col1', 'Row1Col2', 'Row1Col3']
		// 	},
		// 	Row{
		// 		cells: ['Row2Col1', 'Row2Col2', 'Row2Col3']
		// 	},
		// ]
		assert table.markdown()! == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |
| Row2Col1 | Row2Col2 | Row2Col3 |
'
	}
}

fn test_table_two_rows_one_is_half_filled_invalid() {
	content := '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | 
|   Row2Col1  | Row2Col2     | Row2Col3   |
'
	if _ := new(content: content) {
		assert false, 'should return an error: wrongly formatted row'
	}
}

fn test_table_two_rows_one_is_filled_too_much() {
	content := '
|   Column1   | Column2      | Column3    |
|-------------|--------------|------------|
|   Row1Col1  | Row1Col2     | Row1Col3   | Row1Col4 |
|   Row2Col1  | Row2Col2     | Row2Col3   |
'
	if _ := new(content: content) {
		assert false, 'should return an error: wrongly formatted row'
	}
}

// fn test_table_two_rows_weird_format_yet_valid() {
// 	mut docs := new(
// 		content: '
// |   Column1   | Column2      | Column3 |
// -|--------------------------|--
// |   Row1Col1  | Row1Col2     | Row1Col3
// Row2Col1  | Row2Col2     | Row2Col3
// '
// 	)!
// 	assert docs.children.len == 1
// 	table := docs.children[0]
// 	if table is Table {
// 		assert table.num_columns == 3
// 		assert table.header == ['Column1', 'Column2', 'Column3']
// 		assert table.alignments == [.left, .left, .left]
// 		assert table.rows == [
// 			Row{
// 				cells: ['Row1Col1', 'Row1Col2', 'Row1Col3']
// 			},
// 			Row{
// 				cells: ['Row2Col1', 'Row2Col2', 'Row2Col3']
// 			},
// 		]
// 		assert table.markdown()! == '| Column1 | Column2 | Column3 |
// | :-- | :-- | :-- |
// | Row1Col1 | Row1Col2 | Row1Col3 |
// | Row2Col1 | Row2Col2 | Row2Col3 |

// '
// 	}
// }

fn test_table_one_row_alignment_left() {
	mut docs := new(
		content: '
|   Column1   | Column2      | Column3    |
|:------------|:-------------|:-----------|
|   Row1Col1  | Row1Col2     | Row1Col3   |
'
	)!
	assert docs.children.len == 2
	table := docs.children[1]
	if table is Table {
		assert table.num_columns == 3
		assert table.alignments == [.left, .left, .left]
		assert table.markdown()! == '| Column1 | Column2 | Column3 |
| :-- | :-- | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 |
'
	}
}

fn test_table_one_row_alignment_right() {
	mut docs := new(
		content: '
|   Column1   | Column2      | Column3    |
|------------:|-------------:|-----------:|
|   Row1Col1  | Row1Col2     | Row1Col3   |
'
	)!
	assert docs.children.len == 2
	table := docs.children[1]
	if table is Table {
		assert table.num_columns == 3
		assert table.alignments == [.right, .right, .right]
		assert table.markdown()! == '| Column1 | Column2 | Column3 |
| --: | --: | --: |
| Row1Col1 | Row1Col2 | Row1Col3 |
'
	}
}

fn test_table_one_row_alignment_center() {
	mut docs := new(
		content: '
|   Column1   | Column2      | Column3    |
|:-----------:|:------------:|:----------:|
|   Row1Col1  | Row1Col2     | Row1Col3   |
'
	)!
	assert docs.children.len == 2
	table := docs.children[1]
	if table is Table {
		assert table.num_columns == 3
		assert table.alignments == [.center, .center, .center]
		assert table.markdown()! == '| Column1 | Column2 | Column3 |
| :-: | :-: | :-: |
| Row1Col1 | Row1Col2 | Row1Col3 |
'
	}
}

fn test_table_one_row_alignment_mixed() {
	mut docs := new(
		content: '
|   Column1   | Column2      | Column3    | Column4   |
|:------------|:------------:|-----------:|-----------|
|   Row1Col1  | Row1Col2     | Row1Col3   | Row1Col4  |
'
	)!
	assert docs.children.len == 2
	table := docs.children[1]
	if table is Table {
		assert table.num_columns == 4
		assert table.alignments == [.left, .center, .right, .left]
		assert table.markdown()! == '| Column1 | Column2 | Column3 | Column4 |
| :-- | :-: | --: | :-- |
| Row1Col1 | Row1Col2 | Row1Col3 | Row1Col4 |
'
	}
}
