module heroweb

enum PriorityEnum {
    critical
    urgent
    normal
    low
    no
}

fn priority_colorenum(prio PriorityEnum) ColorEnum {
    return match prio {
        .critical { .red }
        .urgent { .red }
        .normal { .green }
        .low { .yellow }
        .no { .white }
    }
}


