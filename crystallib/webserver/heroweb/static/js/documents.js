function scrollLeft(listId) {
    const list = document.getElementById(listId);
    list.scrollBy({
        left: -300,
        behavior: 'smooth'
    });
}

function scrollRight(listId) {
    const list = document.getElementById(listId);
    list.scrollBy({
        left: 300,
        behavior: 'smooth'
    });
}