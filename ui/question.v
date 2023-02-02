module console

import os

pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
	regex       string
	minlen      int
}

// args:
// - description string
// - question string
// - warning: string (if it goes wrong, which message to use)
// - reset bool = true
// - regex: to check what result need to be part of
// - minlen: min nr of chars
//
pub fn (mut c UIChannel) ask_question(args QuestionArgs) string {

}
