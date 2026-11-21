import "./dropdowns.js";
import "./modal.js";
import { initCardsFilters } from "./cards-filters.js";

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initCardsFilters);
} else {
    initCardsFilters();
}
