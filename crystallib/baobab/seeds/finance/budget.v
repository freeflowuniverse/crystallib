module finance

import freeflowuniverse.crystallib.baobab.base

pub struct Budget {	
pub mut:
    id string
    // expenses []Expense
}

struct Expense {
pub mut:
    id string
    category string
    amount f64
}