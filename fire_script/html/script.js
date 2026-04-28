let inventoryData = {
    wood: { count: 0, image: "" },
    rock: { count: 0, image: "" }
};

let selected = {
    wood: 0,
    rock: 0
};

// Merr resource name në mënyrë të sigurt
const resourceName = (typeof GetParentResourceName === "function")
    ? GetParentResourceName()
    : "fire_script"; // fallback nëse nuk ekziston

// 1. Degjuesi i mesazheve nga Client.lua
window.addEventListener("message", function(event) {
    if (event.data.action === "open") {
        inventoryData = event.data.items;

        document.getElementById("ui").classList.remove("hidden");

        document.getElementById("woodImg").src = inventoryData.wood.image;
        document.getElementById("rockImg").src = inventoryData.rock.image;

        selected.wood = 0;
        selected.rock = 0;
        
        updateUI();
    }
});

// 2. Funksioni kryesor që përditëson gjithçka në ekran
function updateUI() {
    document.getElementById("woodCount").innerText = selected.wood + " / " + inventoryData.wood.count;
    document.getElementById("rockCount").innerText = selected.rock + " / " + inventoryData.rock.count;

    let totalNeeded = 10; 
    let currentTotal = selected.wood + selected.rock;
    let percentage = Math.min(Math.floor((currentTotal / totalNeeded) * 100), 100);

    let offset = 283 - (percentage / 100) * 283;
    document.getElementById("progress").style.strokeDashoffset = offset;
    document.getElementById("percentageText").innerText = percentage + "%";

    let infoText = document.getElementById("info-text");
    let infoBox = document.querySelector(".info-box");
    let craftBtn = document.getElementById("craftBtn");

    if (selected.wood >= 7 && selected.rock >= 4) {
        infoText.innerHTML = "✅ Materialet janë gati!";
        infoBox.style.borderLeftColor = "#4CAF50"; 
        infoText.style.color = "#4CAF50";
        craftBtn.classList.remove("disabled");
        craftBtn.disabled = false;
    } else {
        let missingWood = Math.max(0, 7 - selected.wood);
        let missingRock = Math.max(0, 4 - selected.rock);
        infoText.innerHTML = `Mungojnë: ${missingWood} Dru & ${missingRock} Gurë`;
        infoBox.style.borderLeftColor = "#ffa500";
        infoText.style.color = "#ffa500";
        craftBtn.classList.add("disabled");
        craftBtn.disabled = true;
    }
}

// 3. Shtimi i materialeve
function add(type) {
    if (selected[type] < inventoryData[type].count) {
        selected[type]++;
        updateUI();
    }
}

// 4. Heqja e materialeve
function remove(type) {
    if (selected[type] > 0) {
        selected[type]--;
        updateUI();
    }
}

// 5. Dërgimi i të dhënave te Serveri për spawn
function startFire() {
    fetch(`https://${resourceName}/startFire`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(selected)
    }).catch(err => {
        console.error("NUI fetch error (startFire):", err);
    });

    closeUI();
}

// 6. Mbyllja e UI
function closeUI() {
    document.getElementById("ui").classList.add("hidden");

    fetch(`https://${resourceName}/close`, {
        method: 'POST'
    }).catch(err => {
        console.error("NUI fetch error (close):", err);
    });
}