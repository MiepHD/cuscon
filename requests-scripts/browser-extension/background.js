const HOST_NAME = "com.froxot.requests.scripts";
let activePort = null;
let isProcessing = false; // Sperre gegen mehrfaches Ausführen

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  // NUR ausführen, wenn die Seite komplett geladen ist UND aktuell kein Prozess läuft
  if (changeInfo.status === "complete" && tab.url && tab.url.includes("play.google.com/console")) {
    if (isProcessing) {
      console.log("Verarbeitung läuft bereits, ignoriere onUpdated-Event.");
      return;
    }
    console.log("Zielseite erkannt:", tab.url);
    connectToNativeHost(tabId);
  }
});
function connectToNativeHost(tabId) {
  if (isProcessing) return;
  isProcessing = true;

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

      try {
        // 1. Versuche den aktiven Tab zu finden
        const [activeTab] = await chrome.tabs.query({ active: true, currentWindow: true });
        
        // 2. Nutze den aktiven Tab ODER die übergebene tabId als Fallback
        const targetTabId = (activeTab && activeTab.id) ? activeTab.id : tabId;

        if (!targetTabId) {
          throw new Error("Keine gültige Tab-ID ermittelbar.");
        }

        console.log(`Führe Script auf Tab ID ${targetTabId} aus...`);

        const results = await chrome.scripting.executeScript({
          target: { tabId: targetTabId },
          func: processOrdersInDOM,
          args: [database]
        });

        if (results && results[0] && results[0].result) {
          const updatedDB = results[0].result;
          console.log("Ergebnis aus Tab empfangen, sende an Python...", updatedDB);
          const updatedBase64 = btoa(unescape(encodeURIComponent(JSON.stringify(updatedDB, null, 4))));
          activePort.postMessage({ action: "save_file", data: updatedBase64 });
        }
      } catch (err) {
        console.error("Fehler beim Ausführen von executeScript:", err);
      } finally {
        isProcessing = false;
      }

    } else if (response.action === "save") {
      console.log("Speichern erfolgreich bestätigt!");
      isProcessing = false;
    } else {
      console.error("Fehler von Python:", response.message);
      isProcessing = false;
    }
  });

  activePort.onDisconnect.addListener(() => {
    if (chrome.runtime.lastError) {
      console.error("Verbindungsfehler:", chrome.runtime.lastError.message);
    }
    activePort = null;
    isProcessing = false;
  });

  activePort.postMessage({ action: "connect" });
}

/**
 * Läuft exklusiv EINMAL im Tab-Kontext
 */
