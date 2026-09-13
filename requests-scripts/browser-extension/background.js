const HOST_NAME = "com.froxot.requests.scripts";
let activePort = null;

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === "complete" && tab.url && tab.url.includes("play.google.com")) {
    console.log("Zielseite erkannt:", tab.url);
    connectToNativeHost(tabId);
  }
});

function connectToNativeHost(tabId) {
  if (activePort) {
    activePort.postMessage({ action: "get_file" });
    return;
  }

  activePort = chrome.runtime.connectNative(HOST_NAME);

  activePort.onMessage.addListener(async (response) => {
    if (response.status === "success" && response.data) {
      console.log("JSON empfangen. Starte Verarbeitung im Tab...");
      
      const jsonString = decodeURIComponent(escape(atob(response.data)));
      let database = JSON.parse(jsonString);

      // Führe die DOM-Suchen und Daten-Verarbeitung im Kontext der Seite aus
      chrome.scripting.executeScript({
        target: { tabId: tabId },
        func: processOrdersInDOM,
        args: [database]
      }, (results) => {
        if (results && results[0] && results[0].result) {
          const updatedDB = results[0].result;
          
          // Aktualisiertes JSON zurück an den Python Native Host senden zum Speichern
          const updatedBase64 = btoa(unescape(encodeURIComponent(JSON.stringify(updatedDB, null, 4))));
          activePort.postMessage({ action: "save_file", data: updatedBase64 });
        }
      });

    } else if (response.action === "save") {
      console.log("Speichern erfolgreich bestätigt!");
    } else {
      console.error("Fehler von Python:", response.message);
    }
  });

  activePort.onDisconnect.addListener(() => {
    if (chrome.runtime.lastError) {
      console.error("Verbindungsfehler:", chrome.runtime.lastError.message);
    }
    activePort = null;
  });

  activePort.postMessage({ action: "connect" });
}

/**
 * Diese Funktion läuft direkt im Tab (DOM Context)
 */
async function processOrdersInDOM(database) {
  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  // Hilfsfunktion: Versucht eine Order ID auf der aktuellen Seite zu lesen
  function tryExtractCurrentPageData(targetOrderId) {
    const orderElements = document.querySelectorAll("text-field");
    let foundIndex = -1;

    orderElements.forEach((el, index) => {
      if (el.innerText.trim().includes(targetOrderId)) {
        foundIndex = index;
      }
    });

    if (foundIndex !== -1) {
      const checkmarks = document.querySelectorAll("material-icon[clickabletooltiptarget][size] > i");
      const products = document.querySelectorAll("ess-cell[essfield=product_column] > console-table-text-cell > div > :nth-child(2) > span");

      // Bsp.-Werte aus den gefundener Elementen ziehen
      const isPaid = checkmarks[foundIndex] ? checkmarks[foundIndex].innerText.includes("check") : false;
      const productText = products[foundIndex] ? products[foundIndex].innerText : "";
      
      // Nutze die aus dem DOM extrahierten Werte (Beispielwerte adaptieren)
      return {
        paid: isPaid,
        requested: 1, // Beispielwerte aus Elementen parsen
        totalavailable: 1
      };
    }
    return null;
  }

  // Hilfsfunktion: Nutzt die Suchleiste auf der Seite
  async function searchAndExtractData(orderId) {
    const searchInput = document.querySelector("material-input[leadingglyph] > label > input");
    if (!searchInput) return null;

    searchInput.value = orderId;
    searchInput.dispatchEvent(new Event("input", { bubbles: true }));
    searchInput.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter", keyCode: 13, bubbles: true }));

    // Warten bis Ergebnisse geladen werden
    await sleep(2000);

    return tryExtractCurrentPageData(orderId);
  }

  // Rekursive/Tiefe Durchmusterung aller Keys im JSON, die auf null stehen
  async function traverseAndFix(obj) {
    for (const key in obj) {
      if (obj[key] !== null && typeof obj[key] === "object") {
        await traverseAndFix(obj[key]);
      } else if (obj[key] === null && key.startsWith("GPA.")) {
        const orderId = key;
        console.log(`Verarbeite null-Eintrag für: ${orderId}`);

        // 1. Erst auf aktueller Seite prüfen
        let extractedData = tryExtractCurrentPageData(orderId);

        // 2. Falls nicht gefunden, Suchleiste benutzen
        if (!extractedData) {
          console.log(`Nicht direkt im DOM gefunden. Starte Suche für ${orderId}...`);
          extractedData = await searchAndExtractData(orderId);
        }

        // 3. Ersetze null durch das ermittelte Objekt
        if (extractedData) {
          obj[orderId] = extractedData;
          console.log(`Erfolgreich ersetzt für ${orderId}:`, extractedData);
        } else {
          console.warn(`Keine Daten im DOM/Suche gefunden für ${orderId}`);
        }
      }
    }
  }

  await traverseAndFix(database);
  return database;
}
