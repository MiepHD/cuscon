const HOST_NAME = "com.froxot.requests.scripts";
let activePort = null;

// Reagiert auf alle Änderungen an Tabs
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === "complete" && tab.url && tab.url.includes("play.google.com")) {
    console.log("Zielseite erkannt:", tab.url);
    connectToNativeHost();
  }
});

function connectToNativeHost() {
  // Verhindert doppelte Verbindungen
  if (activePort) {
    console.log("Sende Anfrage über bestehende Verbindung...");
    activePort.postMessage({ action: "get_file" });
    return;
  }

  console.log("Verbinde mit Native Messaging Host...");
  activePort = chrome.runtime.connectNative(HOST_NAME);
  console.log(activePort);

  // Nachrichten vom Python-Skript empfangen
  activePort.onMessage.addListener((response) => {
    if (response.status === "success") {
      console.log("Datei empfangen:", response.filename);

      const binaryData = atob(response.data);
      console.log(`Dateigröße: ${binaryData.length} Bytes`);
    } else {
      console.error("Fehler von Python:", response.message);
    }
  });

  // Verbindungsabbruch/Fehler abfangen
  activePort.onDisconnect.addListener(() => {
    if (chrome.runtime.lastError) {
      console.error("Verbindungsfehler:", chrome.runtime.lastError.message);
    } else {
      console.log("Verbindung zum Native Host sauber getrennt.");
    }
    activePort = null; // Reset des Ports
  });

  // Initialen Handshake/Anfrage senden
  activePort.postMessage({ action: "connect" });
}


document.querySelector("material-input[leadingglyph] > label > input")
document.querySelectorAll("text-field")
document.querySelectorAll("material-icon[clickabletooltiptarget][size]")
document.querySelectorAll("material-icon[clickabletooltiptarget][size] > i")
document.querySelectorAll("ess-cell[essfield=product_column] > console-table-text-cell > div > :nth-child(2) > span")