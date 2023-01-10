module actionrunnerold

import os

const testpath = os.dir(@FILE) + '/testdata'

fn test_gitrunner() {
	execute('${actionrunner.testpath}/gitrunner/run.md')?
}

fn test_booksrunner() {
	execute('${actionrunner.testpath}/booksrunner/run.md')?
}

fn test_actionrunner() {
	execute('${actionrunner.testpath}/run.md')?
}
