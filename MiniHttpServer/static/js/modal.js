const modal = document.getElementById("card-modal") ?? document.body.appendChild(
    Object.assign(document.createElement("div"), { id: "card-modal", className: "modal", hidden: true }));

console.info("[modal] modal.js загружен");

let abortController = null;
let debounceTimer = null; // <-- Таймер для debounce

function setVisible(visible) {
    modal.hidden = !visible;
    modal.style.display = visible ? "" : "none";
    document.body.classList.toggle("modal-open", visible);
}

function showModal(html) {
    console.info("[modal] показываю модалку, длина html:", html.length);
    modal.innerHTML = html;
    setVisible(true);
}

function closeModal() {
    if (abortController) {
        abortController.abort();
        abortController = null;
    }
    if (debounceTimer) {
        clearTimeout(debounceTimer); // <-- Очищаем таймер при закрытии
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
    // Отменяем предыдущий запрос и таймер
    if (abortController) {
        abortController.abort();
    }
    if (debounceTimer) {
        clearTimeout(debounceTimer);
    }

    // Debounce: ждём 300мс перед выполнением
    return new Promise((resolve) => {
        debounceTimer = setTimeout(async () => {
            // Создаём новый контроллер
            abortController = new AbortController();

            const { prev, next } = neighbours(slug);
            let html;
            try {
                const params = new URLSearchParams({ slug });
                if (prev) params.set("prev", prev);
                if (next) params.set("next", next);
                const url = `/hearthstone/card?${params}`;
                console.info("[modal] GET", url);

                const response = await fetch(url, { signal: abortController.signal });
                console.info("[modal] ответ", response.status);

                if (!response.ok) throw new Error(`HTTP ${response.status}`);
                html = await response.text();
            } catch (error) {
                if (error.name === 'AbortError') {
                    console.info("[modal] запрос отменён");
                    resolve();
                    return;
                }
                console.error(error);
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
        console.info("[modal] клик по карте", target.dataset);
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