import { loadCards } from "./cards-api.js";

// Значения по умолчанию. Остальные категории по умолчанию = "any" (ключа в state нет).
const DEFAULTS = { set: "standard", sort: "mana-asc", view: "cards", group_by_class: "true" };
// Эти категории не показываем плашками над результатами.
const HIDDEN_TAGS = new Set(["sort", "view", "group_by_class"]);

// ЕДИНСТВЕННЫЙ источник правды: по одному значению на категорию.
// Выбор нового значения просто перезаписывает старое, а внешний вид и запрос строятся из state.
const state = { ...DEFAULTS };
const costs = new Set(); // мана — множественный выбор

const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];

const labelOf = button => $(".filter-list__button__text", button)?.textContent.trim() || button.dataset.value;
const byValue = (filter, value) => $$(`button[data-filter="${filter}"]`).find(b => b.dataset.value === value);

export function initCardsFilters() {
    const searchInput = $("#search__hero");
    const groupCheckbox = $(".sort-group__checkbox");
    const tags = $("#selected-filters");

    // запоминаем исходный заголовок каждой кнопки-шторки ("Все классы", "Атака"...)
    $$(".filter-list__container").forEach(container => {
        const trigger = container.previousElementSibling;
        const text = trigger && $(".filter-button__text", trigger);
        if (text) trigger.dataset.heading = text.textContent.trim();
    });

    // ---------- состояние -> внешний вид ----------
    function syncButtons() {
        $$("button[data-filter][data-value]").forEach(button => {
            const { filter, value } = button.dataset;
            const active = filter === "cost" ? costs.has(value) : (state[filter] ?? "any") === value;
            button.classList.toggle("is-active", active);
        });
    }

    function syncTriggers() {
        $$(".filter-list__container").forEach(container => {
            const trigger = container.previousElementSibling;
            if (!trigger) return;

            const active = $(".filter-list__button.is-active", container);
            const text = $(".filter-button__text", trigger);
            if (text) {
                text.textContent = active && active.dataset.value !== "any"
                    ? labelOf(active)
                    : (trigger.dataset.heading ?? text.textContent);
            }

            const triggerIcon = $(".filter-button__icon, .filter-class-button__icon", trigger);
            const optionIcon = active && $(".filter-list__button__icon", active);
            if (triggerIcon && optionIcon) triggerIcon.innerHTML = optionIcon.innerHTML;
        });
    }

    function chip(className, label, onClick) {
        const element = document.createElement("button");
        element.type = "button";
        element.className = className;
        element.innerHTML = `<span class="selected-filter__label"></span><span class="selected-filter__remove">×</span>`;
        element.firstChild.textContent = label;
        element.addEventListener("click", onClick);
        return element;
    }

    function renderTags() {
        const items = [];

        for (const [filter, value] of Object.entries(state)) {
            if (HIDDEN_TAGS.has(filter) || value === DEFAULTS[filter]) continue;
            const button = byValue(filter, value);
            items.push(chip("selected-filter", button ? labelOf(button) : value, () => {
                resetFilter(filter);
                update();
            }));
        }

        if (costs.size) {
            items.push(chip("selected-filter", `Мана: ${sortedCosts().join(", ")}`, () => {
                costs.clear();
                update();
            }));
        }

        if (items.length) {
            const clear = chip("selected-filters__clear", "⟳ Удалить все", () => {
                clearAll();
                update();
            });
            clear.querySelector(".selected-filter__remove")?.remove();
            items.push(clear);
        }

        tags?.replaceChildren(...items);
    }

    // ---------- действия ----------
    const sortedCosts = () => [...costs].sort((a, b) => parseInt(a) - parseInt(b));

    function resetFilter(filter) {
        if (filter in DEFAULTS) state[filter] = DEFAULTS[filter];
        else delete state[filter];
    }

    function clearAll() {
        Object.keys(state).forEach(filter => {
            if (!["view", "group_by_class"].includes(filter)) resetFilter(filter);
        });
        state.set = DEFAULTS.set;
        state.sort = DEFAULTS.sort;
        costs.clear();
        if (searchInput) searchInput.value = "";
    }

    function buildPayload() {
        const payload = { ...state };
        if (costs.size) payload.cost = sortedCosts().join(",");
        const q = searchInput?.value.trim();
        if (q) payload.q = q;
        return payload;
    }

    function update() {
        syncButtons();
        syncTriggers();
        renderTags();
        loadCards(buildPayload());
    }

    // ---------- события ----------
    // Если CSS прячет шторку при потере фокуса кнопкой-триггером, она исчезала бы
    // на mousedown, ещё до click. Не даём фокусу уйти с триггера.
    document.addEventListener("mousedown", event => {
        if (event.target.closest(".filter-list__container")) event.preventDefault();
    });

    document.addEventListener("click", event => {
        const button = event.target.closest("button[data-filter][data-value]");
        if (!button) return;

        const { filter, value } = button.dataset;

        if (filter === "cost") {
            if (!costs.delete(value)) costs.add(value);          // вкл/выкл
        } else if (value === "any") {
            delete state[filter];                                  // "Все ..." = фильтр снят
        } else {
            state[filter] = value;                                 // новое значение ЗАМЕНЯЕТ прежнее
        }

        // закрываем шторку, из которой выбрали
        const trigger = button.closest(".filter-list__container")?.previousElementSibling;
        trigger?.classList.remove("is-open");
        trigger?.blur();

        update();
    });

    groupCheckbox?.addEventListener("change", () => {
        state.group_by_class = String(groupCheckbox.checked);
        update();
    });

    const searchForm = $(".search-hero__form");
    searchForm?.addEventListener("submit", event => {
        event.preventDefault();
        update();
    });
    searchInput?.addEventListener("search", update); // крестик очистки в input[type=search]

    if (groupCheckbox) state.group_by_class = String(groupCheckbox.checked);
    update();
}