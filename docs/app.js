(() => {
  "use strict";

  const STORAGE_KEYS = {
    settings: "crisis-settings",
    snapshot: "crisis-snapshot",
    snapshotAt: "crisis-snapshot-at",
    fxRate: "crisis-fx-rate",
    stooqCache: "crisis-stooq-cache",
    newsCache: "crisis-news-cache",
    lastNotified: "crisis-last-notified"
  };

  const THRESHOLD_PROFILES = {
    standard: { id: "standard", label: "Standard", highRisk: 5.0, governanceCutoff: -0.5, recessionCutoff: 0.0 },
    sensitive: { id: "sensitive", label: "Sensitiv", highRisk: 4.5, governanceCutoff: -0.3, recessionCutoff: 0.5 },
    conservative: { id: "conservative", label: "Konservativ", highRisk: 5.5, governanceCutoff: -0.7, recessionCutoff: -0.5 }
  };

  const WATCHLISTS = {
    geopolitical: [
      { code: "UKR", name: "Ukraine" },
      { code: "ISR", name: "Israel" },
      { code: "TWN", name: "Taiwan" },
      { code: "ZAF", name: "South Africa" },
      { code: "DEU", name: "Germany" }
    ],
    financial: [
      { code: "DEU", name: "Germany" },
      { code: "USA", name: "United States" },
      { code: "GBR", name: "United Kingdom" },
      { code: "JPN", name: "Japan" },
      { code: "CHN", name: "China" }
    ]
  };

  const DEFAULT_SETTINGS = {
    currency: "EUR",
    thresholdProfile: "standard",
    watchlistGeo: WATCHLISTS.geopolitical.map((item) => item.code),
    watchlistFinancial: WATCHLISTS.financial.map((item) => item.code),
    newsApiKey: ""
  };

  const MACRO_KINDS = [
    {
      id: "INFLATION",
      indicatorCode: "FP.CPI.TOTL.ZG",
      unit: "%",
      title: "Inflation",
      explanation: "Jaehrliche Verbraucherpreisinflation laut Weltbank"
    },
    {
      id: "GROWTH",
      indicatorCode: "NY.GDP.MKTP.KD.ZG",
      unit: "%",
      title: "Wachstum",
      explanation: "Reales BIP-Wachstum"
    },
    {
      id: "DEFENSE",
      indicatorCode: "MS.MIL.XPND.GD.ZS",
      unit: "% BIP",
      title: "Verteidigung",
      explanation: "Militaerausgaben im Verhaeltnis zum BIP"
    }
  ];

  const MACRO_KIND_MAP = new Map(MACRO_KINDS.map((kind) => [kind.id, kind]));

  const COLORS = {
    accent: "#e3b66a",
    strong: "#c6903a",
    info: "#86b7c6",
    muted: "#7a6f78",
    subtle: "#a59aa5"
  };

  const MACRO_COMPARISON_REGIONS = [
    { iso: "DEU", label: "DE", color: COLORS.accent, colorClass: "color-accent" },
    { iso: "USA", label: "US", color: COLORS.strong, colorClass: "color-strong" },
    { iso: "GBR", label: "UK", color: COLORS.info, colorClass: "color-info" },
    { iso: "ESP", label: "ES", color: COLORS.muted, colorClass: "color-muted" }
  ];

  const ASSET_GROUPS = [
    { id: "equities", label: "Aktienmaerkte" },
    { id: "real_estate", label: "Immobilienpreise" },
    { id: "metals", label: "Edelmetalle" }
  ];

  const COMPARISON_ASSETS = [
    { id: "EQUITY_DE", label: "Deutschland Aktien", group: "equities", instrument: "^dax", color: COLORS.accent },
    { id: "EQUITY_USA", label: "USA Aktien", group: "equities", instrument: "^spx", color: COLORS.strong },
    { id: "EQUITY_LON", label: "London Aktien", group: "equities", instrument: "^ftse", color: COLORS.info },
    { id: "REAL_ESTATE_DE", label: "Deutschland Immobilien", group: "real_estate", instrument: "iqq7.de", color: COLORS.accent },
    { id: "REAL_ESTATE_ES", label: "Spanien Immobilien", group: "real_estate", instrument: "iqq7.de", color: COLORS.strong },
    { id: "REAL_ESTATE_FR", label: "Frankreich Immobilien", group: "real_estate", instrument: "iqq7.de", color: COLORS.info },
    { id: "REAL_ESTATE_LON", label: "London Immobilien", group: "real_estate", instrument: "vnq.us", color: COLORS.muted },
    { id: "GOLD", label: "Gold", group: "metals", instrument: "xauusd", color: COLORS.strong },
    { id: "SILVER", label: "Silber", group: "metals", instrument: "xagusd", color: COLORS.info }
  ];

  const COMPARISON_ASSET_MAP = new Map(COMPARISON_ASSETS.map((asset) => [asset.id, asset]));

  const BENNER_CONFIG = {
    initialPanicYear: 1700,
    intervals: [18, 20, 16],
    rangeStart: 1780,
    rangeEnd: 2150,
    goodSpan: 7,
    hardSpan: 11
  };

  const BENNER_PHASES = {
    panic: {
      id: "panic",
      title: "Panikjahr",
      subtitle: "Extremer Verkaufsdruck - Phase A",
      guidance: "Historisch folgten auf diese Jahre heftige Markteinbrueche. Liquiditaet sichern und Risiko begrenzen.",
      metalTrendMultiplier: 0.08
    },
    good: {
      id: "good",
      title: "Good Times",
      subtitle: "Hohe Preise - Phase B (Verkaeufe bevorzugt)",
      guidance: "Ueberdurchschnittliche Bewertungen. Gewinne sichern und Exposure reduzieren.",
      metalTrendMultiplier: 0.02
    },
    hard: {
      id: "hard",
      title: "Hard Times",
      subtitle: "Niedrige Preise - Phase C (Akkumulation)",
      guidance: "Marktpreise gelten als guenstig. Positionsaufbau und Sparplaene bieten sich an.",
      metalTrendMultiplier: 0.03
    }
  };

  const TEXT = {
    heroTitle: "Vermoegenssicherung",
    heroSubtitle: "Aktuelle Prognose",
    heroLabel: "Prognose",
    heroHint: "Vorsicht empfohlen - Absicherung priorisieren.",
    metalsFocusTitle: "Edelmetalle im Fokus",
    metalsFocusSubtitle: "Gold & Silber im aktuellen Marktumfeld",
    macroTitle: "Makro-Lage",
    macroSubtitle: "Inflation, Wechsel & Wachstum je Region",
    whyMetalsTitle: "Warum Edelmetalle und Struktur",
    whyMetalsBullets: [
      "Physischer Wert, unabhaengig von Waehrungen",
      "Schutz vor Inflation und Kaufkraftverlust",
      "Stabilitaet in Kriegen und Wirtschaftskrisen",
      "Strukturierter Vermoegensschutz durch planbare Allokation",
      "Sichere Lagerung im Zollfreilager ausserhalb des Bankensystems"
    ],
    comparisonSectionTitle: "Asset-Klassen Vergleich",
    comparisonSectionSubtitle: "Historisch & Prognose 2025-2050",
    comparisonChartTitle: "Wertentwicklung",
    comparisonChartSubtitle: "Tippen Sie auf den Chart um Details zu sehen",
    comparisonPerformanceTitle: "Performance Uebersicht",
    comparisonPerformanceSubtitle: "Historisch und Prognose",
    comparisonNoData: "Keine Marktdaten verfuegbar.",
    comparisonLoading: "Lade Marktdaten...",
    comparisonMacroTitle: "Makro-Vergleich",
    comparisonMacroSubtitle: "Regionale Trends nebeneinander",
    comparisonMacroLoading: "Lade Makro-Daten.",
    comparisonMacroNoData: "Keine Makro-Daten verfuegbar.",
    comparisonScenarioTitle: "Szenario-Labor",
    comparisonScenarioSubtitle: "Inflation, Wachstum und Verteidigung justieren",
    scenarioInflation: "Inflation (%)",
    scenarioGrowth: "Wachstum (%)",
    scenarioDefense: "Verteidigung (% BIP)",
    scenarioEquities: "Aktien",
    scenarioRealEstate: "Immobilien",
    scenarioMetals: "Edelmetalle",
    portfolioTitle: "Portfolio-Resilienz",
    portfolioSubtitle: "Mix aus Aktien, Immobilien und Edelmetallen",
    metalsSelectorTitle: "Edelmetall auswaehlen",
    metalsProjectionTitle: "Prognose fuer 3 Jahre",
    metalsTrendTitle: "Historisch & Prognose bis 2050",
    metalsTrendSubtitle: "Indexentwicklung %s",
    metalsTrendLoading: "Lade Marktdaten...",
    metalsResilienceTitle: "Resilienz in Krisen",
    metalsResilienceSubtitle: "%s in unterschiedlichen Szenarien",
    metalsScenarioInflation: "Inflation",
    metalsScenarioWars: "Kriege",
    metalsScenarioWarsDetail: "Geopolitische Spannungen erhoehen die Nachfrage nach sicheren Haefen.",
    metalsScenarioRecession: "Wirtschaftskrisen",
    metalsScenarioRecessionDetail: "In Rezessionen dient %s als Liquiditaetsreserve.",
    metalsBadgeProtection: "Schutz",
    metalsBadgeShield: "Absicherung",
    metalsBadgeDiversification: "Diversifikation",
    crisisOverviewTitle: "Krisenlage",
    crisisOverviewSubtitle: "Aktuelle Hinweise aus externen Quellen",
    crisisOverviewEmpty: "Keine aktuellen Hinweise.",
    crisisFeedTitle: "Krisen-Feed",
    crisisFeedSubtitle: "Meldungen aus NewsAPI und World Bank",
    crisisFeedEmpty: "Keine aktuellen Krisenmeldungen.",
    crisisCategoryFinancial: "Finanzen",
    crisisCategoryGeopolitical: "Geopolitik",
    crisisBadgeInfo: "Info",
    crisisBadgeModerate: "Moderat",
    crisisBadgeHigh: "Hoch",
    crisisDetailTitle: "Krisen-Details",
    crisisDetailMissing: "Ereignis nicht gefunden.",
    crisisDetailTimeline: "Zeitachse",
    crisisDetailOpenSource: "Quelle oeffnen",
    consultationExpectationsTitle: "Was Sie erwartet",
    consultationExpectations: [
      "Kostenlose Erstberatung durch Edelmetall-Experten",
      "Individuelle Vermoegensstrukturierung",
      "Informationen zur Zollfreilager-Lagerung",
      "Steuerliche Aspekte und rechtliche Absicherung"
    ],
    consultationMoreInfoTitle: "Weitere Informationen",
    consultationInfo1Title: "Zollfreilager-Lagerung",
    consultationInfo1Text: "Physische Trennung vom Bankensystem, Versicherung und 24/7 Ueberwachung fuer maximale Sicherheit und Flexibilitaet.",
    consultationInfo2Title: "Wert - Struktur gewinnt",
    consultationInfo2Text: "Klare Allokation in Edelmetalle schafft Stabilitaet in Inflation, Waehrungsreformen und Krisen.",
    consultationPrivacyNote:
      "Mit dem Absenden stimmen Sie zu, dass wir Ihre Anfrage gemaess Datenschutzerklaerung beantworten. Wir speichern keine Daten dauerhaft auf diesem Geraet.",
    consultationSuccessTitle: "Vielen Dank",
    consultationSuccessMessage: "Ihre Anfrage wurde gesendet. Wir melden uns zeitnah.",
    consultationFailureTitle: "Senden fehlgeschlagen",
    notificationsActive: "Aktiv",
    notificationsDenied: "Deaktiviert",
    notificationsUnknown: "Unbekannt",
    notificationsActiveDesc: "Sie erhalten Warnhinweise bei Prognose-Wechseln oder groesseren Krisen.",
    notificationsDeniedDesc: "Benachrichtigungen sind ausgeschaltet. Aktivieren Sie sie in den Browser-Einstellungen.",
    notificationsUnknownDesc: "Noch keine Berechtigung angefragt.",
    notificationsActionEnable: "Benachrichtigungen aktivieren",
    notificationsActionOpenSettings: "Browser-Einstellungen oeffnen",
    privacyIntro:
      "Wir verarbeiten Ihre Daten ausschliesslich auf dem Geraet oder ueber den Versand Ihrer Anfrage. Es gibt keine versteckten Tracker oder Cloud-Profile.",
    privacySections: [
      {
        title: "Verantwortliche Stelle",
        body: "VermoegensKompass (Vibecode GmbH) verarbeitet ausschliesslich die Daten, die Sie aktiv teilen."
      },
      {
        title: "Datenerhebung im Ueberblick",
        body: [
          "Markt- und Krisendaten stammen aus offen zugaenglichen APIs (World Bank, USGS, NOAA, GoldPrice.org) und werden nur lokal ausgewertet.",
          "Wir speichern keine personenbezogenen Daten auf unseren Servern."
        ]
      },
      {
        title: "Kontaktaufnahme",
        body:
          "Wenn Sie auf \"Beratung anfragen\" tippen, senden wir Ihre Nachricht an unser Beratungsteam. Der Versand erfolgt ueber eine gesicherte Verbindung; wir speichern dabei keine Kopie."
      },
      {
        title: "Benachrichtigungen",
        body:
          "Krisen-Benachrichtigungen werden ausschliesslich auf Ihrem Geraet verarbeitet. Sie koennen die Berechtigung jederzeit in den Browser-Einstellungen widerrufen."
      },
      {
        title: "Analytics & Tracking",
        body:
          "Kein Tracking, keine Drittanbieter-SDKs. Die App funktioniert vollstaendig offline mit den zuletzt synchronisierten Daten."
      },
      {
        title: "Ihre Rechte",
        body:
          "Sie koennen Auskunft, Berichtigung oder Loeschung Ihrer Kontaktaufnahme verlangen, indem Sie uns unter datenschutz@vermoegenskompass.de kontaktieren."
      }
    ]
  };

  const state = {
    settings: null,
    snapshot: null,
    lastSyncAt: null,
    lastError: null,
    fxRate: null,
    stooqCache: readJson(STORAGE_KEYS.stooqCache, {}),
    newsCache: readJson(STORAGE_KEYS.newsCache, null),
    bennerEntries: makeBennerEntries(),
    comparisonSeries: [],
    comparisonLoading: false,
    macroComparison: { kindId: "INFLATION", data: {}, loading: false },
    comparisonMode: "history",
    selectedAssets: new Set(["EQUITY_DE", "EQUITY_USA", "GOLD"]),
    selectedMetalId: null,
    selectedMacroRegion: "DE",
    scenario: { inflation: 2, growth: 1, defense: 2 },
    scenarioTouched: false,
    metalHistoryLoading: false,
    route: "overview",
    crisisDetailId: null
  };

  const elements = {};

  document.addEventListener("DOMContentLoaded", init);

  function init() {
    state.settings = loadSettings();
    state.snapshot = loadSnapshot() || makeSampleSnapshot();
    state.lastSyncAt = readJson(STORAGE_KEYS.snapshotAt, null);
    state.fxRate = readJson(STORAGE_KEYS.fxRate, null);
    state.selectedMetalId = state.snapshot.metals[0]?.id || null;
    state.scenario = seedScenarioFromSnapshot(state.snapshot);
    state.route = parseRoute(window.location.hash) || "overview";

    cacheElements();
    bindEvents();
    applySettingsToUI();
    setRoute(state.route, { skipHash: true });
    renderAll();
    updateSyncBanner();

    window.setTimeout(() => {
      document.body.classList.add("is-ready");
    }, 60);

    void syncData({ silent: true });

    window.setInterval(() => {
      void syncData({ silent: true });
    }, 15 * 60 * 1000);
  }

  function cacheElements() {
    elements.screens = $$(".screen");
    elements.navButtons = $$(".nav-item");
    elements.refreshButton = $("#refresh-button");
    elements.settingsButton = $("#settings-button");
    elements.settingsSheet = $("#settings-sheet");
    elements.privacyModal = $("#privacy-modal");
    elements.syncBanner = $("#sync-banner");
    elements.overviewHero = $("#overview-hero");
    elements.overviewMetals = $("#overview-metals");
    elements.overviewMacro = $("#overview-macro");
    elements.overviewWhyMetals = $("#overview-why-metals");
    elements.comparisonControls = $("#comparison-controls");
    elements.comparisonChart = $("#comparison-chart");
    elements.comparisonPerformance = $("#comparison-performance");
    elements.comparisonMacro = $("#comparison-macro");
    elements.comparisonScenario = $("#comparison-scenario");
    elements.metalsSelector = $("#metals-selector");
    elements.metalsPrice = $("#metals-price");
    elements.metalsProjection = $("#metals-projection");
    elements.metalsChart = $("#metals-chart");
    elements.metalsResilience = $("#metals-resilience");
    elements.metalsWhy = $("#metals-why-metals");
    elements.crisisSummary = $("#crisis-summary");
    elements.crisisFeed = $("#crisis-feed");
    elements.crisisDetailCard = $("#crisis-detail-card");
    elements.crisisBack = $("#crisis-back");
    elements.consultationForm = $("#consultation-form");
    elements.consultationInfo = $("#consultation-info");
    elements.consultationPrivacy = $("#consultation-privacy");
    elements.notificationStatus = $("#notification-status");
    elements.notificationDescription = $("#notification-description");
    elements.notificationAction = $("#notification-action");
    elements.newsApiKey = $("#news-api-key");
    elements.watchlistGeo = $("#watchlist-geo");
    elements.watchlistFinancial = $("#watchlist-financial");
    elements.privacyContent = $("#privacy-content");
    elements.toast = $("#toast");
    elements.toastContent = $("#toast-content");
  }

  function bindEvents() {
    elements.navButtons.forEach((button) => {
      button.addEventListener("click", () => setRoute(button.dataset.route));
    });

    $$("[data-route-target]").forEach((button) => {
      button.addEventListener("click", () => setRoute(button.dataset.routeTarget));
    });

    elements.refreshButton?.addEventListener("click", () => void syncData());
    elements.settingsButton?.addEventListener("click", openSettings);

    elements.settingsSheet?.addEventListener("click", (event) => {
      if (event.target === elements.settingsSheet) closeSettings();
    });

    $$("[data-close-sheet]").forEach((button) => {
      button.addEventListener("click", closeSettings);
    });

    $("#privacy-button")?.addEventListener("click", openPrivacy);
    elements.privacyModal?.addEventListener("click", (event) => {
      if (event.target === elements.privacyModal) closePrivacy();
    });

    $$("[data-close-privacy]").forEach((button) => {
      button.addEventListener("click", closePrivacy);
    });

    elements.crisisBack?.addEventListener("click", () => setRoute("crisis"));

    elements.consultationForm?.addEventListener("submit", handleConsultationSubmit);

    elements.settingsSheet?.addEventListener("click", (event) => {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;
      if (target.dataset.currency) {
        updateCurrency(target.dataset.currency);
      }
      if (target.dataset.threshold) {
        updateThresholdProfile(target.dataset.threshold);
      }
    });

    elements.watchlistGeo?.addEventListener("change", handleWatchlistChange);
    elements.watchlistFinancial?.addEventListener("change", handleWatchlistChange);

    elements.newsApiKey?.addEventListener("input", () => {
      state.settings.newsApiKey = elements.newsApiKey.value.trim();
      saveSettings();
    });

    elements.notificationAction?.addEventListener("click", handleNotificationAction);

    elements.overviewMacro?.addEventListener("click", (event) => {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;
      const region = target.dataset.macroRegion;
      if (region) {
        state.selectedMacroRegion = region;
        renderOverview();
      }
    });

    elements.comparisonControls?.addEventListener("click", (event) => {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;
      const mode = target.dataset.comparisonMode;
      if (mode) {
        state.comparisonMode = mode;
        renderComparison();
      }
      const assetId = target.dataset.assetId;
      if (assetId) {
        if (state.selectedAssets.has(assetId)) {
          state.selectedAssets.delete(assetId);
        } else {
          state.selectedAssets.add(assetId);
        }
        renderComparison();
      }
    });

    elements.comparisonMacro?.addEventListener("click", (event) => {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;
      const kindId = target.dataset.macroKind;
      if (kindId && kindId !== state.macroComparison.kindId) {
        state.macroComparison.kindId = kindId;
        void ensureMacroComparison();
        renderComparison();
      }
    });

    elements.comparisonScenario?.addEventListener("input", (event) => {
      const target = event.target;
      if (!(target instanceof HTMLInputElement)) return;
      if (target.type !== "range") return;
      const key = target.name;
      if (key === "inflation" || key === "growth" || key === "defense") {
        state.scenario[key] = Number.parseFloat(target.value);
        state.scenarioTouched = true;
        updateScenarioValues(elements.comparisonScenario, state.scenario);
      }
    });

    elements.metalsSelector?.addEventListener("click", (event) => {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;
      const metalId = target.dataset.metalId;
      if (metalId) {
        state.selectedMetalId = metalId;
        renderMetals();
        void ensureMetalHistory();
      }
    });

    elements.crisisFeed?.addEventListener("click", (event) => {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;
      const card = target.closest("[data-crisis-id]");
      if (!(card instanceof HTMLElement)) return;
      const crisisId = card.dataset.crisisId;
      if (crisisId) {
        state.crisisDetailId = crisisId;
        setRoute("crisis-detail");
      }
    });

    window.addEventListener("hashchange", () => {
      const route = parseRoute(window.location.hash);
      if (route) setRoute(route, { skipHash: true });
    });

    window.addEventListener("online", updateSyncBanner);
    window.addEventListener("offline", updateSyncBanner);

    document.addEventListener("keydown", (event) => {
      if (event.key !== "Escape") return;
      if (elements.settingsSheet && !elements.settingsSheet.hidden) closeSettings();
      if (elements.privacyModal && !elements.privacyModal.hidden) closePrivacy();
    });
  }

  function parseRoute(hash) {
    if (!hash) return null;
    const cleaned = hash.replace("#", "").trim();
    if (!cleaned) return null;
    const allowed = ["overview", "comparison", "metals", "crisis", "consultation", "crisis-detail"];
    return allowed.includes(cleaned) ? cleaned : null;
  }

  function setRoute(route, options = {}) {
    if (!route) return;
    if (route === "crisis-detail" && !state.crisisDetailId) {
      route = "crisis";
    }

    state.route = route;

    elements.screens.forEach((screen) => {
      const isActive = screen.dataset.route === route;
      screen.hidden = !isActive;
      screen.classList.toggle("is-active", isActive);
    });

    elements.navButtons.forEach((button) => {
      button.setAttribute("aria-current", button.dataset.route === route ? "page" : "false");
    });

    if (!options.skipHash) {
      window.location.hash = route;
    }

    if (route === "comparison") {
      void ensureComparisonSeries();
      void ensureMacroComparison();
    }

    if (route === "metals") {
      void ensureMetalHistory();
    }

    renderAll();

    const activeScreen = elements.screens.find((screen) => screen.dataset.route === route);
    if (activeScreen) {
      applyStagger(activeScreen);
    }
  }

  function applyStagger(screen) {
    const cards = Array.from(screen.querySelectorAll(".card"));
    cards.forEach((card, index) => {
      const step = (index % 5) + 1;
      card.classList.remove("stagger-1", "stagger-2", "stagger-3", "stagger-4", "stagger-5");
      card.classList.add(`stagger-${step}`);
    });
  }

  function openSettings() {
    if (!elements.settingsSheet) return;
    closePrivacy();
    elements.settingsSheet.hidden = false;
    document.body.classList.add("modal-open");
    const firstButton = elements.settingsSheet.querySelector("button, input");
    if (firstButton instanceof HTMLElement) {
      firstButton.focus();
    }
  }

  function closeSettings() {
    if (!elements.settingsSheet) return;
    elements.settingsSheet.hidden = true;
    document.body.classList.remove("modal-open");
  }

  function openPrivacy() {
    if (!elements.privacyModal) return;
    closeSettings();
    elements.privacyModal.hidden = false;
    document.body.classList.add("modal-open");
    const firstButton = elements.privacyModal.querySelector("button");
    if (firstButton instanceof HTMLElement) {
      firstButton.focus();
    }
  }

  function closePrivacy() {
    if (!elements.privacyModal) return;
    elements.privacyModal.hidden = true;
    document.body.classList.remove("modal-open");
  }

  function renderAll() {
    renderOverview();
    renderComparison();
    renderMetals();
    renderCrisis();
    renderCrisisDetail();
    renderConsultation();
    renderSettings();
    renderPrivacy();
  }

  function applySettingsToUI() {
    renderSettings();
  }

  function renderOverview() {
    if (!state.snapshot) return;
    renderOverviewHero();
    renderOverviewMetals();
    renderOverviewMacro();
    renderWhyMetals(elements.overviewWhyMetals);
  }

  function renderOverviewHero() {
    const container = elements.overviewHero;
    if (!container) return;
    clearElement(container);

    const header = cardHeader(TEXT.heroTitle, TEXT.heroSubtitle);
    container.append(header);

    const entry = currentBennerEntry(state.bennerEntries, new Date().getFullYear());
    if (!entry) return;

    const row = makeEl("div", "row");
    const label = makeEl("span", "pill", TEXT.heroLabel);
    const year = makeEl("span", "label", String(entry.year));
    row.append(label, year);

    const summary = makeEl("div", "hero-summary", `${entry.year} - ${entry.phase.subtitle}`);
    const guidance = makeEl("p", "hint", entry.phase.guidance);

    container.append(row, summary, guidance, makeProgress(entry.progress, "accent"));
  }

  function renderOverviewMetals() {
    const container = elements.overviewMetals;
    if (!container || !state.snapshot) return;
    clearElement(container);
    container.append(cardHeader(TEXT.metalsFocusTitle, TEXT.metalsFocusSubtitle));

    state.snapshot.metals.slice(0, 2).forEach((metal) => {
      container.append(renderMetalCard(metal));
    });
  }

  function renderOverviewMacro() {
    const container = elements.overviewMacro;
    if (!container || !state.snapshot) return;
    clearElement(container);
    container.append(cardHeader(TEXT.macroTitle, TEXT.macroSubtitle));

    const regionRow = makeEl("div", "chip-row");
    ["DE", "USA", "ES", "UK"].forEach((region) => {
      const button = makeEl("button", "chip", region);
      button.type = "button";
      button.dataset.macroRegion = region;
      if (state.selectedMacroRegion === region) button.classList.add("is-active");
      regionRow.append(button);
    });
    container.append(regionRow);

    const indicators = state.snapshot.macroOverview.indicators;
    const grid = makeEl("div", "kpi-grid");
    indicators.forEach((indicator) => {
      grid.append(renderMacroIndicator(indicator, state.selectedMacroRegion));
    });
    container.append(grid);
  }

  function renderComparison() {
    renderComparisonControls();
    renderComparisonChart();
    renderComparisonPerformance();
    renderComparisonMacro();
    renderScenarioSection();
  }

  function renderComparisonControls() {
    const container = elements.comparisonControls;
    if (!container) return;
    clearElement(container);
    container.append(cardHeader(TEXT.comparisonSectionTitle, TEXT.comparisonSectionSubtitle));

    const modeRow = makeEl("div", "segmented");
    [
      { id: "history", label: "Historisch" },
      { id: "forecast", label: "Prognose" }
    ].forEach((mode) => {
      const button = makeEl("button", "segmented-button", mode.label);
      button.type = "button";
      button.dataset.comparisonMode = mode.id;
      if (state.comparisonMode === mode.id) button.classList.add("is-active");
      modeRow.append(button);
    });
    container.append(modeRow);

    ASSET_GROUPS.forEach((group) => {
      container.append(makeEl("p", "label", group.label));
      const row = makeEl("div", "chip-row");
      COMPARISON_ASSETS.filter((asset) => asset.group === group.id).forEach((asset) => {
        const button = makeEl("button", "chip", asset.label);
        button.type = "button";
        button.dataset.assetId = asset.id;
        if (state.selectedAssets.has(asset.id)) button.classList.add("is-active");
        row.append(button);
      });
      container.append(row);
    });

    if (state.comparisonLoading && state.comparisonSeries.length === 0) {
      container.append(makeEl("p", "hint", TEXT.comparisonLoading));
    }
  }

  function renderComparisonChart() {
    const container = elements.comparisonChart;
    if (!container) return;
    clearElement(container);
    container.append(cardHeader(TEXT.comparisonChartTitle, TEXT.comparisonChartSubtitle));

    const selected = state.comparisonSeries.filter((item) => state.selectedAssets.has(item.assetId));
    const mode = state.comparisonMode;

    const series = selected
      .map((item) => {
        const points = mode === "history" ? item.history : item.projection;
        return points.length
          ? {
              label: COMPARISON_ASSET_MAP.get(item.assetId)?.label || item.assetId,
              points: points.map((point) => ({ x: point.year, y: point.value })),
              color: COMPARISON_ASSET_MAP.get(item.assetId)?.color || COLORS.accent,
              dashed: mode === "forecast"
            }
          : null;
      })
      .filter(Boolean);

    if (state.comparisonLoading && series.length === 0) {
      container.append(makeEl("p", "hint", TEXT.comparisonLoading));
      return;
    }

    if (series.length === 0) {
      container.append(makeEl("p", "hint", TEXT.comparisonNoData));
      return;
    }

    container.append(createLineChart(series, { showTodayMarker: true }));
    container.append(renderLegend(series));
  }

  function renderComparisonPerformance() {
    const container = elements.comparisonPerformance;
    if (!container) return;
    clearElement(container);
    container.append(cardHeader(TEXT.comparisonPerformanceTitle, TEXT.comparisonPerformanceSubtitle));

    const selected = state.comparisonSeries.filter((item) => state.selectedAssets.has(item.assetId));
    const hasHistory = selected.some((item) => item.history.length);

    if (state.comparisonLoading && !hasHistory) {
      container.append(makeEl("p", "hint", TEXT.comparisonLoading));
      return;
    }

    if (!hasHistory) {
      container.append(makeEl("p", "hint", TEXT.comparisonNoData));
      return;
    }

    selected.forEach((item) => {
      const row = makeEl("div", "row");
      row.append(makeEl("span", "label", COMPARISON_ASSET_MAP.get(item.assetId)?.label || item.assetId));
      const value = `Historisch ${calcCagr(item.history)} / Prognose ${calcProjectionDelta(item.history, item.projection)}`;
      row.append(makeEl("span", "hint", value));
      container.append(row);
    });
  }

  function renderComparisonMacro() {
    const container = elements.comparisonMacro;
    if (!container) return;
    clearElement(container);
    container.append(cardHeader(TEXT.comparisonMacroTitle, TEXT.comparisonMacroSubtitle));

    const segmented = makeEl("div", "segmented");
    MACRO_KINDS.forEach((kind) => {
      const button = makeEl("button", "segmented-button", kind.title);
      button.type = "button";
      button.dataset.macroKind = kind.id;
      if (state.macroComparison.kindId === kind.id) button.classList.add("is-active");
      segmented.append(button);
    });
    container.append(segmented);

    if (state.macroComparison.loading && Object.keys(state.macroComparison.data).length === 0) {
      container.append(makeEl("p", "hint", TEXT.comparisonMacroLoading));
      return;
    }

    const availableSeries = Object.entries(state.macroComparison.data)
      .map(([iso, series]) => {
        const region = MACRO_COMPARISON_REGIONS.find((item) => item.iso === iso);
        return {
          label: region?.label || iso,
          points: series.points.map((point) => ({ x: point.year, y: point.value })),
          color: region?.color || COLORS.accent,
          colorClass: region?.colorClass || "color-accent"
        };
      })
      .filter((series) => series.points.length);

    if (!availableSeries.length) {
      container.append(makeEl("p", "hint", TEXT.comparisonMacroNoData));
      return;
    }

    container.append(createLineChart(availableSeries));
    container.append(renderLegend(availableSeries));
  }

  function renderScenarioSection() {
    const container = elements.comparisonScenario;
    if (!container) return;
    clearElement(container);
    container.append(cardHeader(TEXT.comparisonScenarioTitle, TEXT.comparisonScenarioSubtitle));

    const card = makeEl("div", "stack");
    card.append(renderScenarioSlider("inflation", TEXT.scenarioInflation, -2, 12, state.scenario.inflation));
    card.append(renderScenarioSlider("growth", TEXT.scenarioGrowth, -5, 10, state.scenario.growth));
    card.append(renderScenarioSlider("defense", TEXT.scenarioDefense, 0, 8, state.scenario.defense));
    container.append(wrapInCard(card));

    const impacts = scenarioImpacts(state.scenario);
    const impactCard = makeEl("div", "stack");
    impactCard.append(renderImpactRow(TEXT.scenarioEquities, impacts.equities, "accent"));
    impactCard.append(renderImpactRow(TEXT.scenarioRealEstate, impacts.realEstate, "strong"));
    impactCard.append(renderImpactRow(TEXT.scenarioMetals, impacts.metals, "info"));
    container.append(wrapInCard(impactCard));

    const portfolioScore = portfolioResilience(impacts);
    const portfolioCard = makeEl("div", "stack");
    portfolioCard.append(makeEl("h3", null, TEXT.portfolioTitle));
    portfolioCard.append(makeEl("p", "hint", TEXT.portfolioSubtitle));
    const portfolioProgress = makeProgress(portfolioScore, "accent");
    portfolioProgress.dataset.portfolioScore = "true";
    portfolioCard.append(portfolioProgress);
    const portfolioLabel = makeEl("p", "hint", `${Math.round(portfolioScore * 100)}%`);
    portfolioLabel.dataset.portfolioLabel = "true";
    portfolioCard.append(portfolioLabel);
    container.append(wrapInCard(portfolioCard));
  }

  function renderMetals() {
    renderMetalsSelector();
    renderMetalsPrice();
    renderMetalsProjection();
    renderMetalsChart();
    renderMetalsResilience();
    renderWhyMetals(elements.metalsWhy);
  }

  function renderMetalsSelector() {
    const container = elements.metalsSelector;
    if (!container || !state.snapshot) return;
    clearElement(container);
    container.append(cardHeader(TEXT.metalsSelectorTitle));

    const row = makeEl("div", "chip-row");
    state.snapshot.metals.forEach((metal) => {
      const button = makeEl("button", "chip", metal.name);
      button.type = "button";
      button.dataset.metalId = metal.id;
      if (state.selectedMetalId === metal.id) button.classList.add("is-active");
      row.append(button);
    });
    container.append(row);
  }

  function renderMetalsPrice() {
    const container = elements.metalsPrice;
    if (!container || !state.snapshot) return;
    clearElement(container);

    const metal = selectedMetal();
    if (!metal) return;

    const converted = convertCurrency(metal.price, metal.currency, state.settings.currency, state.fxRate);
    const priceText = formatCurrency(converted, state.settings.currency);
    const changeText = formatSignedPercent(metal.dailyChangePercentage);
    const changeClass = metal.dailyChangePercentage >= 0 ? "badge high" : "badge low";

    const headerRow = makeEl("div", "row");
    headerRow.append(makeEl("h3", null, metal.name));
    headerRow.append(makeEl("span", "pill", metal.symbol));

    const valueRow = makeEl("div", "row");
    valueRow.append(makeEl("span", "value", priceText));
    valueRow.append(makeEl("span", changeClass, changeText));

    const updated = metal.lastUpdated ? new Date(metal.lastUpdated) : null;
    const updatedText = updated ? `Stand: ${formatDateTime(updated)}` : "";

    container.append(headerRow, valueRow, makeEl("p", "hint", updatedText));
    const insights = makeEl("div", "metric-grid");
    const changeValueRaw = Number.isFinite(metal.change)
      ? metal.change
      : metal.dailyChangePercentage * metal.price * 0.01;
    const changeValue = convertCurrency(changeValueRaw, metal.currency, state.settings.currency, state.fxRate);
    insights.append(renderMetric("24h", formatPercent(metal.dailyChangePercentage)));
    insights.append(renderMetric("Veraenderung", formatNumber(changeValue, 2)));
    container.append(insights);
  }

  function renderMetalsProjection() {
    const container = elements.metalsProjection;
    if (!container) return;
    clearElement(container);

    const metal = selectedMetal();
    if (!metal) return;

    container.append(cardHeader(TEXT.metalsProjectionTitle, `${metal.name} Ausblick`));

    const currentYear = new Date().getFullYear();
    const projections = state.bennerEntries.filter((entry) => entry.year >= currentYear).slice(0, 3);

    const list = makeEl("div", "stack");
    projections.forEach((entry) => {
      const row = makeEl("div", "row");
      row.append(makeEl("span", "label", String(entry.year)));
      row.append(makeEl("span", "hint", entry.phase.subtitle));
      const card = wrapInCard(makeEl("div", "stack"));
      card.firstChild.append(row, makeProgress(entry.progress, "accent"));
      list.append(card);
    });

    container.append(list);
  }

  function renderMetalsChart() {
    const container = elements.metalsChart;
    if (!container) return;
    clearElement(container);

    const metal = selectedMetal();
    if (!metal) return;

    container.append(cardHeader(TEXT.metalsTrendTitle, TEXT.metalsTrendSubtitle.replace("%s", metal.name)));

    const history = metalHistoryFor(metal);
    if (!history && state.metalHistoryLoading) {
      container.append(makeEl("p", "hint", TEXT.metalsTrendLoading));
      return;
    }

    const points = metalTrendPoints(metal, history);
    const historyPoints = points.filter((point) => !point.isProjection);
    const projectionPoints = points.filter((point) => point.isProjection);

    if (!points.length) {
      container.append(makeEl("p", "hint", TEXT.comparisonNoData));
      return;
    }

    const series = [];
    if (historyPoints.length) {
      series.push({
        label: `${metal.name} Historie`,
        points: historyPoints.map((point) => ({ x: point.year, y: point.value })),
        color: COLORS.strong
      });
    }
    if (projectionPoints.length) {
      series.push({
        label: `${metal.name} Prognose`,
        points: projectionPoints.map((point) => ({ x: point.year, y: point.value })),
        color: COLORS.strong,
        dashed: true
      });
    }

    container.append(createLineChart(series));
  }

  function renderMetalsResilience() {
    const container = elements.metalsResilience;
    if (!container || !state.snapshot) return;
    clearElement(container);

    const metal = selectedMetal();
    if (!metal) return;

    container.append(cardHeader(TEXT.metalsResilienceTitle, TEXT.metalsResilienceSubtitle.replace("%s", metal.name)));

    const inflation = indicatorValue("INFLATION");
    const growth = indicatorValue("GROWTH");
    const defense = indicatorValue("DEFENSE");

    const scenarios = [
      {
        title: TEXT.metalsScenarioInflation,
        description: `${metal.name} reagiert historisch positiv auf steigende Verbraucherpreise.`,
        score: normalizedScore(inflation + metal.dailyChangePercentage),
        badge: TEXT.metalsBadgeProtection,
        tone: "accent"
      },
      {
        title: TEXT.metalsScenarioWars,
        description: TEXT.metalsScenarioWarsDetail,
        score: normalizedScore(defense + 5),
        badge: TEXT.metalsBadgeShield,
        tone: "info"
      },
      {
        title: TEXT.metalsScenarioRecession,
        description: TEXT.metalsScenarioRecessionDetail.replace("%s", metal.name),
        score: normalizedScore(-growth + 8),
        badge: TEXT.metalsBadgeDiversification,
        tone: "strong"
      }
    ];

    const list = makeEl("div", "stack");
    scenarios.forEach((scenario) => {
      const card = makeEl("div", "stack");
      const row = makeEl("div", "row");
      row.append(makeEl("h3", null, scenario.title));
      row.append(makeEl("span", "pill", scenario.badge));
      card.append(row);
      card.append(makeEl("p", "hint", scenario.description));
      card.append(makeProgress(scenario.score, scenario.tone));
      list.append(wrapInCard(card));
    });

    container.append(list);
  }

  function renderCrisis() {
    renderCrisisSummary();
    renderCrisisFeed();
  }

  function renderCrisisSummary() {
    const container = elements.crisisSummary;
    if (!container || !state.snapshot) return;
    clearElement(container);

    container.append(cardHeader(TEXT.crisisOverviewTitle, TEXT.crisisOverviewSubtitle));
    const profile = THRESHOLD_PROFILES[state.settings.thresholdProfile] || THRESHOLD_PROFILES.standard;
    const summary = summarizeCrisis(state.snapshot.crises, profile.highRisk);

    if (!summary) {
      container.append(makeEl("p", "hint", TEXT.crisisOverviewEmpty));
      return;
    }

    const card = makeEl("div", "stack");
    card.append(makeEl("h3", null, summary.headline));
    summary.highlights.forEach((item) => {
      card.append(makeEl("p", "hint", item));
    });

    container.append(wrapInCard(card));
  }

  function renderCrisisFeed() {
    const container = elements.crisisFeed;
    if (!container || !state.snapshot) return;
    clearElement(container);

    container.append(cardHeader(TEXT.crisisFeedTitle, TEXT.crisisFeedSubtitle));

    const events = [...state.snapshot.crises].sort((a, b) => b.occurredAt - a.occurredAt);
    if (!events.length) {
      container.append(makeEl("p", "hint", TEXT.crisisFeedEmpty));
      return;
    }

    const list = makeEl("div", "stack");
    events.forEach((event) => list.append(renderCrisisCard(event)));
    container.append(list);
  }

  function renderCrisisDetail() {
    const container = elements.crisisDetailCard;
    if (!container || !state.snapshot) return;
    clearElement(container);

    const event = state.snapshot.crises.find((item) => item.id === state.crisisDetailId);
    if (!event) {
      container.append(makeEl("p", "hint", TEXT.crisisDetailMissing));
      return;
    }

    const detail = makeEl("div", "stack");
    detail.append(makeEl("h2", null, event.title));
    detail.append(makeEl("p", "hint", event.region));
    detail.append(makeEl("span", "pill", categoryLabel(event.category)));

    if (event.summary) {
      detail.append(makeEl("p", "hint", event.summary));
    }

    detail.append(makeEl("p", "hint", `Zeitpunkt: ${formatDateTime(new Date(event.occurredAt))}`));
    if (event.sourceName) {
      detail.append(makeEl("p", "hint", `Quelle: ${event.sourceName}`));
    }
    if (event.detailURL) {
      const link = makeEl("a", "ghost-button", TEXT.crisisDetailOpenSource);
      link.href = event.detailURL;
      link.target = "_blank";
      link.rel = "noopener noreferrer";
      detail.append(link);
    }

    container.append(wrapInCard(detail));

    const timeline = makeEl("div", "stack");
    timeline.append(makeEl("h3", null, TEXT.crisisDetailTimeline));
    relatedEvents(event).forEach((item) => timeline.append(renderTimelineItem(item)));
    container.append(wrapInCard(timeline));
  }

  function renderConsultation() {
    renderConsultationInfo();
    renderConsultationPrivacy();
  }

  function renderConsultationInfo() {
    const container = elements.consultationInfo;
    if (!container) return;
    clearElement(container);

    const list = makeEl("ul", "bullet-list");
    TEXT.consultationExpectations.forEach((item) => {
      const li = makeEl("li", null, item);
      list.append(li);
    });
    container.append(cardHeader(TEXT.consultationExpectationsTitle));
    container.append(list);
  }

  function renderConsultationPrivacy() {
    const container = elements.consultationPrivacy;
    if (!container) return;
    clearElement(container);

    container.append(cardHeader(TEXT.consultationMoreInfoTitle));
    const stack = makeEl("div", "stack");
    stack.append(renderInfoRow(TEXT.consultationInfo1Title, TEXT.consultationInfo1Text));
    stack.append(renderInfoRow(TEXT.consultationInfo2Title, TEXT.consultationInfo2Text));
    stack.append(makeEl("p", "hint", TEXT.consultationPrivacyNote));
    container.append(stack);
  }

  function renderSettings() {
    if (!elements.settingsSheet) return;

    $$("[data-currency]").forEach((button) => {
      button.classList.toggle("is-active", button.dataset.currency === state.settings.currency);
    });

    $$("[data-threshold]").forEach((button) => {
      button.classList.toggle("is-active", button.dataset.threshold === state.settings.thresholdProfile);
    });

    if (elements.newsApiKey && document.activeElement !== elements.newsApiKey) {
      elements.newsApiKey.value = state.settings.newsApiKey || "";
    }

    renderWatchlist(elements.watchlistGeo, WATCHLISTS.geopolitical, state.settings.watchlistGeo, "geo");
    renderWatchlist(elements.watchlistFinancial, WATCHLISTS.financial, state.settings.watchlistFinancial, "financial");

    updateNotificationUI();
  }

  function renderPrivacy() {
    const container = elements.privacyContent;
    if (!container) return;
    clearElement(container);

    container.append(makeEl("p", "hint", TEXT.privacyIntro));

    TEXT.privacySections.forEach((section) => {
      const card = makeEl("div", "stack");
      card.append(makeEl("h3", null, section.title));

      if (Array.isArray(section.body)) {
        const list = makeEl("ul", "bullet-list");
        section.body.forEach((line) => list.append(makeEl("li", null, line)));
        card.append(list);
      } else {
        card.append(makeEl("p", "hint", section.body));
      }

      container.append(wrapInCard(card));
    });
  }

  function renderWhyMetals(container) {
    if (!container) return;
    clearElement(container);

    const list = makeEl("ul", "bullet-list");
    TEXT.whyMetalsBullets.forEach((item) => list.append(makeEl("li", null, item)));
    container.append(cardHeader(TEXT.whyMetalsTitle));
    container.append(list);
  }

  function updateScenarioValues(container, scenario) {
    if (!container) return;
    const values = container.querySelectorAll("[data-slider-value]");
    values.forEach((value) => {
      const key = value.getAttribute("data-slider-value");
      if (!key) return;
      const amount = scenario[key];
      value.textContent = Number.isFinite(amount) ? amount.toFixed(1) : "0";
    });

    const impacts = scenarioImpacts(scenario);
    updateImpactBar(container, "equities", impacts.equities);
    updateImpactBar(container, "realEstate", impacts.realEstate);
    updateImpactBar(container, "metals", impacts.metals);

    const portfolioScore = portfolioResilience(impacts);
    const portfolio = container.querySelector("[data-portfolio-score]");
    if (portfolio instanceof HTMLProgressElement) {
      portfolio.value = portfolioScore;
    }
    const portfolioLabel = container.querySelector("[data-portfolio-label]");
    if (portfolioLabel instanceof HTMLElement) {
      portfolioLabel.textContent = `${Math.round(portfolioScore * 100)}%`;
    }
  }

  function updateImpactBar(container, id, value) {
    const bar = container.querySelector(`[data-impact='${id}']`);
    if (!(bar instanceof HTMLProgressElement)) return;
    bar.value = normalizeImpact(value);
    const label = container.querySelector(`[data-impact-label='${id}']`);
    if (label instanceof HTMLElement) {
      label.textContent = formatNumber(value, 1);
    }
  }

  function updateCurrency(currency) {
    if (currency !== "EUR" && currency !== "USD") return;
    if (state.settings.currency !== currency) {
      state.settings.currency = currency;
      saveSettings();
      void ensureFxRate();
      renderAll();
    }
  }

  function updateThresholdProfile(profileId) {
    if (!THRESHOLD_PROFILES[profileId]) return;
    state.settings.thresholdProfile = profileId;
    saveSettings();
    renderCrisis();
  }

  function handleWatchlistChange(event) {
    const target = event.target;
    if (!(target instanceof HTMLInputElement)) return;
    const code = target.value;
    const type = target.dataset.watchlist;
    if (!code || !type) return;

    if (type === "geo") {
      updateWatchlistSet(state.settings.watchlistGeo, code, target.checked);
    }
    if (type === "financial") {
      updateWatchlistSet(state.settings.watchlistFinancial, code, target.checked);
    }

    saveSettings();
    void syncData({ silent: true });
  }

  function updateWatchlistSet(list, code, enabled) {
    const index = list.indexOf(code);
    if (enabled && index < 0) {
      list.push(code);
    } else if (!enabled && index >= 0) {
      list.splice(index, 1);
    }
  }

  async function handleNotificationAction() {
    if (!("Notification" in window)) {
      showToast("Benachrichtigungen sind in diesem Browser nicht verfuegbar.");
      return;
    }

    if (Notification.permission === "default") {
      const result = await Notification.requestPermission();
      if (result === "granted") {
        showToast("Benachrichtigungen aktiviert.");
      }
      updateNotificationUI();
      return;
    }

    showToast("Bitte aktivieren Sie Benachrichtigungen in den Browser-Einstellungen.");
  }

  function updateNotificationUI() {
    if (!elements.notificationStatus || !elements.notificationAction || !elements.notificationDescription) return;

    if (!("Notification" in window)) {
      elements.notificationStatus.textContent = "Nicht verfuegbar";
      elements.notificationDescription.textContent = "Dieser Browser unterstuetzt keine Benachrichtigungen.";
      elements.notificationAction.disabled = true;
      return;
    }

    if (Notification.permission === "granted") {
      elements.notificationStatus.textContent = TEXT.notificationsActive;
      elements.notificationDescription.textContent = TEXT.notificationsActiveDesc;
      elements.notificationAction.textContent = TEXT.notificationsActionOpenSettings;
    } else if (Notification.permission === "denied") {
      elements.notificationStatus.textContent = TEXT.notificationsDenied;
      elements.notificationDescription.textContent = TEXT.notificationsDeniedDesc;
      elements.notificationAction.textContent = TEXT.notificationsActionOpenSettings;
    } else {
      elements.notificationStatus.textContent = TEXT.notificationsUnknown;
      elements.notificationDescription.textContent = TEXT.notificationsUnknownDesc;
      elements.notificationAction.textContent = TEXT.notificationsActionEnable;
    }
  }

  async function handleConsultationSubmit(event) {
    event.preventDefault();
    if (!elements.consultationForm) return;

    const formData = new FormData(elements.consultationForm);
    const name = String(formData.get("name") || "").trim();
    const email = String(formData.get("email") || "").trim();
    const phone = String(formData.get("phone") || "").trim();
    const message = String(formData.get("message") || "").trim();

    const error = validateConsultation(name, email, phone, message);
    if (error) {
      showToast(error);
      return;
    }

    try {
      const response = await fetch("https://api.midainvest.com/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email, phone, message, locale: navigator.language || "de-DE" })
      });

      if (!response.ok) {
        throw new Error("Fehler beim Senden");
      }

      elements.consultationForm.reset();
      showToast(`${TEXT.consultationSuccessTitle}: ${TEXT.consultationSuccessMessage}`);
    } catch (error) {
      showToast(`${TEXT.consultationFailureTitle}: ${(error && error.message) || "Fehler beim Senden"}`);
    }
  }

  function validateConsultation(name, email, phone, message) {
    if (name.length < 2) return "Bitte geben Sie Ihren Namen an.";
    if (!/^([A-Z0-9._%+-]+)@([A-Z0-9.-]+)\.([A-Z]{2,})$/i.test(email)) {
      return "Bitte geben Sie eine gueltige E-Mail-Adresse an.";
    }
    if (phone.length < 5) return "Bitte geben Sie Ihre Telefonnummer an.";
    if (message.length < 10) return "Ihre Nachricht sollte mindestens 10 Zeichen enthalten.";
    return "";
  }

  async function syncData(options = {}) {
    if (!state.snapshot) return;
    elements.refreshButton?.classList.add("is-loading");

    try {
      await ensureFxRate();

      const snapshot = state.snapshot;

      const [metalsResult, macroResult, crisisResult] = await Promise.allSettled([
        fetchMetals(),
        fetchMacroSnapshot(),
        fetchCrisisEvents()
      ]);

      const metals = metalsResult.status === "fulfilled" && metalsResult.value.length ? metalsResult.value : snapshot.metals;
      const macro = macroResult.status === "fulfilled" ? macroResult.value : { overview: snapshot.macroOverview, series: snapshot.macroSeries };
      const crises = crisisResult.status === "fulfilled" ? crisisResult.value : snapshot.crises;

      state.snapshot = {
        metals,
        macroOverview: macro.overview,
        macroSeries: macro.series,
        crises
      };

      const failures = [];
      if (metalsResult.status === "rejected") failures.push("Metalle");
      if (macroResult.status === "rejected") failures.push("Makro");
      if (crisisResult.status === "rejected") failures.push("Krisen");

      if (failures.length === 0) {
        state.lastSyncAt = Date.now();
      }
      state.lastError = failures.length ? `Teilweise offline (${failures.join(", ")})` : null;
      saveSnapshot(state.snapshot);

      if (!state.scenarioTouched) {
        state.scenario = seedScenarioFromSnapshot(state.snapshot);
      }

      maybeNotify(crises);
    } catch (error) {
      state.lastError = error instanceof Error ? error.message : "Sync fehlgeschlagen";
    } finally {
      elements.refreshButton?.classList.remove("is-loading");
      updateSyncBanner();
      renderAll();
      if (!options.silent && state.lastError) {
        showToast(`Offline: ${state.lastError}`);
      }
    }
  }

  async function ensureComparisonSeries() {
    if (state.comparisonLoading || state.comparisonSeries.length) return;
    state.comparisonLoading = true;
    renderComparison();

    const series = await loadComparisonSeries();
    state.comparisonSeries = series;
    state.comparisonLoading = false;
    renderComparison();
  }

  async function ensureMacroComparison() {
    if (state.macroComparison.loading) return;
    state.macroComparison.loading = true;
    renderComparisonMacro();

    const kindId = state.macroComparison.kindId;
    const results = await Promise.allSettled(
      MACRO_COMPARISON_REGIONS.map(async (region) => {
        const points = await fetchWorldBankSeries(region.iso, MACRO_KIND_MAP.get(kindId)?.indicatorCode || "", 12);
        return { iso: region.iso, series: { kindId, points } };
      })
    );

    const data = {};
    results.forEach((result) => {
      if (result.status === "fulfilled" && result.value.series.points.length) {
        data[result.value.iso] = result.value.series;
      }
    });

    state.macroComparison.data = data;
    state.macroComparison.loading = false;
    renderComparisonMacro();
  }

  async function ensureMetalHistory() {
    const metal = selectedMetal();
    if (!metal) return;

    const instrument = metalInstrument(metal.id);
    if (!instrument) return;

    if (state.stooqCache[instrument]) return;

    state.metalHistoryLoading = true;
    renderMetalsChart();
    await fetchStooqHistory(instrument, 10);
    state.metalHistoryLoading = false;
    renderMetalsChart();
  }

  function updateSyncBanner() {
    if (!elements.syncBanner) return;
    const banner = elements.syncBanner;

    if (state.lastError || !navigator.onLine) {
      const time = state.lastSyncAt ? formatDateTime(new Date(state.lastSyncAt)) : "";
      banner.textContent = state.lastError
        ? `Offline: letzte Synchronisierung ${time}. ${state.lastError}`
        : `Offline: letzte Synchronisierung ${time}.`;
      banner.classList.add("is-visible");
      return;
    }

    banner.textContent = "";
    banner.classList.remove("is-visible");
  }

  async function fetchMetals() {
    const response = await fetch("https://data-asg.goldprice.org/dbXRates/USD", { cache: "no-store" });
    const data = await response.json();
    const item = data.items?.[0];
    if (!item) return [];

    const timestamp = Number(data.ts || Date.now());

    return [
      {
        id: "XAU",
        name: "Gold",
        symbol: "XAU",
        price: Number(item.xauPrice),
        dailyChangePercentage: Number(item.pcXau),
        change: Number(item.chgXau),
        currency: item.curr || "USD",
        lastUpdated: timestamp
      },
      {
        id: "XAG",
        name: "Silber",
        symbol: "XAG",
        price: Number(item.xagPrice),
        dailyChangePercentage: Number(item.pcXag),
        change: Number(item.chgXag),
        currency: item.curr || "USD",
        lastUpdated: timestamp
      }
    ];
  }

  async function fetchMacroSnapshot() {
    const results = await Promise.allSettled(
      MACRO_KINDS.map((kind) => fetchMacroIndicator("DEU", kind))
    );

    const indicators = [];
    const series = [];

    results.forEach((result) => {
      if (result.status === "fulfilled") {
        indicators.push(result.value.indicator);
        series.push(result.value.series);
      }
    });

    return {
      overview: { indicators },
      series
    };
  }

  async function fetchMacroIndicator(countryIso, kind) {
    const points = await fetchWorldBankSeries(countryIso, kind.indicatorCode, 8);
    const sorted = points.slice().sort((a, b) => a.year - b.year);
    const latest = sorted[sorted.length - 1];
    const previous = sorted[sorted.length - 2];

    return {
      indicator: {
        id: kind.id,
        title: kind.title,
        latestValue: latest?.value ?? null,
        previousValue: previous?.value ?? null,
        unit: kind.unit,
        description: kind.explanation
      },
      series: { kindId: kind.id, points: sorted }
    };
  }

  async function fetchWorldBankSeries(countryIso, indicatorCode, limit) {
    if (!indicatorCode) return [];
    const url = `https://api.worldbank.org/v2/country/${countryIso}/indicator/${indicatorCode}?format=json&per_page=${limit}`;
    const response = await fetch(url, { cache: "no-store" });
    const data = await response.json();
    const entries = Array.isArray(data) ? data[1] : [];
    if (!Array.isArray(entries)) return [];

    const points = entries
      .map((entry) => {
        const year = Number(entry.date);
        const value = Number(entry.value);
        if (!Number.isFinite(year) || !Number.isFinite(value)) return null;
        return { year, value };
      })
      .filter(Boolean);

    points.sort((a, b) => a.year - b.year);
    return points;
  }

  async function fetchCrisisEvents() {
    const profile = THRESHOLD_PROFILES[state.settings.thresholdProfile] || THRESHOLD_PROFILES.standard;

    const [newsResult, geoResult, financeResult] = await Promise.allSettled([
      fetchNewsEvents(),
      fetchGovernanceAlerts(profile),
      fetchRecessionAlerts(profile)
    ]);

    const events = [];
    if (newsResult.status === "fulfilled") events.push(...newsResult.value);
    if (geoResult.status === "fulfilled") events.push(...geoResult.value);
    if (financeResult.status === "fulfilled") events.push(...financeResult.value);

    return events.sort((a, b) => b.occurredAt - a.occurredAt).slice(0, 12);
  }

  async function fetchNewsEvents() {
    if (!state.settings.newsApiKey) {
      return state.newsCache?.events || [];
    }

    const apiKey = state.settings.newsApiKey;
    const headers = { "X-Api-Key": apiKey };

    const headlinesUrl = "https://newsapi.org/v2/top-headlines?category=business&language=en&pageSize=6";
    const everythingUrl =
      "https://newsapi.org/v2/everything?q=geopolitics%20OR%20government%20OR%20election%20OR%20crisis%20OR%20war&language=en&pageSize=6&sortBy=publishedAt";

    try {
      const [headlinesResponse, everythingResponse] = await Promise.all([
        fetch(headlinesUrl, { headers, cache: "no-store" }),
        fetch(everythingUrl, { headers, cache: "no-store" })
      ]);

      const [headlines, everything] = await Promise.all([headlinesResponse.json(), everythingResponse.json()]);
      const mapped = [];

      (headlines.articles || []).forEach((article) => {
        const event = mapNewsArticle(article, "FINANCIAL");
        if (event) mapped.push(event);
      });

      (everything.articles || []).forEach((article) => {
        const event = mapNewsArticle(article, "GEOPOLITICAL");
        if (event) mapped.push(event);
      });

      const unique = {};
      mapped.forEach((event) => {
        if (!unique[event.id]) unique[event.id] = event;
      });

      const events = Object.values(unique).slice(0, 10);
      state.newsCache = { fetchedAt: Date.now(), events };
      writeJson(STORAGE_KEYS.newsCache, state.newsCache);
      return events;
    } catch (error) {
      return state.newsCache?.events || [];
    }
  }

  function mapNewsArticle(article, category) {
    if (!article || !article.title) return null;
    const publishedAt = article.publishedAt ? Date.parse(article.publishedAt) : Date.now();
    const id = `news-${category}-${hashString(article.title)}`;

    return {
      id,
      title: article.title,
      summary: article.description || article.content || "",
      region: article.source?.name || "Weltweit",
      occurredAt: Number.isFinite(publishedAt) ? publishedAt : Date.now(),
      publishedAt: Number.isFinite(publishedAt) ? publishedAt : Date.now(),
      detailURL: article.url || "",
      sourceName: article.source?.name || "NewsAPI",
      source: "NEWS_API",
      category,
      severityScore: newsSeverityScore(publishedAt)
    };
  }

  async function fetchGovernanceAlerts(profile) {
    const active = WATCHLISTS.geopolitical.filter((item) => state.settings.watchlistGeo.includes(item.code));
    if (!active.length) return [];

    const results = await Promise.allSettled(
      active.map(async (country) => {
        const value = await fetchWorldBankLatest(country.code, "PV.PSR.PIND");
        if (!value || value.value >= profile.governanceCutoff) return null;
        return {
          id: `geo-${country.code}`,
          title: `Politische Instabilitaet ${country.name}`,
          summary: `Governance-Index ${formatNumber(value.value, 2)}`,
          region: country.name,
          occurredAt: yearInstant(value.year),
          publishedAt: yearInstant(value.year),
          detailURL: "https://data.worldbank.org/indicator/PV.PSR.PIND",
          sourceName: "World Bank",
          source: "WORLD_BANK_GOVERNANCE",
          category: "GEOPOLITICAL",
          severityScore: governanceSeverity(value.value)
        };
      })
    );

    return results
      .map((result) => (result.status === "fulfilled" ? result.value : null))
      .filter(Boolean);
  }

  async function fetchRecessionAlerts(profile) {
    const active = WATCHLISTS.financial.filter((item) => state.settings.watchlistFinancial.includes(item.code));
    if (!active.length) return [];

    const results = await Promise.allSettled(
      active.map(async (country) => {
        const value = await fetchWorldBankLatest(country.code, "NY.GDP.MKTP.KD.ZG");
        if (!value || value.value >= profile.recessionCutoff) return null;
        return {
          id: `finance-${country.code}`,
          title: `Rezession ${country.name}`,
          summary: `Reales BIP-Wachstum ${formatNumber(value.value, 1)}%`,
          region: country.name,
          occurredAt: yearInstant(value.year),
          publishedAt: yearInstant(value.year),
          detailURL: "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG",
          sourceName: "World Bank",
          source: "WORLD_BANK_FINANCE",
          category: "FINANCIAL",
          severityScore: recessionSeverity(value.value)
        };
      })
    );

    return results
      .map((result) => (result.status === "fulfilled" ? result.value : null))
      .filter(Boolean);
  }

  async function fetchWorldBankLatest(countryIso, indicatorCode) {
    const url = `https://api.worldbank.org/v2/country/${countryIso}/indicator/${indicatorCode}?format=json&per_page=2`;
    const response = await fetch(url, { cache: "no-store" });
    const data = await response.json();
    const entries = Array.isArray(data) ? data[1] : [];
    if (!Array.isArray(entries)) return null;

    const latest = entries.find((entry) => entry.value !== null && entry.value !== undefined);
    if (!latest) return null;

    const year = Number(latest.date);
    const value = Number(latest.value);
    if (!Number.isFinite(year) || !Number.isFinite(value)) return null;

    return { year, value };
  }

  async function ensureFxRate() {
    if (state.settings.currency !== "EUR") return;

    if (state.fxRate && !fxRateStale(state.fxRate)) return;

    try {
      const fxRate = await fetchFxRate();
      state.fxRate = fxRate;
      writeJson(STORAGE_KEYS.fxRate, fxRate);
    } catch (error) {
      if (!state.fxRate) {
        state.fxRate = null;
      }
    }
  }

  async function fetchFxRate() {
    const response = await fetch("https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml", { cache: "no-store" });
    const text = await response.text();
    const xml = new DOMParser().parseFromString(text, "application/xml");
    const node = xml.querySelector("Cube[currency='USD']");
    const rate = Number(node?.getAttribute("rate"));
    if (!Number.isFinite(rate)) throw new Error("FX parse failed");
    return { rate, fetchedAt: Date.now() };
  }

  function fxRateStale(fxRate) {
    if (!fxRate?.fetchedAt) return true;
    return Date.now() - fxRate.fetchedAt > 12 * 60 * 60 * 1000;
  }

  async function loadComparisonSeries() {
    const series = await Promise.all(
      COMPARISON_ASSETS.map(async (asset) => {
        const history = asset.instrument ? await fetchStooqHistory(asset.instrument, 10) : [];
        const projection = history.length ? makeProjection(history, asset.group) : [];
        return { assetId: asset.id, history, projection };
      })
    );

    return series;
  }

  async function fetchStooqHistory(symbol, limitYears) {
    const cached = state.stooqCache[symbol];
    if (cached) return cached.points;

    try {
      const response = await fetch(`https://stooq.pl/q/d/l/?s=${symbol}&i=d`, { cache: "no-store" });
      const text = await response.text();
      const points = parseStooqCsv(text, limitYears);
      if (points.length) {
        state.stooqCache[symbol] = { fetchedAt: Date.now(), points };
        writeJson(STORAGE_KEYS.stooqCache, state.stooqCache);
      }
      return points;
    } catch (error) {
      return cached?.points || [];
    }
  }

  function parseStooqCsv(csv, limitYears) {
    if (!csv) return [];
    const lines = csv.trim().split("\n");
    const points = [];

    lines.slice(1).forEach((line) => {
      const parts = line.split(",");
      if (parts.length < 5) return;
      const year = Number(parts[0].slice(0, 4));
      const close = Number(parts[4]);
      if (!Number.isFinite(year) || !Number.isFinite(close)) return;
      points.push({ year, value: close });
    });

    points.sort((a, b) => a.year - b.year);
    if (limitYears <= 0) return points;
    const maxYear = points[points.length - 1]?.year;
    const threshold = maxYear - limitYears;
    return points.filter((point) => point.year >= threshold);
  }

  function makeProjection(history, group) {
    const last = history[history.length - 1];
    if (!last) return [];

    let value = last.value;
    return state.bennerEntries
      .filter((entry) => entry.year >= last.year)
      .map((entry) => {
        value += value * assetMultiplier(group, entry.phase.id);
        return { year: entry.year, value };
      });
  }

  function assetMultiplier(group, phaseId) {
    if (group === "equities") {
      if (phaseId === "good") return 0.05;
      if (phaseId === "hard") return -0.02;
      return -0.08;
    }
    if (group === "real_estate") {
      if (phaseId === "good") return 0.03;
      if (phaseId === "hard") return -0.015;
      return -0.06;
    }
    if (phaseId === "good") return 0.015;
    if (phaseId === "hard") return 0.03;
    return 0.08;
  }

  function metalTrendPoints(metal, history) {
    const historyPoints = history || [];
    const currentYear = new Date().getFullYear();
    const base = historyPoints.length
      ? historyPoints[historyPoints.length - 1].value
      : Math.max(convertCurrency(metal.price, metal.currency, state.settings.currency, state.fxRate) / 100, 25.0);

    const projections = [];
    let value = base;
    state.bennerEntries
      .filter((entry) => entry.year >= currentYear && entry.year <= 2050)
      .forEach((entry) => {
        value += value * entry.phase.metalTrendMultiplier;
        projections.push({ year: entry.year, value, isProjection: true });
      });

    return historyPoints.map((point) => ({ ...point, isProjection: false })).concat(projections);
  }

  function metalHistoryFor(metal) {
    const instrument = metalInstrument(metal.id);
    const cached = instrument ? state.stooqCache[instrument] : null;
    return cached ? cached.points : null;
  }

  function metalInstrument(id) {
    if (id === "XAU") return "xauusd";
    if (id === "XAG") return "xagusd";
    return "";
  }

  function currentBennerEntry(entries, year) {
    return entries.find((entry) => entry.year >= year) || entries[entries.length - 1];
  }

  function makeBennerEntries() {
    const panicYears = makePanicYears(BENNER_CONFIG.rangeEnd + BENNER_CONFIG.hardSpan + Math.max(...BENNER_CONFIG.intervals));
    const entries = [];

    for (let index = 0; index < panicYears.length - 1; index += 1) {
      const panicYear = panicYears[index];
      const nextPanic = panicYears[index + 1];
      if (panicYear > BENNER_CONFIG.rangeEnd) break;

      if (panicYear >= BENNER_CONFIG.rangeStart && panicYear <= BENNER_CONFIG.rangeEnd) {
        entries.push(makeBennerEntry(panicYear, BENNER_PHASES.panic, 1, 1));
      }

      const availableYears = Math.max(Math.min(nextPanic, BENNER_CONFIG.rangeEnd + 1) - panicYear - 1, 0);
      const cycleGoodYears = Math.min(BENNER_CONFIG.goodSpan, availableYears);
      const cycleHardYears = Math.max(availableYears - cycleGoodYears, 0);

      for (let offset = 1; offset <= cycleGoodYears; offset += 1) {
        const year = panicYear + offset;
        if (year >= BENNER_CONFIG.rangeStart && year <= BENNER_CONFIG.rangeEnd) {
          entries.push(makeBennerEntry(year, BENNER_PHASES.good, offset, cycleGoodYears));
        }
      }

      for (let i = 0; i < cycleHardYears; i += 1) {
        const year = panicYear + cycleGoodYears + 1 + i;
        if (year >= BENNER_CONFIG.rangeStart && year <= BENNER_CONFIG.rangeEnd) {
          entries.push(makeBennerEntry(year, BENNER_PHASES.hard, i + 1, cycleHardYears));
        }
      }
    }

    return entries.sort((a, b) => a.year - b.year);
  }

  function makeBennerEntry(year, phase, order, length) {
    return {
      year,
      phase,
      orderInPhase: order,
      phaseLength: length,
      progress: length > 0 ? order / length : 1
    };
  }

  function makePanicYears(limit) {
    const years = [BENNER_CONFIG.initialPanicYear];
    let index = 0;
    while (years[years.length - 1] < limit) {
      const increment = BENNER_CONFIG.intervals[index % BENNER_CONFIG.intervals.length];
      years.push(years[years.length - 1] + increment);
      index += 1;
    }
    return years;
  }

  function summarizeCrisis(events, highRiskThreshold) {
    if (!events.length) return null;

    const severe = events.filter((event) => event.severityScore >= highRiskThreshold);
    const headline = severe.length
      ? `${severe.length} Hochrisiko-Ereignis(se) aktiv`
      : "Keine Hochrisiko-Ereignisse erkennbar";

    const dominantRegion = dominantGroup(events, (event) => event.region);
    const dominantCategory = dominantGroup(events, (event) => event.category);

    const highlights = [];
    if (dominantRegion) {
      highlights.push(`${dominantRegion.count}x Ereignisse in ${dominantRegion.key}`);
    }
    if (dominantCategory) {
      highlights.push(`${dominantCategory.count}x Kategorie ${categoryLabel(dominantCategory.key)}`);
    }

    const latest = events.reduce((acc, event) => (event.occurredAt > acc.occurredAt ? event : acc), events[0]);
    highlights.push(`Zuletzt ${latest.title} um ${formatDateTime(new Date(latest.occurredAt))}`);

    return { headline, highlights };
  }

  function dominantGroup(items, selector) {
    const counts = {};
    items.forEach((item) => {
      const key = selector(item);
      if (!key) return;
      counts[key] = (counts[key] || 0) + 1;
    });
    const entries = Object.entries(counts).sort((a, b) => b[1] - a[1]);
    if (!entries.length) return null;
    return { key: entries[0][0], count: entries[0][1] };
  }

  function categoryLabel(category) {
    return category === "FINANCIAL" ? TEXT.crisisCategoryFinancial : TEXT.crisisCategoryGeopolitical;
  }

  function severityBadge(score) {
    if (score < 4) return TEXT.crisisBadgeInfo;
    if (score < 6) return TEXT.crisisBadgeModerate;
    return TEXT.crisisBadgeHigh;
  }

  function severityClass(score) {
    if (score < 4) return "low";
    if (score < 6) return "medium";
    return "high";
  }

  function newsSeverityScore(publishedAt) {
    const now = Date.now();
    const hours = Math.abs(now - publishedAt) / 3_600_000;
    if (hours < 24) return 6.0;
    if (hours < 72) return 5.0;
    return 4.0;
  }

  function governanceSeverity(value) {
    return Math.abs(value) * 2;
  }

  function recessionSeverity(value) {
    return Math.abs(value);
  }

  function relatedEvents(event) {
    if (!state.snapshot) return [];
    return state.snapshot.crises
      .filter((item) => item.id !== event.id && (item.region === event.region || item.category === event.category))
      .slice(0, 6);
  }

  function renderCrisisCard(event) {
    const card = makeEl("div", "stack");
    card.dataset.crisisId = event.id;

    const header = makeEl("div", "row");
    header.append(makeEl("h3", null, event.title));
    const badge = makeEl("span", `badge ${severityClass(event.severityScore)}`, severityBadge(event.severityScore));
    header.append(badge);

    card.append(header);
    if (event.summary) {
      card.append(makeEl("p", "hint", event.summary));
    }

    const meta = makeEl("div", "row");
    meta.append(makeEl("span", "hint", event.region));
    meta.append(makeEl("span", "hint", formatDateTime(new Date(event.occurredAt))));
    card.append(meta);

    const footer = makeEl("div", "row");
    footer.append(makeEl("span", "pill", categoryLabel(event.category)));
    footer.append(makeEl("span", "hint", event.sourceName || event.source));
    card.append(footer);

    return wrapInCard(card);
  }

  function renderTimelineItem(event) {
    const row = makeEl("div", "timeline-item");
    row.append(makeEl("span", "timeline-dot", ""));
    const content = makeEl("div", "stack");
    content.append(makeEl("span", "label", event.title));
    content.append(makeEl("span", "hint", formatDateTime(new Date(event.occurredAt))));
    row.append(content);
    return row;
  }

  function renderScenarioSlider(name, label, min, max, value) {
    const wrapper = makeEl("div", "slider-row");
    const header = makeEl("div", "row");
    header.append(makeEl("label", "label", label));
    const valueLabel = makeEl("span", "hint", value.toFixed(1));
    valueLabel.dataset.sliderValue = name;
    header.append(valueLabel);
    const input = document.createElement("input");
    input.type = "range";
    input.name = name;
    input.min = String(min);
    input.max = String(max);
    input.step = "0.1";
    input.value = String(value);
    wrapper.append(header, input);
    return wrapper;
  }

  function renderImpactRow(label, value, tone) {
    const wrapper = makeEl("div", "stack");
    const header = makeEl("div", "row");
    header.append(makeEl("span", "label", label));
    const valueLabel = makeEl("span", "hint", formatNumber(value, 1));
    valueLabel.dataset.impactLabel = impactLabelId(label);
    header.append(valueLabel);
    const progress = makeProgress(normalizeImpact(value), tone);
    progress.dataset.impact = impactLabelId(label);
    wrapper.append(header, progress);
    return wrapper;
  }

  function impactLabelId(label) {
    if (label === TEXT.scenarioEquities) return "equities";
    if (label === TEXT.scenarioRealEstate) return "realEstate";
    return "metals";
  }

  function scenarioImpacts(scenario) {
    const equities = scenario.growth * 0.6 - scenario.inflation * 0.3 - scenario.defense * 0.1;
    const realEstate = scenario.growth * 0.4 + scenario.inflation * 0.2 - scenario.defense * 0.1;
    const metals = scenario.inflation * 0.5 + scenario.defense * 0.3 - scenario.growth * 0.2;
    return { equities, realEstate, metals };
  }

  function normalizeImpact(value) {
    const normalized = (value + 10) / 20;
    return Math.min(Math.max(normalized, 0), 1);
  }

  function portfolioResilience(impacts) {
    const score = normalizeImpact(impacts.equities) * 0.5 + normalizeImpact(impacts.realEstate) * 0.3 + normalizeImpact(impacts.metals) * 0.2;
    return Math.min(Math.max(score, 0), 1);
  }

  function normalizedScore(value) {
    const normalized = (value + 10) / 20;
    return Math.min(Math.max(normalized, 0.05), 0.95);
  }

  function indicatorValue(kindId) {
    const indicator = state.snapshot?.macroOverview.indicators.find((item) => item.id === kindId);
    return indicator?.latestValue ?? 0;
  }

  function seedScenarioFromSnapshot(snapshot) {
    const inflation = snapshot.macroOverview.indicators.find((item) => item.id === "INFLATION")?.latestValue ?? 2;
    const growth = snapshot.macroOverview.indicators.find((item) => item.id === "GROWTH")?.latestValue ?? 1;
    const defense = snapshot.macroOverview.indicators.find((item) => item.id === "DEFENSE")?.latestValue ?? 2;
    return { inflation, growth, defense };
  }

  function renderMacroIndicator(indicator, region) {
    const card = makeEl("div", "metric");
    const header = makeEl("div", "row");
    header.append(makeEl("span", "label", indicator.title));
    header.append(makeEl("span", "pill", region));
    card.append(header);

    const latest = indicator.latestValue;
    const previous = indicator.previousValue;
    const hasLatest = Number.isFinite(latest);
    const hasPrevious = Number.isFinite(previous);
    const formatted = hasLatest ? `${formatNumber(latest, 1)}${indicator.unit}` : "-";
    card.append(makeEl("div", "value", formatted));

    let delta = "Kein Verlauf";
    if (hasLatest && hasPrevious) {
      const diff = latest - previous;
      const sign = diff >= 0 ? "+" : "";
      delta = `${sign}${formatNumber(diff, 1)}${indicator.unit} vs. Vorjahr`;
    }
    card.append(makeEl("p", "hint", delta));

    return card;
  }

  function renderMetalCard(metal) {
    const card = makeEl("div", "stack");

    const header = makeEl("div", "row");
    header.append(makeEl("h3", null, metal.name));
    header.append(makeEl("span", "pill", metal.symbol));
    card.append(header);

    const converted = convertCurrency(metal.price, metal.currency, state.settings.currency, state.fxRate);
    card.append(makeEl("div", "value", formatCurrency(converted, state.settings.currency)));

    const change = formatSignedPercent(metal.dailyChangePercentage);
    card.append(makeEl("p", "hint", `24h: ${change}`));

    return wrapInCard(card);
  }

  function renderMetric(label, value) {
    const card = makeEl("div", "metric");
    card.append(makeEl("span", "label", label));
    card.append(makeEl("span", "value", value));
    return card;
  }

  function renderInfoRow(title, text) {
    const row = makeEl("div", "stack");
    row.append(makeEl("span", "label", title));
    row.append(makeEl("p", "hint", text));
    return row;
  }

  function renderLegend(series) {
    const legend = makeEl("div", "legend");
    series.forEach((item) => {
      const entry = makeEl("span", "legend-item");
      const dot = makeEl("span", "dot", "");
      const colorClass = item.colorClass || legendColorClass(item.color);
      if (colorClass) dot.classList.add(colorClass);
      entry.append(dot, makeEl("span", "hint", item.label));
      legend.append(entry);
    });
    return legend;
  }

  function legendColorClass(color) {
    if (color === COLORS.accent) return "color-accent";
    if (color === COLORS.strong) return "color-strong";
    if (color === COLORS.info) return "color-info";
    if (color === COLORS.muted) return "color-muted";
    if (color === COLORS.subtle) return "color-subtle";
    return "color-accent";
  }

  function wrapInCard(content) {
    const card = makeEl("div", "card");
    card.append(content);
    return card;
  }

  function cardHeader(title, subtitle) {
    const wrapper = makeEl("div", "card-header");
    wrapper.append(makeEl("h2", null, title));
    if (subtitle) wrapper.append(makeEl("p", "hint", subtitle));
    return wrapper;
  }

  function makeEl(tag, className, text) {
    const element = document.createElement(tag);
    if (className) element.className = className;
    if (text !== undefined) element.textContent = text;
    return element;
  }

  function clearElement(element) {
    while (element.firstChild) {
      element.removeChild(element.firstChild);
    }
  }

  function makeProgress(value, tone) {
    const progress = document.createElement("progress");
    progress.max = 1;
    const safeValue = Number.isFinite(value) ? value : 0;
    progress.value = Math.min(Math.max(safeValue, 0), 1);
    progress.className = `progress ${tone}`;
    return progress;
  }

  function createLineChart(series, options = {}) {
    const width = 320;
    const height = 200;
    const padding = { top: 12, right: 16, bottom: 18, left: 24 };

    const allPoints = series.flatMap((item) => item.points);
    if (!allPoints.length) return makeEl("div", "chart-placeholder", TEXT.comparisonNoData);

    const minX = Math.min(...allPoints.map((point) => point.x));
    const maxX = Math.max(...allPoints.map((point) => point.x));
    const minY = Math.min(...allPoints.map((point) => point.y));
    const maxY = Math.max(...allPoints.map((point) => point.y));

    const spanX = maxX - minX || 1;
    const spanY = maxY - minY || 1;

    const scaleX = (x) => padding.left + ((x - minX) / spanX) * (width - padding.left - padding.right);
    const scaleY = (y) => height - padding.bottom - ((y - minY) / spanY) * (height - padding.top - padding.bottom);

    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    svg.setAttribute("viewBox", `0 0 ${width} ${height}`);
    svg.setAttribute("class", "chart");
    svg.setAttribute("role", "img");
    svg.setAttribute("aria-label", "Datenchart");

    if (options.showTodayMarker) {
      const currentYear = new Date().getFullYear();
      if (currentYear >= minX && currentYear <= maxX) {
        const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
        const x = scaleX(currentYear);
        line.setAttribute("x1", x);
        line.setAttribute("x2", x);
        line.setAttribute("y1", padding.top);
        line.setAttribute("y2", height - padding.bottom);
        line.setAttribute("stroke", COLORS.muted);
        line.setAttribute("stroke-dasharray", "4 4");
        svg.append(line);
      }
    }

    series.forEach((item) => {
      const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
      path.setAttribute("d", buildPath(item.points, scaleX, scaleY));
      path.setAttribute("fill", "none");
      path.setAttribute("stroke", item.color || COLORS.accent);
      path.setAttribute("stroke-width", "2.4");
      if (item.dashed) {
        path.setAttribute("stroke-dasharray", "6 4");
        path.setAttribute("opacity", "0.8");
      }
      svg.append(path);
    });

    return svg;
  }

  function buildPath(points, scaleX, scaleY) {
    return points
      .map((point, index) => {
        const x = scaleX(point.x).toFixed(2);
        const y = scaleY(point.y).toFixed(2);
        return `${index === 0 ? "M" : "L"}${x} ${y}`;
      })
      .join(" ");
  }

  function formatCurrency(value, currency) {
    if (!Number.isFinite(value)) return "-";
    try {
      return new Intl.NumberFormat("de-DE", {
        style: "currency",
        currency: currency || "EUR",
        maximumFractionDigits: 2
      }).format(value);
    } catch {
      return `${formatNumber(value, 2)} ${currency}`;
    }
  }

  function formatNumber(value, decimals) {
    if (!Number.isFinite(value)) return "-";
    return new Intl.NumberFormat("de-DE", {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals
    }).format(value);
  }

  function formatPercent(value) {
    return `${formatNumber(value, 2)}%`;
  }

  function formatSignedPercent(value) {
    if (!Number.isFinite(value)) return "-";
    const sign = value >= 0 ? "+" : "";
    return `${sign}${formatNumber(value, 2)}%`;
  }

  function formatDateTime(date) {
    return new Intl.DateTimeFormat("de-DE", {
      dateStyle: "medium",
      timeStyle: "short"
    }).format(date);
  }

  function convertCurrency(value, from, to, fxRate) {
    if (!Number.isFinite(value)) return value;
    if (from === to) return value;
    if (!fxRate || !Number.isFinite(fxRate.rate)) return value;
    if (from === "USD" && to === "EUR") return value / fxRate.rate;
    if (from === "EUR" && to === "USD") return value * fxRate.rate;
    return value;
  }

  function calcCagr(history) {
    const first = history[0];
    const last = history[history.length - 1];
    if (!first || !last || first.year === last.year) return "n/v";
    const years = last.year - first.year;
    const base = Math.max(last.value, 0.1) / Math.max(first.value, 0.1);
    const growth = Math.pow(base, 1 / years) - 1;
    return `${formatNumber(growth * 100, 1)}%`;
  }

  function calcProjectionDelta(history, projection) {
    const lastHistory = history[history.length - 1];
    const lastProjection = projection[projection.length - 1];
    if (!lastHistory || !lastProjection) return "n/v";
    const delta = (lastProjection.value - lastHistory.value) / Math.max(lastHistory.value, 0.1);
    return `${formatNumber(delta * 100, 1)}%`;
  }

  function convertToSet(list) {
    return Array.isArray(list) ? list : [];
  }

  function loadSettings() {
    const saved = readJson(STORAGE_KEYS.settings, null);
    if (!saved) {
      return { ...DEFAULT_SETTINGS };
    }
    return {
      currency: saved.currency === "USD" ? "USD" : "EUR",
      thresholdProfile: THRESHOLD_PROFILES[saved.thresholdProfile] ? saved.thresholdProfile : "standard",
      watchlistGeo: convertToSet(saved.watchlistGeo).filter(Boolean),
      watchlistFinancial: convertToSet(saved.watchlistFinancial).filter(Boolean),
      newsApiKey: saved.newsApiKey || ""
    };
  }

  function saveSettings() {
    writeJson(STORAGE_KEYS.settings, {
      currency: state.settings.currency,
      thresholdProfile: state.settings.thresholdProfile,
      watchlistGeo: state.settings.watchlistGeo,
      watchlistFinancial: state.settings.watchlistFinancial,
      newsApiKey: state.settings.newsApiKey
    });
  }

  function loadSnapshot() {
    const snapshot = readJson(STORAGE_KEYS.snapshot, null);
    if (!snapshot) return null;
    return snapshot;
  }

  function saveSnapshot(snapshot) {
    writeJson(STORAGE_KEYS.snapshot, snapshot);
    writeJson(STORAGE_KEYS.snapshotAt, state.lastSyncAt);
  }

  function readJson(key, fallback) {
    try {
      const raw = window.localStorage.getItem(key);
      if (!raw) return fallback;
      return JSON.parse(raw);
    } catch {
      return fallback;
    }
  }

  function writeJson(key, value) {
    try {
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch {
      // Ignore storage errors.
    }
  }

  function selectedMetal() {
    const metals = state.snapshot?.metals || [];
    if (!metals.length) return null;
    if (!state.selectedMetalId) return metals[0];
    return metals.find((metal) => metal.id === state.selectedMetalId) || metals[0];
  }

  function yearInstant(year) {
    return new Date(Date.UTC(year, 0, 1)).getTime();
  }

  function maybeNotify(events) {
    if (!("Notification" in window)) return;
    if (Notification.permission !== "granted") return;
    if (!events.length) return;

    const profile = THRESHOLD_PROFILES[state.settings.thresholdProfile] || THRESHOLD_PROFILES.standard;
    const topEvent = events.reduce((acc, event) => (event.severityScore > acc.severityScore ? event : acc), events[0]);
    if (topEvent.severityScore < profile.highRisk) return;

    const lastNotified = readJson(STORAGE_KEYS.lastNotified, "");
    if (lastNotified === topEvent.id) return;

    new Notification(`Krisenlage: ${topEvent.title}`, {
      body: `Region: ${topEvent.region}. Kategorie: ${categoryLabel(topEvent.category)}.`
    });

    writeJson(STORAGE_KEYS.lastNotified, topEvent.id);
  }

  function showToast(message) {
    if (!elements.toast || !elements.toastContent) return;
    elements.toastContent.textContent = message;
    elements.toast.hidden = false;
    window.clearTimeout(showToast.timeoutId);
    showToast.timeoutId = window.setTimeout(() => {
      elements.toast.hidden = true;
    }, 3200);
  }

  function renderWatchlist(container, list, activeList, type) {
    if (!container) return;
    clearElement(container);

    list.forEach((country) => {
      const wrapper = makeEl("label", "toggle");
      const label = makeEl("span", null, country.name);
      const input = document.createElement("input");
      input.type = "checkbox";
      input.checked = activeList.includes(country.code);
      input.value = country.code;
      input.dataset.watchlist = type;
      wrapper.append(label, input);
      container.append(wrapper);
    });
  }

  function makeSampleSnapshot() {
    const now = Date.now();
    return {
      metals: [
        {
          id: "XAU",
          name: "Gold",
        symbol: "XAU",
        price: 2328.2,
        dailyChangePercentage: 0.8,
        change: 18.6,
        currency: "USD",
        lastUpdated: now - 60 * 60 * 1000
      },
        {
          id: "XAG",
          name: "Silber",
        symbol: "XAG",
        price: 28.9,
        dailyChangePercentage: -0.3,
        change: -0.12,
        currency: "USD",
        lastUpdated: now - 60 * 60 * 1000
      }
      ],
      macroOverview: {
        indicators: [
          {
            id: "INFLATION",
            title: "Inflation",
            latestValue: 3.1,
            previousValue: 4.0,
            unit: "%",
            description: "Jaehrliche Verbraucherpreisinflation laut Weltbank"
          },
          {
            id: "GROWTH",
            title: "Wachstum",
            latestValue: 0.6,
            previousValue: 1.2,
            unit: "%",
            description: "Reales BIP-Wachstum"
          },
          {
            id: "DEFENSE",
            title: "Verteidigung",
            latestValue: 1.8,
            previousValue: 1.6,
            unit: "% BIP",
            description: "Militaerausgaben im Verhaeltnis zum BIP"
          }
        ]
      },
      macroSeries: [
        {
          kindId: "INFLATION",
          points: [
            { year: 2018, value: 1.8 },
            { year: 2019, value: 1.4 },
            { year: 2020, value: 0.5 },
            { year: 2021, value: 3.2 },
            { year: 2022, value: 6.9 },
            { year: 2023, value: 5.9 },
            { year: 2024, value: 3.1 }
          ]
        },
        {
          kindId: "GROWTH",
          points: [
            { year: 2018, value: 1.3 },
            { year: 2019, value: 0.6 },
            { year: 2020, value: -3.6 },
            { year: 2021, value: 2.1 },
            { year: 2022, value: 1.4 },
            { year: 2023, value: 0.8 },
            { year: 2024, value: 0.6 }
          ]
        },
        {
          kindId: "DEFENSE",
          points: [
            { year: 2018, value: 1.2 },
            { year: 2019, value: 1.3 },
            { year: 2020, value: 1.4 },
            { year: 2021, value: 1.5 },
            { year: 2022, value: 1.7 },
            { year: 2023, value: 1.8 },
            { year: 2024, value: 1.8 }
          ]
        }
      ],
      crises: [
        {
          id: "news-sample-1",
          title: "Bankenstress in Europa nimmt zu",
          summary: "Finanzielle Spannung in mehreren EU-Laendern.",
          region: "Europa",
          occurredAt: now - 3 * 60 * 60 * 1000,
          publishedAt: now - 3 * 60 * 60 * 1000,
          detailURL: "",
          sourceName: "NewsAPI",
          source: "NEWS_API",
          category: "FINANCIAL",
          severityScore: 6.0
        },
        {
          id: "geo-sample-ukr",
          title: "Politische Instabilitaet Ukraine",
          summary: "Governance-Index -1.1",
          region: "Ukraine",
          occurredAt: yearInstant(2024),
          publishedAt: yearInstant(2024),
          detailURL: "https://data.worldbank.org/indicator/PV.PSR.PIND",
          sourceName: "World Bank",
          source: "WORLD_BANK_GOVERNANCE",
          category: "GEOPOLITICAL",
          severityScore: 2.2
        },
        {
          id: "finance-sample-de",
          title: "Rezession Germany",
          summary: "Reales BIP-Wachstum -0.4%",
          region: "Germany",
          occurredAt: yearInstant(2024),
          publishedAt: yearInstant(2024),
          detailURL: "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG",
          sourceName: "World Bank",
          source: "WORLD_BANK_FINANCE",
          category: "FINANCIAL",
          severityScore: 0.4
        }
      ]
    };
  }

  function hashString(value) {
    let hash = 0;
    for (let i = 0; i < value.length; i += 1) {
      hash = (hash << 5) - hash + value.charCodeAt(i);
      hash |= 0;
    }
    return Math.abs(hash);
  }

  function $(selector, root = document) {
    return root.querySelector(selector);
  }

  function $$(selector, root = document) {
    return Array.from(root.querySelectorAll(selector));
  }
})();