async function processOrdersInDOM(database) {
  console.log("[DOM-Script] Gestartet mit Daten:", database);

  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  function isTableLoading() {
    return document.querySelector("mat-spinner, [role='progressbar']") !== null;
  }

  function isOrderNotFoundInDOM() {
    const placeholder = document.querySelector(".particle-table-placeholder.particle-table-last-row");
    return placeholder !== null;
  }

  // Versucht Daten direkt aus der aktuell sichtbaren Tabelle zu lesen
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

      // Prüfen, ob für diese Zeile der Text in der Produktspalte schon gerendert ist
      const productCell = products[foundIndex];
      const productText = productCell ? productCell.innerText.trim() : "";

      if (!productText) {
        return null; // Noch nicht fertig gerendert!
      }

      const isPaid = checkmarks[foundIndex] ? checkmarks[foundIndex].innerText.includes("check") : false;
      
      let parsedTotalAvailable = 0;
      const match = productText.match(/\d+/);
      if (match) {
        parsedTotalAvailable = parseInt(match[0], 10);
      }

      return {
        paid: isPaid,
        totalavailable: parsedTotalAvailable
      };
    }
    return null;
  }

  // Liest sofort alle derzeit gerenderten Zeilen in den Cache ein
  function cacheFirst25Orders() {
    const initialCache = {};
    const orderElements = document.querySelectorAll("text-field");
    const checkmarks = document.querySelectorAll("material-icon[clickabletooltiptarget][size] > i");
    const products = document.querySelectorAll("ess-cell[essfield=product_column] > console-table-text-cell > div > :nth-child(2) > span");

    const limit = Math.min(orderElements.length, 25);

    for (let index = 0; index < limit; index++) {
      const el = orderElements[index];
      const text = el ? el.innerText.trim() : "";
      
      const match = text.match(/GPA\.\d{4}-\d{4}-\d{4}-\d{5}/);
      if (match) {
        const orderId = match[0];
        const isPaid = checkmarks[index] ? checkmarks[index].innerText.includes("check") : false;
        
        let parsedTotalAvailable = null;
        if (products[index] && products[index].innerText.trim() !== "") {
          const numMatch = products[index].innerText.match(/\d+/);
          if (numMatch) parsedTotalAvailable = parseInt(numMatch[0], 10);
        }

        if (parsedTotalAvailable !== null) {
          initialCache[orderId] = {
            paid: isPaid,
            totalavailable: parsedTotalAvailable
          };
        }
      }
    }

    console.log(`[DOM-Script] ${Object.keys(initialCache).length} Orders gemerkt:`, initialCache);
    return initialCache;
  }

  async function clearSearchInput() {
    const searchInput = document.querySelector("material-input[leadingglyph] > label > input");
    if (searchInput) {
      searchInput.focus();
      searchInput.value = "";
      searchInput.dispatchEvent(new Event("input", { bubbles: true }));
      searchInput.dispatchEvent(new Event("change", { bubbles: true }));
      
      const enterEvent = new KeyboardEvent("keydown", { key: "Enter", code: "Enter", keyCode: 13, which: 13, bubbles: true });
      searchInput.dispatchEvent(enterEvent);
      await sleep(300);
    }
  }

  async function searchAndExtractData(orderId) {
    const searchInput = document.querySelector("material-input[leadingglyph] > label > input");
    if (!searchInput) {
      console.warn("[DOM-Script] Suchfeld nicht im DOM gefunden!");
      return null;
    }

    await clearSearchInput();

    searchInput.value = orderId;
    searchInput.dispatchEvent(new Event("input", { bubbles: true }));
    searchInput.dispatchEvent(new Event("change", { bubbles: true }));

    await sleep(100);

    const eventOptions = { key: "Enter", code: "Enter", keyCode: 13, which: 13, bubbles: true, cancelable: true };
    searchInput.dispatchEvent(new KeyboardEvent("keydown", eventOptions));
    searchInput.dispatchEvent(new KeyboardEvent("keypress", eventOptions));
    searchInput.dispatchEvent(new KeyboardEvent("keyup", eventOptions));

    console.log(`[DOM-Script] Suche nach ${orderId} gestartet. Prüfe alle 500ms...`);

    // Intervall-Prüfung alle 500ms (maximal 20 Durchläufe = 10 Sek Timeout)
    const maxTries = 20; 
    for (let i = 0; i < maxTries; i++) {
      await sleep(500);

      if (isTableLoading()) {
        continue;
      }

      const extracted = tryExtractCurrentPageData(orderId);
      if (extracted) {
        console.log(`[DOM-Script] Treffer für ${orderId} nach ${(i + 1) * 500}ms!`);
        return extracted;
      }

      if (isOrderNotFoundInDOM()) {
        console.warn(`[DOM-Script] Order ${orderId} nicht gefunden.`);
        return null;
      }
    }

    return null;
  }

  // --- HAUPTABLAUF ---

  console.log("[DOM-Script] Prüfe alle 500ms auf geladene Tabellendaten...");

  // Intervall-Prüfung beim Start: Alle 500ms schauen, ob der Text gerendert ist
  const maxInitialWait = 30; // Max 15 Sekunden Notfall-Limit
  for (let i = 0; i < maxInitialWait; i++) {
    const products = document.querySelectorAll("ess-cell[essfield=product_column] > console-table-text-cell > div > :nth-child(2) > span");
    const hasText = products.length > 0 && products[0].innerText.trim().length > 0;

    // Sobald Daten vorhanden sind, SOFORT ausbrechen
    if (hasText && !isTableLoading()) {
      console.log(`[DOM-Script] Tabelle bereit nach ${(i) * 500}ms! Starte Auswertung...`);
      break;
    }

    await sleep(500);
  }

  // Cache füllen mit den ersten 25 Datensätzen
  const cachedOrders = cacheFirst25Orders();
  const orders = database.orders || database;

  for (const orderId in orders) {
    let orderData = orders[orderId];

    if (!orderData || typeof orderData !== "object") {
      orders[orderId] = {
        paid: null,
        requested: typeof orderData === "number" ? orderData : 0,
        totalavailable: null
      };
      orderData = orders[orderId];
    }

    const needsPaid = orderData.paid === null || orderData.paid === undefined;
    const needsTotal = orderData.totalavailable === null || orderData.totalavailable === undefined;

    if (needsPaid || needsTotal) {
      let extracted = null;

      // 1. Blick in den Cache
      if (cachedOrders[orderId]) {
        console.log(`[DOM-Script] Order ${orderId} aus initialem Cache übernommen.`);
        extracted = cachedOrders[orderId];
      } else {
        // 2. Suche ausführen
        console.log(`[DOM-Script] Nicht im Cache. Starte Suche nach ${orderId}...`);
        extracted = await searchAndExtractData(orderId);
      }

      if (extracted) {
        orderData.paid = extracted.paid;
        orderData.totalavailable = extracted.totalavailable;
        console.log(`[DOM-Script] Aktualisiert (${orderId}):`, orderData);
      } else {
        console.warn(`[DOM-Script] Keine Daten ermittelbar für ${orderId}. Setze Fallback.`);
        orderData.paid = orderData.paid ?? false;
        orderData.totalavailable = orderData.totalavailable ?? 0;
      }
    }
  }

  await clearSearchInput();
  console.log("[DOM-Script] Fertig! Gesamtergebnis:", database);
  return database;
}