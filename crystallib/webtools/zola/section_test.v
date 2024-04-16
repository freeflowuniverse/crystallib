module zola

fn test_section_export() {
	section := Section{}
	section.export('test')!
}
