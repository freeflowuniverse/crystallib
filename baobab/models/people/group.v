module people

//group of people (persons)
pub struct Group {
pub mut:
	name        string
	description string
	members     []&GroupMember
	votingprofile VotingProfile
}

pub enum VotingProfileState {
	init
	active
	inactive
}

pub struct VotingProfile {
pub mut:
	state			VotingProfileState
	votingpower_min	u16		
	votingnr_min	u8  	// min nr of votes required before vote can pass
	votingperc	u8			// 0...100 % of members voting who need to be positive before approve
	adminpower_min	u8      // can change descr, voting profile, voting/admin/usermod power of user
	usermodpower_min  u8    // min of power needed before users can be added/removed from group
	votingpower_immutable   // once set, the voting power can never be changed by admins any more
}

pub enum MemberState {
	init //the initial step
	active
	inactive
}


pub struct GroupMember {
pub mut:
	person_sid 	     Person
	description      string
	active       	 MemberState
	votingpower		u8 = 1 //if 0 means cannot vote
	adminpower		u8
	usermodpower 	u8
}





