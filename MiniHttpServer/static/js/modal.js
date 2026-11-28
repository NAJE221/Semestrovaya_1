const modal = document.getElementById("card-modal") ?? document.body.appendChild(
    Object.assign(document.createElement("div"), {id: "card-modal", className: "modal", hidden: true}));


let abortController = null;
let debounceTimer = null;

function setVisible(visible) {
    modal.hidden = !visible;
    modal.style.display = visible ? "" : "none";
    document.body.classList.toggle("modal-open", visible);
}

function showModal(html) {
    modal.innerHTML = html;
    setVisible(true);
}

function closeModal() {
    if (abortController) {
        abortController.abort();
        abortController = null;
    }
    if (debounceTimer) {
        clearTimeout(debounceTimer);
        debounceTimer = null;
    }
    setVisible(false);
    modal.innerHTML = "";
}

function neighbours(slug) {
    const slugs = [...new Set([...document.querySelectorAll(".card-link[data-card-slug]")].map(el => el.dataset.cardSlug))];
    const index = slugs.indexOf(slug);
    return {
        prev: index > 0 ? slugs[index - 1] : "",
        next: index >= 0 && index < slugs.length - 1 ? slugs[index + 1] : ""
    };
}

async function loadCard(slug) {
    if (abortController) {
        abortController.abort();
    }
    if (debounceTimer) {
        clearTimeout(debounceTimer);
    }

    return new Promise((resolve) => {
        debounceTimer = setTimeout(async () => {
            abortController = new AbortController();

            const {prev, next} = neighbours(slug);
            let html;
            try {
                const params = new URLSearchParams({slug});
                if (prev) params.set("prev", prev);
                if (next) params.set("next", next);
                const url = `/hearthstone/card?${params}`;

                const response = await fetch(url, {signal: abortController.signal});

                if (!response.ok) throw new Error(`HTTP ${response.status}`);
                html = await response.text();
            } catch (error) {
                if (error.name === 'AbortError') {
                    resolve();
                    return;
                }
                html = '<div class="modal__dialog"><button class="modal__close" type="button" data-modal-close>&times;</button><p>Не удалось загрузить карту.</p></div>';
            }

            showModal(html);
            resolve();
        }, 200);
    });
}

document.addEventListener("click", event => {
    const target = event.target.closest(".card-link[data-card-slug], .modal__arrow[data-card-slug]");
    if (target) {
        event.preventDefault();
        loadCard(target.dataset.cardSlug);
    } else if (!modal.hidden && (event.target === modal || event.target.closest("[data-modal-close]"))) {
        closeModal();
    }
});

document.addEventListener("keydown", event => {
    if (modal.hidden) return;
    if (event.key === "Escape") closeModal();
    else if (event.key === "ArrowLeft") modal.querySelector(".modal__arrow--prev")?.click();
    else if (event.key === "ArrowRight") modal.querySelector(".modal__arrow--next")?.click();
});

setVisible(false);
