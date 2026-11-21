function closeDropdowns(except = null) {
    document.querySelectorAll("[data-toggle].is-open:not(#more-filters__button)").forEach(item => {
        if (item === except) return;
        item.classList.remove("is-open");
        item.blur();
    });
}

document.addEventListener("click", event => {
    const more = event.target.closest("#more-filters__button");
    if (more) {
        const isOpen = document.getElementById("advanced__filters").classList.toggle("is-open");
        more.classList.toggle("is-open", isOpen);
        more.setAttribute("aria-expanded", isOpen);
        if (!isOpen) closeDropdowns();
        return;
    }

    const toggle = event.target.closest("[data-toggle]");
    if (toggle) {
        closeDropdowns(toggle);
        toggle.classList.toggle("is-open");
    } else if (!event.target.closest(".filter-list__container")) {
        closeDropdowns();
    }
});

document.addEventListener("keydown", event => {
    if (event.key === "Escape") closeDropdowns();
});
