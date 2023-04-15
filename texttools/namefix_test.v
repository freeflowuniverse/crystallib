module texttools

fn test_main() {

	assert name_fix_keepext("\$sds__ 4F")=="sds_4f"
	assert name_fix_keepext("\$sds_?__ 4F")=="sds_4f"
	assert name_fix_keepext("\$sds_?_!\"`{_ 4F")=="sds_4f"
	assert name_fix_keepext("\$sds_?_!\"`{_ 4F.jpg")=="sds_4f.jpg"

}
