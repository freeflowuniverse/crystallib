module couchdb

@[params]
pub struct GetDocumentQueryParams {
pub mut:
	// Includes attachments bodies in response.
	attachments ?bool
	// Includes encoding information in attachment stubs if the particular attachment is compressed.
	att_encoding_info ?bool
	// Includes attachments only since specified revisions. Doesn’t includes attachments for specified revisions.
	atts_since ?[]string
	// Includes information about conflicts in document.
	conflicts ?bool
	// Includes information about deleted conflicted revisions.
	deleted_conflicts ?bool
	//  Forces retrieving latest “leaf” revision, no matter what rev was requested.
	latest ?bool
	// Includes last update sequence for the document.
	local_seq ?bool
	// Acts same as specifying all conflicts, deleted_conflicts and revs_info query parameters.
	meta ?bool
	// Retrieves documents of specified leaf revisions. Additionally, it accepts value as all to return all leaf revisions.
	open_revs ?[]string
	// Retrieves document of specified revision.
	rev ?string
	// Includes list of all known document revisions.
	revs ?bool
	// Includes detailed information for all known document revisions.
	revs_info ?bool
}

fn (p GetDocumentQueryParams) encode() string {
	mut ret := ''
	if val := p.attachments {
		ret = '${ret}attachments=${val}&'
	}

	if val := p.att_encoding_info {
		ret = '${ret}att_encoding_info=${val}&'
	}

	if val := p.atts_since {
		mut enc_array := ''
		for el in val {
			enc_array = '${enc_array},${el}'
		}
		ret = '${ret}atts_since=${enc_array}&'
	}

	if val := p.conflicts {
		ret = '${ret}conflicts=${val}&'
	}

	if val := p.deleted_conflicts {
		ret = '${ret}deleted_conflicts=${val}&'
	}

	if val := p.latest {
		ret = '${ret}latest=${val}&'
	}

	if val := p.local_seq {
		ret = '${ret}local_seq=${val}&'
	}

	if val := p.meta {
		ret = '${ret}meta=${val}&'
	}

	if val := p.open_revs {
		mut enc_array := ''
		for el in val {
			enc_array = '${enc_array},${el}'
		}
		ret = '${ret}open_revs=${enc_array}&'
	}

	if val := p.rev {
		ret = '${ret}rev=${val}&'
	}

	if val := p.revs {
		ret = '${ret}revs=${val}&'
	}

	if val := p.revs_info {
		ret = '${ret}revs_info=${val}&'
	}

	return ret
}
