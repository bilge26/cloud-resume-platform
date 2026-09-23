const visitorCount = document.getElementById("visitor-count");

const API_URL =
    "https://sgtb0uy359.execute-api.eu-central-1.amazonaws.com/visitors";

async function updateVisitorCount() {
    try {
        const response = await fetch(API_URL);

        if (!response.ok) {
            throw new Error(`HTTP error: ${response.status}`);
        }

        const data = await response.json();

        visitorCount.textContent = data.count;
    } catch (error) {
        console.error("Failed to load visitor count:", error);
        visitorCount.textContent = "Unavailable";
    }
}

updateVisitorCount();