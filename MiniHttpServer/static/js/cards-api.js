// Номер последнего запроса: ответ более раннего запроса, пришедший позже,
// не должен затирать результат более нового (иначе кажется, что фильтр "не применился").
let latest = 0;

export async function loadCards(filters = {}) {
    const container = document.getElementById("card-grids");
    const info = document.getElementById("search-results__info");

    const body = new URLSearchParams();
    for (const [key, value] of Object.entries(filters)) {
        for (const item of [].concat(value)) {
            if (item !== undefined && item !== null && item !== "") body.append(key, item);
        }
    }

    const id = ++latest;
    console.info("POST /hearthstone/cards", body.toString());
    container.classList.add("is-loading");

    try {
        const response = await fetch("/hearthstone/cards", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
            body: body.toString()
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        const html = await response.text();
        if (id !== latest) return;

        const page = new DOMParser().parseFromString(html, "text/html");
        const count = page.getElementById("search-results__info");
        count?.remove();

        container.innerHTML = page.body.innerHTML.trim()
            ? page.body.innerHTML
            : '<p class="card-grid__empty">Карты не найдены.</p>';
        if (count && info) info.textContent = count.textContent.trim();
    } catch (error) {
        console.error(error);
        if (id === latest) container.innerHTML = '<p class="card-grid__error">Не удалось загрузить карты.</p>';
    } finally {
        if (id === latest) container.classList.remove("is-loading");
    }
}
