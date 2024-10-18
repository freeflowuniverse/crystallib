module components

pub struct Layout {
pub:
    components []IComponent
}

pub fn (layout Layout) html() string {
    return layout.components.map(it.html()).join('\n')
}