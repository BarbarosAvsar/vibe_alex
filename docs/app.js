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

  const SUPPORTED_LANGUAGES = ["de", "en", "fr", "es"];
  const DEFAULT_LANGUAGE = "de";
  const LOCALE_BY_LANGUAGE = {
    de: "de-DE",
    en: "en-US",
    fr: "fr-FR",
    es: "es-ES"
  };

  const THRESHOLD_PROFILES = {
    standard: { id: "standard", highRisk: 5.0, governanceCutoff: -0.5, recessionCutoff: 0.0 },
    sensitive: { id: "sensitive", highRisk: 4.5, governanceCutoff: -0.3, recessionCutoff: 0.5 },
    conservative: { id: "conservative", highRisk: 5.5, governanceCutoff: -0.7, recessionCutoff: -0.5 }
  };

  const WATCHLISTS = {
    geopolitical: ["UKR", "ISR", "TWN", "ZAF", "DEU"],
    financial: ["DEU", "USA", "GBR", "JPN", "CHN"]
  };

  const DEFAULT_SETTINGS = {
    currency: "EUR",
    language: DEFAULT_LANGUAGE,
    thresholdProfile: "standard",
    watchlistGeo: WATCHLISTS.geopolitical.slice(),
    watchlistFinancial: WATCHLISTS.financial.slice(),
    newsApiKey: ""
  };

  const MACRO_KINDS = [
    {
      id: "INFLATION",
      indicatorCode: "FP.CPI.TOTL.ZG",
      unit: "%"
    },
    {
      id: "GROWTH",
      indicatorCode: "NY.GDP.MKTP.KD.ZG",
      unit: "%"
    },
    {
      id: "DEFENSE",
      indicatorCode: "MS.MIL.XPND.GD.ZS",
      unit: "% BIP"
    }
  ];

  const MACRO_KIND_MAP = new Map(MACRO_KINDS.map((kind) => [kind.id, kind]));

  const COLORS = {
    accent: "#c7e8e3",
    strong: "rgba(199, 232, 227, 0.7)",
    info: "#c7e8e3",
    muted: "rgba(15, 28, 61, 0.6)",
    subtle: "rgba(15, 28, 61, 0.35)"
  };

  const MACRO_COMPARISON_REGIONS = [
    { iso: "DEU", label: "DE", color: COLORS.accent, colorClass: "color-accent" },
    { iso: "USA", label: "US", color: COLORS.strong, colorClass: "color-strong" },
    { iso: "GBR", label: "UK", color: COLORS.info, colorClass: "color-info" },
    { iso: "ESP", label: "ES", color: COLORS.muted, colorClass: "color-muted" }
  ];

  const ASSET_GROUPS = ["equities", "real_estate", "metals"];

  const COMPARISON_ASSETS = [
    { id: "EQUITY_DE", group: "equities", instrument: "^dax", color: COLORS.accent },
    { id: "EQUITY_USA", group: "equities", instrument: "^spx", color: COLORS.strong },
    { id: "EQUITY_LON", group: "equities", instrument: "^ftse", color: COLORS.info },
    { id: "REAL_ESTATE_DE", group: "real_estate", instrument: "iqq7.de", color: COLORS.accent },
    { id: "REAL_ESTATE_ES", group: "real_estate", instrument: "iqq7.de", color: COLORS.strong },
    { id: "REAL_ESTATE_FR", group: "real_estate", instrument: "iqq7.de", color: COLORS.info },
    { id: "REAL_ESTATE_LON", group: "real_estate", instrument: "vnq.us", color: COLORS.muted },
    { id: "GOLD", group: "metals", instrument: "xauusd", color: COLORS.strong },
    { id: "SILVER", group: "metals", instrument: "xagusd", color: COLORS.info }
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
      metalTrendMultiplier: 0.08
    },
    good: {
      id: "good",
      metalTrendMultiplier: 0.02
    },
    hard: {
      id: "hard",
      metalTrendMultiplier: 0.03
    }
  };

  const STRINGS_DE = {
    appName: "CRISIS 2050",
    skipLink: "Zum Inhalt springen",
    navLabel: "Hauptnavigation",
    refreshAriaLabel: "Daten aktualisieren",
    settingsAriaLabel: "Einstellungen öffnen",
    settingsCloseAriaLabel: "Einstellungen schließen",
    privacyCloseAriaLabel: "Datenschutzerklärung schließen",
    overviewHeaderTitle: "Übersicht",
    overviewHeaderSubtitle: "Vermögenssicherung, Edelmetalle und Makro-Lage auf einen Blick.",
    overviewCtaTitle: "Beratung anfragen",
    overviewCtaSubtitle: "Persönliche Einschätzung sichern",
    comparisonHeaderTitle: "Vergleich",
    comparisonHeaderSubtitle: "Asset-Klassen im historischen Vergleich und in der Prognose.",
    metalsHeaderTitle: "Edelmetalle",
    metalsHeaderSubtitle: "Preisfokus, Resilienz und langfristige Projektion bis 2050.",
    metalsCtaTitle: "Strategie besprechen",
    metalsCtaSubtitle: "Metallquote optimieren",
    crisisHeaderTitle: "Krisen",
    crisisHeaderSubtitle: "Geopolitische und finanzielle Warnsignale in Echtzeit.",
    crisisDetailHeaderTitle: "Krisen-Details",
    crisisDetailHeaderSubtitle: "Kontext und Zeitlinie zum ausgewählten Ereignis.",
    crisisDetailBack: "Zurück",
    consultationHeaderTitle: "Beratung",
    consultationHeaderSubtitle: "Individuelle Einschätzung zur Vermögenssicherung anfordern.",
    consultationFormTitle: "Kontakt",
    consultationNameLabel: "Name*",
    consultationEmailLabel: "E-Mail*",
    consultationPhoneLabel: "Telefon*",
    consultationMessageLabel: "Nachricht*",
    consultationSubmitLabel: "Anfrage senden",
    consultationFormHint: "Mit dem Absenden stimmen Sie der Verarbeitung Ihrer Angaben gemäß der Datenschutzerklärung zu.",
    settingsTitle: "Einstellungen",
    settingsSectionGeneral: "Allgemein",
    settingsCurrencyLabel: "Währung",
    settingsCurrencyHint: "Wechselkurs aus der EZB, Updates alle 12 Stunden.",
    settingsLanguageLabel: "App-Sprache",
    settingsLanguageHint: "Ändert die Sprache der Benutzeroberfläche.",
    settingsSectionWatchlist: "Krisen-Filter",
    settingsWatchlistGeopolitical: "Geopolitische Watchlist",
    settingsWatchlistFinancial: "Finanzielle Watchlist",
    settingsSectionThresholds: "Schwellenwerte",
    settingsThresholdLabel: "Schwellenwerte",
    settingsThresholdStandard: "Standard",
    settingsThresholdSensitive: "Sensibel",
    settingsThresholdConservative: "Konservativ",
    settingsThresholdHint: "Steuert, ab wann ein Ereignis als Hochrisiko markiert wird.",
    settingsSectionNotifications: "Benachrichtigungen",
    settingsNotificationsStatusLabel: "Status",
    settingsNotificationsHint: "Benachrichtigungen werden lokal verarbeitet.",
    settingsSectionPrivacy: "Datenschutz",
    settingsPrivacyButton: "Datenschutzerklärung",
    settingsPrivacyHint: "Kein Tracking, keine versteckten SDKs. Nur lokale Verarbeitung.",
    settingsNewsApiTitle: "NewsAPI (optional)",
    settingsNewsApiLabel: "API-Schlüssel",
    settingsNewsApiPlaceholder: "X-Api-Key",
    settingsNewsApiHint: "Wird nur lokal gespeichert und nie hochgeladen.",
    privacyTitle: "Datenschutzerklärung",
    noscriptMessage: "Bitte aktivieren Sie JavaScript, um die CRISIS 2050 Web-App zu verwenden.",
    languageLabels: {
      de: "Deutsch",
      en: "Englisch",
      fr: "Französisch",
      es: "Spanisch"
    },
    watchlistCountries: {
      UKR: "Ukraine",
      ISR: "Israel",
      TWN: "Taiwan",
      ZAF: "Südafrika",
      DEU: "Deutschland",
      USA: "USA",
      GBR: "Vereinigtes Königreich",
      JPN: "Japan",
      CHN: "China"
    },
    assetGroups: {
      equities: "Aktienmärkte",
      real_estate: "Immobilienpreise",
      metals: "Edelmetalle"
    },
    assetLabels: {
      EQUITY_DE: "Deutschland Aktien",
      EQUITY_USA: "USA Aktien",
      EQUITY_LON: "London Aktien",
      REAL_ESTATE_DE: "Deutschland Immobilien",
      REAL_ESTATE_ES: "Spanien Immobilien",
      REAL_ESTATE_FR: "Frankreich Immobilien",
      REAL_ESTATE_LON: "London Immobilien",
      GOLD: "Gold",
      SILVER: "Silber"
    },
    macroKinds: {
      INFLATION: {
        title: "Inflation",
        description: "Jährliche Verbraucherpreisinflation laut Weltbank",
        unit: "%"
      },
      GROWTH: {
        title: "Wachstum",
        description: "Reales BIP-Wachstum",
        unit: "%"
      },
      DEFENSE: {
        title: "Verteidigung",
        description: "Militärausgaben im Verhältnis zum BIP",
        unit: "% BIP"
      }
    },
    bennerPhases: {
      panic: {
        title: "Panikjahr",
        subtitle: "Extremer Verkaufsdruck - Phase A",
        guidance: "Historisch folgten auf diese Jahre heftige Markteinbrüche. Liquidität sichern und Risiko begrenzen."
      },
      good: {
        title: "Gute Zeiten",
        subtitle: "Hohe Preise - Phase B (Verkäufe bevorzugt)",
        guidance: "Überdurchschnittliche Bewertungen. Gewinne sichern und Exposure reduzieren."
      },
      hard: {
        title: "Schwere Zeiten",
        subtitle: "Niedrige Preise - Phase C (Akkumulation)",
        guidance: "Marktpreise gelten als günstig. Positionsaufbau und Sparpläne bieten sich an."
      }
    },
    heroTitle: "Vermögenssicherung",
    heroSubtitle: "Aktuelle Prognose",
    heroLabel: "Prognose",
    heroHint: "Vorsicht empfohlen - Absicherung priorisieren.",
    metalsFocusTitle: "Edelmetalle im Fokus",
    metalsFocusSubtitle: "Gold & Silber im aktuellen Marktumfeld",
    macroTitle: "Makro-Lage",
    macroSubtitle: "Inflation, Wechsel & Wachstum je Region",
    whyMetalsTitle: "Warum Edelmetalle und Struktur",
    whyMetalsBullets: [
      "Physischer Wert, unabhängig von Währungen",
      "Schutz vor Inflation und Kaufkraftverlust",
      "Stabilität in Kriegen und Wirtschaftskrisen",
      "Strukturierter Vermögensschutz durch planbare Allokation",
      "Sichere Lagerung im Zollfreilager außerhalb des Bankensystems"
    ],
    comparisonSectionTitle: "Asset-Klassen-Vergleich",
    comparisonSectionSubtitle: "Historisch & Prognose 2025–2050",
    comparisonModeHistory: "Historisch",
    comparisonModeForecast: "Prognose",
    comparisonChartTitle: "Wertentwicklung",
    comparisonChartSubtitle: "Tippen Sie auf den Chart, um Details zu sehen.",
    comparisonPerformanceTitle: "Performance-Übersicht",
    comparisonPerformanceSubtitle: "Historisch und Prognose",
    comparisonPerformanceFormat: "Historisch %s / Prognose %s",
    comparisonNoData: "Keine Marktdaten verfügbar.",
    comparisonLoading: "Lade Marktdaten…",
    comparisonMacroTitle: "Makro-Vergleich",
    comparisonMacroSubtitle: "Regionale Trends nebeneinander",
    comparisonMacroLoading: "Lade Makro-Daten.",
    comparisonMacroNoData: "Keine Makro-Daten verfügbar.",
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
    metalsSelectorTitle: "Edelmetall auswählen",
    metalInsight24h: "24h",
    metalInsightChange: "Veränderung",
    metalsUpdatedLabel: "Stand: %s",
    metalsProjectionTitle: "Prognose für 3 Jahre",
    metalsProjectionSubtitle: "%s Ausblick",
    metalsTrendTitle: "Historisch & Prognose bis 2050",
    metalsTrendSubtitle: "Indexentwicklung %s",
    metalsTrendHistoryLabel: "%s Historie",
    metalsTrendForecastLabel: "%s Prognose",
    metalsTrendLoading: "Lade Marktdaten…",
    metalsResilienceTitle: "Resilienz in Krisen",
    metalsResilienceSubtitle: "%s in unterschiedlichen Szenarien",
    metalsScenarioInflation: "Inflation",
    metalsScenarioInflationDetail: "%s reagiert historisch positiv auf steigende Verbraucherpreise.",
    metalsScenarioWars: "Kriege",
    metalsScenarioWarsDetail: "Geopolitische Spannungen erhöhen die Nachfrage nach sicheren Häfen.",
    metalsScenarioRecession: "Wirtschaftskrisen",
    metalsScenarioRecessionDetail: "In Rezessionen dient %s als Liquiditätsreserve.",
    metalsBadgeProtection: "Schutz",
    metalsBadgeShield: "Absicherung",
    metalsBadgeDiversification: "Diversifikation",
    crisisOverviewTitle: "Krisenlage",
    crisisOverviewSubtitle: "Aktuelle Hinweise aus externen Quellen",
    crisisOverviewEmpty: "Keine aktuellen Hinweise.",
    crisisFeedTitle: "Krisen-Feed",
    crisisFeedSubtitle: "Meldungen aus NewsAPI und der World Bank",
    crisisFeedEmpty: "Keine aktuellen Krisenmeldungen.",
    crisisCategoryFinancial: "Finanzen",
    crisisCategoryGeopolitical: "Geopolitik",
    crisisBadgeInfo: "Info",
    crisisBadgeModerate: "Moderat",
    crisisBadgeHigh: "Hoch",
    crisisDetailTitle: "Krisen-Details",
    crisisDetailMissing: "Ereignis nicht gefunden.",
    crisisDetailTimeline: "Zeitachse",
    crisisDetailOpenSource: "Quelle öffnen",
    crisisDetailTimeLabel: "Zeitpunkt: %s",
    crisisDetailSourceLabel: "Quelle: %s",
    crisisEventTitleGovernance: "Politische Instabilität in %s",
    crisisEventTitleRecession: "Rezession in %s",
    crisisGovernanceSummary: "Governance-Index %s",
    crisisRecessionSummary: "Reales BIP-Wachstum %s%",
    regionGlobal: "Weltweit",
    regionEurope: "Europa",
    sampleNewsTitle: "Bankenstress in Europa nimmt zu",
    sampleNewsSummary: "Finanzielle Spannungen in mehreren EU-Ländern.",
    consultationExpectationsTitle: "Was Sie erwartet",
    consultationExpectations: [
      "Kostenlose Erstberatung durch Edelmetall-Experten",
      "Individuelle Vermögensstrukturierung",
      "Informationen zur Zollfreilager-Lagerung",
      "Steuerliche Aspekte und rechtliche Absicherung"
    ],
    consultationMoreInfoTitle: "Weitere Informationen",
    consultationInfo1Title: "Zollfreilager-Lagerung",
    consultationInfo1Text: "Physische Trennung vom Bankensystem, Versicherung und 24/7 Überwachung für maximale Sicherheit und Flexibilität.",
    consultationInfo2Title: "Wert - Struktur gewinnt",
    consultationInfo2Text: "Klare Allokation in Edelmetalle schafft Stabilität in Inflation, Währungsreformen und Krisen.",
    consultationPrivacyNote:
      "Mit dem Absenden stimmen Sie zu, dass wir Ihre Anfrage gemäß Datenschutzerklärung beantworten. Wir speichern keine Daten dauerhaft auf diesem Gerät.",
    consultationSuccessTitle: "Vielen Dank",
    consultationSuccessMessage: "Ihre Anfrage wurde gesendet. Wir melden uns zeitnah.",
    consultationFailureTitle: "Senden fehlgeschlagen",
    consultationFailureMessage: "Fehler beim Senden der Anfrage.",
    consultationErrorName: "Bitte geben Sie Ihren Namen an.",
    consultationErrorEmail: "Bitte geben Sie eine gültige E-Mail-Adresse an.",
    consultationErrorPhone: "Bitte geben Sie Ihre Telefonnummer an.",
    consultationErrorMessage: "Ihre Nachricht sollte mindestens 10 Zeichen enthalten.",
    notificationsActive: "Aktiv",
    notificationsDenied: "Deaktiviert",
    notificationsUnknown: "Unbekannt",
    notificationsActiveDesc: "Sie erhalten Warnhinweise bei Prognose-Wechseln oder größeren Krisen.",
    notificationsDeniedDesc: "Benachrichtigungen sind ausgeschaltet. Aktivieren Sie sie in den Browser-Einstellungen.",
    notificationsUnknownDesc: "Noch keine Berechtigung angefragt.",
    notificationsActionEnable: "Benachrichtigungen aktivieren",
    notificationsActionOpenSettings: "Browser-Einstellungen öffnen",
    notificationsCrisisTitle: "Krisenlage: %s",
    notificationsCrisisBody: "Region: %s. Kategorie: %s.",
    notificationsUnsupportedStatus: "Nicht verfügbar",
    notificationsUnsupportedDescription: "Dieser Browser unterstützt keine Benachrichtigungen.",
    notificationsUnsupportedToast: "Benachrichtigungen sind in diesem Browser nicht verfügbar.",
    notificationsEnabledToast: "Benachrichtigungen aktiviert.",
    notificationsSettingsToast: "Bitte aktivieren Sie Benachrichtigungen in den Browser-Einstellungen.",
    privacyIntro:
      "Wir verarbeiten Ihre Daten ausschließlich auf dem Gerät oder über den Versand Ihrer Anfrage. Es gibt keine versteckten Tracker oder Cloud-Profile.",
    privacySections: [
      {
        title: "Verantwortliche Stelle",
        body: "VermögensKompass (Vibecode GmbH) verarbeitet ausschließlich die Daten, die Sie aktiv teilen."
      },
      {
        title: "Datenerhebung im Überblick",
        body: [
          "Markt- und Krisendaten stammen aus offen zugänglichen APIs (World Bank, USGS, NOAA, GoldPrice.org) und werden nur lokal ausgewertet.",
          "Wir speichern keine personenbezogenen Daten auf unseren Servern."
        ]
      },
      {
        title: "Kontaktaufnahme",
        body:
          "Wenn Sie auf \"Beratung anfragen\" tippen, senden wir Ihre Nachricht an unser Beratungsteam. Der Versand erfolgt über eine gesicherte Verbindung; wir speichern dabei keine Kopie."
      },
      {
        title: "Benachrichtigungen",
        body:
          "Krisen-Benachrichtigungen werden ausschließlich auf Ihrem Gerät verarbeitet. Sie können die Berechtigung jederzeit in den Browser-Einstellungen widerrufen."
      },
      {
        title: "Analytics & Tracking",
        body:
          "Kein Tracking, keine Drittanbieter-SDKs. Die App funktioniert vollständig offline mit den zuletzt synchronisierten Daten."
      },
      {
        title: "Ihre Rechte",
        body:
          "Sie können Auskunft, Berichtigung oder Löschung Ihrer Kontaktaufnahme verlangen, indem Sie uns unter datenschutz@vermoegenskompass.de kontaktieren."
      }
    ],
    crisisSummaryHeadlineNone: "Keine Hochrisiko-Ereignisse erkennbar",
    crisisSummaryHeadlineCountOne: "%s Hochrisiko-Ereignis aktiv",
    crisisSummaryHeadlineCountOther: "%s Hochrisiko-Ereignisse aktiv",
    crisisSummaryHighlightRegion: "%sx Ereignisse in %s",
    crisisSummaryHighlightCategory: "%sx Kategorie %s",
    crisisSummaryHighlightLatest: "Zuletzt %s um %s",
    syncBannerWithTime: "Offline: letzte Synchronisierung %s.",
    syncBannerWithoutTime: "Offline: letzte Synchronisierung.",
    syncPartialOffline: "Teilweise offline (%s)",
    syncFailed: "Synchronisierung fehlgeschlagen",
    offlineToastPrefix: "Offline: %s",
    syncFailureMetals: "Metalle",
    syncFailureMacro: "Makro",
    syncFailureCrisis: "Krisen",
    notAvailableShort: "k. A.",
    macroDeltaNoTrend: "Kein Verlauf",
    macroDeltaVsPrevious: "%s%s%s vs. Vorjahr",
    chartAriaLabel: "Datenchart"
  };

  const STRINGS = { de: STRINGS_DE };

  STRINGS.en = {
    appName: "CRISIS 2050",
    skipLink: "Skip to content",
    navLabel: "Main navigation",
    refreshAriaLabel: "Refresh data",
    settingsAriaLabel: "Open settings",
    settingsCloseAriaLabel: "Close settings",
    privacyCloseAriaLabel: "Close privacy policy",
    overviewHeaderTitle: "Overview",
    overviewHeaderSubtitle: "Wealth protection, precious metals, and macro outlook at a glance.",
    overviewCtaTitle: "Request consultation",
    overviewCtaSubtitle: "Secure a personal assessment",
    comparisonHeaderTitle: "Comparison",
    comparisonHeaderSubtitle: "Asset classes in historical comparison and forecast.",
    metalsHeaderTitle: "Metals",
    metalsHeaderSubtitle: "Price focus, resilience, and long-term projection to 2050.",
    metalsCtaTitle: "Discuss strategy",
    metalsCtaSubtitle: "Optimize metal allocation",
    crisisHeaderTitle: "Crises",
    crisisHeaderSubtitle: "Geopolitical and financial warning signals in real time.",
    crisisDetailHeaderTitle: "Crisis details",
    crisisDetailHeaderSubtitle: "Context and timeline for the selected event.",
    crisisDetailBack: "Back",
    consultationHeaderTitle: "Consultation",
    consultationHeaderSubtitle: "Request a personalized assessment for wealth protection.",
    consultationFormTitle: "Contact",
    consultationNameLabel: "Name*",
    consultationEmailLabel: "Email*",
    consultationPhoneLabel: "Phone*",
    consultationMessageLabel: "Message*",
    consultationSubmitLabel: "Send request",
    consultationFormHint: "By submitting, you agree to the processing of your details in accordance with the privacy policy.",
    settingsTitle: "Settings",
    settingsSectionGeneral: "General",
    settingsCurrencyLabel: "Currency",
    settingsCurrencyHint: "ECB exchange rate, updates every 12 hours.",
    settingsLanguageLabel: "App language",
    settingsLanguageHint: "Changes the interface language.",
    settingsSectionWatchlist: "Crisis filters",
    settingsWatchlistGeopolitical: "Geopolitical watchlist",
    settingsWatchlistFinancial: "Financial watchlist",
    settingsSectionThresholds: "Thresholds",
    settingsThresholdLabel: "Thresholds",
    settingsThresholdStandard: "Standard",
    settingsThresholdSensitive: "Sensitive",
    settingsThresholdConservative: "Conservative",
    settingsThresholdHint: "Controls when an event is flagged as high risk.",
    settingsSectionNotifications: "Notifications",
    settingsNotificationsStatusLabel: "Status",
    settingsNotificationsHint: "Notifications are processed locally.",
    settingsSectionPrivacy: "Privacy",
    settingsPrivacyButton: "Privacy policy",
    settingsPrivacyHint: "No tracking, no hidden SDKs. Local processing only.",
    settingsNewsApiTitle: "NewsAPI (optional)",
    settingsNewsApiLabel: "API key",
    settingsNewsApiPlaceholder: "X-Api-Key",
    settingsNewsApiHint: "Stored locally only and never uploaded.",
    privacyTitle: "Privacy policy",
    noscriptMessage: "Please enable JavaScript to use the CRISIS 2050 web app.",
    languageLabels: {
      de: "German",
      en: "English",
      fr: "French",
      es: "Spanish"
    },
    watchlistCountries: {
      UKR: "Ukraine",
      ISR: "Israel",
      TWN: "Taiwan",
      ZAF: "South Africa",
      DEU: "Germany",
      USA: "United States",
      GBR: "United Kingdom",
      JPN: "Japan",
      CHN: "China"
    },
    assetGroups: {
      equities: "Equity markets",
      real_estate: "Real estate prices",
      metals: "Metals"
    },
    assetLabels: {
      EQUITY_DE: "Germany equities",
      EQUITY_USA: "US equities",
      EQUITY_LON: "London equities",
      REAL_ESTATE_DE: "Germany real estate",
      REAL_ESTATE_ES: "Spain real estate",
      REAL_ESTATE_FR: "France real estate",
      REAL_ESTATE_LON: "London real estate",
      GOLD: "Gold",
      SILVER: "Silver"
    },
    macroKinds: {
      INFLATION: {
        title: "Inflation",
        description: "Annual consumer price inflation (World Bank)",
        unit: "%"
      },
      GROWTH: {
        title: "Growth",
        description: "Real GDP growth",
        unit: "%"
      },
      DEFENSE: {
        title: "Defense",
        description: "Military spending as a share of GDP",
        unit: "% of GDP"
      }
    },
    bennerPhases: {
      panic: {
        title: "Panic year",
        subtitle: "Extreme selling pressure - Phase A",
        guidance: "Historically, these years were followed by sharp market drops. Secure liquidity and limit risk."
      },
      good: {
        title: "Good times",
        subtitle: "High prices - Phase B (prefer selling)",
        guidance: "Above-average valuations. Lock in gains and reduce exposure."
      },
      hard: {
        title: "Hard times",
        subtitle: "Low prices - Phase C (accumulation)",
        guidance: "Prices look favorable. Building positions and savings plans make sense."
      }
    },
    heroTitle: "Wealth protection",
    heroSubtitle: "Current outlook",
    heroLabel: "Outlook",
    heroHint: "Caution advised - prioritize protection.",
    metalsFocusTitle: "Metals in focus",
    metalsFocusSubtitle: "Gold & silver in the current market context",
    macroTitle: "Macro outlook",
    macroSubtitle: "Inflation, FX & growth by region",
    whyMetalsTitle: "Why metals and structure",
    whyMetalsBullets: [
      "Physical value independent of currencies",
      "Protection against inflation and loss of purchasing power",
      "Stability in wars and economic crises",
      "Structured wealth protection through planned allocation",
      "Secure storage in bonded warehouses outside the banking system"
    ],
    comparisonSectionTitle: "Asset class comparison",
    comparisonSectionSubtitle: "Historical & forecast 2025–2050",
    comparisonModeHistory: "History",
    comparisonModeForecast: "Forecast",
    comparisonChartTitle: "Value development",
    comparisonChartSubtitle: "Tap the chart to see details.",
    comparisonPerformanceTitle: "Performance overview",
    comparisonPerformanceSubtitle: "Historical and forecast",
    comparisonPerformanceFormat: "History %s / Forecast %s",
    comparisonNoData: "No market data available.",
    comparisonLoading: "Loading market data…",
    comparisonMacroTitle: "Macro comparison",
    comparisonMacroSubtitle: "Regional trends side by side",
    comparisonMacroLoading: "Loading macro data.",
    comparisonMacroNoData: "No macro data available.",
    comparisonScenarioTitle: "Scenario lab",
    comparisonScenarioSubtitle: "Adjust inflation, growth, and defense",
    scenarioInflation: "Inflation (%)",
    scenarioGrowth: "Growth (%)",
    scenarioDefense: "Defense (% of GDP)",
    scenarioEquities: "Equities",
    scenarioRealEstate: "Real estate",
    scenarioMetals: "Metals",
    portfolioTitle: "Portfolio resilience",
    portfolioSubtitle: "Mix of equities, real estate, and metals",
    metalsSelectorTitle: "Select metal",
    metalInsight24h: "24h",
    metalInsightChange: "Change",
    metalsUpdatedLabel: "Updated: %s",
    metalsProjectionTitle: "3-year projection",
    metalsProjectionSubtitle: "%s outlook",
    metalsTrendTitle: "History & forecast through 2050",
    metalsTrendSubtitle: "Index performance %s",
    metalsTrendHistoryLabel: "%s history",
    metalsTrendForecastLabel: "%s forecast",
    metalsTrendLoading: "Loading market data…",
    metalsResilienceTitle: "Resilience in crises",
    metalsResilienceSubtitle: "%s across scenarios",
    metalsScenarioInflation: "Inflation",
    metalsScenarioInflationDetail: "%s historically responds positively to rising consumer prices.",
    metalsScenarioWars: "Wars",
    metalsScenarioWarsDetail: "Geopolitical tensions increase demand for safe havens.",
    metalsScenarioRecession: "Recessions",
    metalsScenarioRecessionDetail: "In recessions, %s serves as a liquidity reserve.",
    metalsBadgeProtection: "Protection",
    metalsBadgeShield: "Hedge",
    metalsBadgeDiversification: "Diversification",
    crisisOverviewTitle: "Crisis situation",
    crisisOverviewSubtitle: "Current signals from external sources",
    crisisOverviewEmpty: "No current signals.",
    crisisFeedTitle: "Crisis feed",
    crisisFeedSubtitle: "Stories from NewsAPI and the World Bank",
    crisisFeedEmpty: "No current crisis headlines.",
    crisisCategoryFinancial: "Financial",
    crisisCategoryGeopolitical: "Geopolitical",
    crisisBadgeInfo: "Info",
    crisisBadgeModerate: "Moderate",
    crisisBadgeHigh: "High",
    crisisDetailTitle: "Crisis details",
    crisisDetailMissing: "Event not found.",
    crisisDetailTimeline: "Timeline",
    crisisDetailOpenSource: "Open source",
    crisisDetailTimeLabel: "Time: %s",
    crisisDetailSourceLabel: "Source: %s",
    crisisEventTitleGovernance: "Political instability in %s",
    crisisEventTitleRecession: "Recession in %s",
    crisisGovernanceSummary: "Governance index %s",
    crisisRecessionSummary: "Real GDP growth %s%",
    regionGlobal: "Global",
    regionEurope: "Europe",
    sampleNewsTitle: "Banking stress in Europe intensifies",
    sampleNewsSummary: "Financial tensions rise across several EU countries.",
    consultationExpectationsTitle: "What to expect",
    consultationExpectations: [
      "Free initial consultation with precious metal experts",
      "Individual wealth structuring",
      "Information on bonded warehouse storage",
      "Tax considerations and legal safeguards"
    ],
    consultationMoreInfoTitle: "More information",
    consultationInfo1Title: "Bonded warehouse storage",
    consultationInfo1Text:
      "Physical separation from the banking system, insurance, and 24/7 monitoring for maximum security and flexibility.",
    consultationInfo2Title: "Value - structure wins",
    consultationInfo2Text: "Clear allocation to precious metals creates stability in inflation, currency reforms, and crises.",
    consultationPrivacyNote:
      "By submitting, you agree that we respond to your request in accordance with the privacy policy. We do not store any data permanently on this device.",
    consultationSuccessTitle: "Thank you",
    consultationSuccessMessage: "Your request was sent. We will get back to you soon.",
    consultationFailureTitle: "Send failed",
    consultationFailureMessage: "Failed to send the request.",
    consultationErrorName: "Please enter your name.",
    consultationErrorEmail: "Please enter a valid email address.",
    consultationErrorPhone: "Please enter your phone number.",
    consultationErrorMessage: "Your message should be at least 10 characters.",
    notificationsActive: "Active",
    notificationsDenied: "Disabled",
    notificationsUnknown: "Unknown",
    notificationsActiveDesc: "You will receive alerts when forecasts change or when major crises emerge.",
    notificationsDeniedDesc: "Notifications are turned off. Enable them in your browser settings.",
    notificationsUnknownDesc: "Permission has not been requested yet.",
    notificationsActionEnable: "Enable notifications",
    notificationsActionOpenSettings: "Open browser settings",
    notificationsCrisisTitle: "Crisis alert: %s",
    notificationsCrisisBody: "Region: %s. Category: %s.",
    notificationsUnsupportedStatus: "Unavailable",
    notificationsUnsupportedDescription: "This browser does not support notifications.",
    notificationsUnsupportedToast: "Notifications are not available in this browser.",
    notificationsEnabledToast: "Notifications enabled.",
    notificationsSettingsToast: "Please enable notifications in the browser settings.",
    privacyIntro:
      "We process your data exclusively on your device or when sending your request. There are no hidden trackers or cloud profiles.",
    privacySections: [
      {
        title: "Responsible entity",
        body: "VermögensKompass (Vibecode GmbH) processes only the data you actively share."
      },
      {
        title: "Data collection overview",
        body: [
          "Market and crisis data come from publicly accessible APIs (World Bank, USGS, NOAA, GoldPrice.org) and are evaluated locally.",
          "We do not store personal data on our servers."
        ]
      },
      {
        title: "Contact",
        body:
          "When you tap \"Request consultation\", we send your message to our advisory team. The transfer is secured; we do not store a copy."
      },
      {
        title: "Notifications",
        body: "Crisis notifications are processed exclusively on your device. You can revoke permission anytime in your browser settings."
      },
      {
        title: "Analytics & tracking",
        body: "No tracking, no third-party SDKs. The app works fully offline with the latest synced data."
      },
      {
        title: "Your rights",
        body:
          "You can request access, correction, or deletion of your contact data by writing to datenschutz@vermoegenskompass.de."
      }
    ],
    crisisSummaryHeadlineNone: "No high-risk events detected",
    crisisSummaryHeadlineCountOne: "%s high-risk event active",
    crisisSummaryHeadlineCountOther: "%s high-risk events active",
    crisisSummaryHighlightRegion: "%sx events in %s",
    crisisSummaryHighlightCategory: "%sx category %s",
    crisisSummaryHighlightLatest: "Latest %s at %s",
    syncBannerWithTime: "Offline: last sync %s.",
    syncBannerWithoutTime: "Offline: last sync.",
    syncPartialOffline: "Partially offline (%s)",
    syncFailed: "Sync failed",
    offlineToastPrefix: "Offline: %s",
    syncFailureMetals: "Metals",
    syncFailureMacro: "Macro",
    syncFailureCrisis: "Crises",
    notAvailableShort: "n/a",
    macroDeltaNoTrend: "No trend",
    macroDeltaVsPrevious: "%s%s%s vs. previous year",
    chartAriaLabel: "Data chart"
  };

  STRINGS.fr = {
    appName: "CRISIS 2050",
    skipLink: "Aller au contenu",
    navLabel: "Navigation principale",
    refreshAriaLabel: "Actualiser les données",
    settingsAriaLabel: "Ouvrir les paramètres",
    settingsCloseAriaLabel: "Fermer les paramètres",
    privacyCloseAriaLabel: "Fermer la politique de confidentialité",
    overviewHeaderTitle: "Aperçu",
    overviewHeaderSubtitle: "Protection du patrimoine, métaux précieux et contexte macro en un coup d’œil.",
    overviewCtaTitle: "Demander une consultation",
    overviewCtaSubtitle: "Obtenir une évaluation personnalisée",
    comparisonHeaderTitle: "Comparaison",
    comparisonHeaderSubtitle: "Classes d’actifs en comparaison historique et en prévision.",
    metalsHeaderTitle: "Métaux",
    metalsHeaderSubtitle: "Focus prix, résilience et projection à long terme jusqu’en 2050.",
    metalsCtaTitle: "Discuter de la stratégie",
    metalsCtaSubtitle: "Optimiser la part de métaux",
    crisisHeaderTitle: "Crises",
    crisisHeaderSubtitle: "Signaux d’alerte géopolitiques et financiers en temps réel.",
    crisisDetailHeaderTitle: "Détails de crise",
    crisisDetailHeaderSubtitle: "Contexte et chronologie de l’événement sélectionné.",
    crisisDetailBack: "Retour",
    consultationHeaderTitle: "Conseil",
    consultationHeaderSubtitle: "Demander une évaluation personnalisée de la protection patrimoniale.",
    consultationFormTitle: "Contact",
    consultationNameLabel: "Nom*",
    consultationEmailLabel: "E-mail*",
    consultationPhoneLabel: "Téléphone*",
    consultationMessageLabel: "Message*",
    consultationSubmitLabel: "Envoyer la demande",
    consultationFormHint: "En envoyant, vous acceptez le traitement de vos informations conformément à la politique de confidentialité.",
    settingsTitle: "Paramètres",
    settingsSectionGeneral: "Général",
    settingsCurrencyLabel: "Devise",
    settingsCurrencyHint: "Taux de change de la BCE, mise à jour toutes les 12 heures.",
    settingsLanguageLabel: "Langue de l’application",
    settingsLanguageHint: "Modifie la langue de l’interface.",
    settingsSectionWatchlist: "Filtres de crise",
    settingsWatchlistGeopolitical: "Watchlist géopolitique",
    settingsWatchlistFinancial: "Watchlist financière",
    settingsSectionThresholds: "Seuils",
    settingsThresholdLabel: "Seuils",
    settingsThresholdStandard: "Standard",
    settingsThresholdSensitive: "Sensible",
    settingsThresholdConservative: "Conservateur",
    settingsThresholdHint: "Définit quand un événement est marqué comme à haut risque.",
    settingsSectionNotifications: "Notifications",
    settingsNotificationsStatusLabel: "Statut",
    settingsNotificationsHint: "Les notifications sont traitées localement.",
    settingsSectionPrivacy: "Confidentialité",
    settingsPrivacyButton: "Politique de confidentialité",
    settingsPrivacyHint: "Pas de suivi, pas de SDK cachés. Traitement local uniquement.",
    settingsNewsApiTitle: "NewsAPI (optionnel)",
    settingsNewsApiLabel: "Clé API",
    settingsNewsApiPlaceholder: "X-Api-Key",
    settingsNewsApiHint: "Enregistrée localement uniquement et jamais téléchargée.",
    privacyTitle: "Politique de confidentialité",
    noscriptMessage: "Veuillez activer JavaScript pour utiliser l’application web CRISIS 2050.",
    languageLabels: {
      de: "Allemand",
      en: "Anglais",
      fr: "Français",
      es: "Espagnol"
    },
    watchlistCountries: {
      UKR: "Ukraine",
      ISR: "Israël",
      TWN: "Taïwan",
      ZAF: "Afrique du Sud",
      DEU: "Allemagne",
      USA: "États-Unis",
      GBR: "Royaume-Uni",
      JPN: "Japon",
      CHN: "Chine"
    },
    assetGroups: {
      equities: "Marchés actions",
      real_estate: "Prix immobiliers",
      metals: "Métaux"
    },
    assetLabels: {
      EQUITY_DE: "Actions Allemagne",
      EQUITY_USA: "Actions États-Unis",
      EQUITY_LON: "Actions Londres",
      REAL_ESTATE_DE: "Immobilier Allemagne",
      REAL_ESTATE_ES: "Immobilier Espagne",
      REAL_ESTATE_FR: "Immobilier France",
      REAL_ESTATE_LON: "Immobilier Londres",
      GOLD: "Or",
      SILVER: "Argent"
    },
    macroKinds: {
      INFLATION: {
        title: "Inflation",
        description: "Inflation annuelle des prix à la consommation (Banque mondiale)",
        unit: "%"
      },
      GROWTH: {
        title: "Croissance",
        description: "Croissance réelle du PIB",
        unit: "%"
      },
      DEFENSE: {
        title: "Défense",
        description: "Dépenses militaires en pourcentage du PIB",
        unit: "% du PIB"
      }
    },
    bennerPhases: {
      panic: {
        title: "Année de panique",
        subtitle: "Pression de vente extrême - Phase A",
        guidance:
          "Historiquement, ces années ont été suivies de fortes baisses de marché. Sécurisez la liquidité et limitez le risque."
      },
      good: {
        title: "Bonnes périodes",
        subtitle: "Prix élevés - Phase B (ventes privilégiées)",
        guidance: "Valorisations au-dessus de la moyenne. Sécurisez les gains et réduisez l’exposition."
      },
      hard: {
        title: "Périodes difficiles",
        subtitle: "Prix bas - Phase C (accumulation)",
        guidance: "Les prix semblent favorables. Accumuler des positions et plans d’épargne est pertinent."
      }
    },
    heroTitle: "Protection du patrimoine",
    heroSubtitle: "Prévision actuelle",
    heroLabel: "Prévision",
    heroHint: "Prudence recommandée - prioriser la protection.",
    metalsFocusTitle: "Métaux en focus",
    metalsFocusSubtitle: "Or & argent dans le contexte de marché actuel",
    macroTitle: "Panorama macro",
    macroSubtitle: "Inflation, change & croissance par région",
    whyMetalsTitle: "Pourquoi métaux et structure",
    whyMetalsBullets: [
      "Valeur physique indépendante des devises",
      "Protection contre l’inflation et la perte de pouvoir d’achat",
      "Stabilité en guerres et crises économiques",
      "Protection patrimoniale structurée via une allocation planifiée",
      "Stockage sécurisé en entrepôt sous douane hors système bancaire"
    ],
    comparisonSectionTitle: "Comparaison des classes d’actifs",
    comparisonSectionSubtitle: "Historique & prévision 2025–2050",
    comparisonModeHistory: "Historique",
    comparisonModeForecast: "Prévision",
    comparisonChartTitle: "Évolution de la valeur",
    comparisonChartSubtitle: "Touchez le graphique pour voir les détails.",
    comparisonPerformanceTitle: "Aperçu de la performance",
    comparisonPerformanceSubtitle: "Historique et prévision",
    comparisonPerformanceFormat: "Historique %s / Prévision %s",
    comparisonNoData: "Aucune donnée de marché disponible.",
    comparisonLoading: "Chargement des données de marché…",
    comparisonMacroTitle: "Comparaison macro",
    comparisonMacroSubtitle: "Tendances régionales côte à côte",
    comparisonMacroLoading: "Chargement des données macro.",
    comparisonMacroNoData: "Aucune donnée macro disponible.",
    comparisonScenarioTitle: "Laboratoire de scénarios",
    comparisonScenarioSubtitle: "Ajuster inflation, croissance et défense",
    scenarioInflation: "Inflation (%)",
    scenarioGrowth: "Croissance (%)",
    scenarioDefense: "Défense (% du PIB)",
    scenarioEquities: "Actions",
    scenarioRealEstate: "Immobilier",
    scenarioMetals: "Métaux",
    portfolioTitle: "Résilience du portefeuille",
    portfolioSubtitle: "Mix d’actions, immobilier et métaux",
    metalsSelectorTitle: "Sélectionner un métal",
    metalInsight24h: "24h",
    metalInsightChange: "Variation",
    metalsUpdatedLabel: "Mise à jour : %s",
    metalsProjectionTitle: "Projection sur 3 ans",
    metalsProjectionSubtitle: "Perspectives %s",
    metalsTrendTitle: "Historique & prévision jusqu’en 2050",
    metalsTrendSubtitle: "Évolution de l’indice %s",
    metalsTrendHistoryLabel: "%s historique",
    metalsTrendForecastLabel: "%s prévision",
    metalsTrendLoading: "Chargement des données de marché…",
    metalsResilienceTitle: "Résilience en crise",
    metalsResilienceSubtitle: "%s dans différents scénarios",
    metalsScenarioInflation: "Inflation",
    metalsScenarioInflationDetail: "%s réagit historiquement positivement à la hausse des prix à la consommation.",
    metalsScenarioWars: "Conflits",
    metalsScenarioWarsDetail: "Les tensions géopolitiques augmentent la demande d’actifs refuges.",
    metalsScenarioRecession: "Récessions",
    metalsScenarioRecessionDetail: "En récession, %s sert de réserve de liquidité.",
    metalsBadgeProtection: "Protection",
    metalsBadgeShield: "Couverture",
    metalsBadgeDiversification: "Diversification",
    crisisOverviewTitle: "Situation de crise",
    crisisOverviewSubtitle: "Signaux actuels issus de sources externes",
    crisisOverviewEmpty: "Aucun signal actuel.",
    crisisFeedTitle: "Flux de crise",
    crisisFeedSubtitle: "Actualités de NewsAPI et de la Banque mondiale",
    crisisFeedEmpty: "Aucun titre de crise pour le moment.",
    crisisCategoryFinancial: "Finances",
    crisisCategoryGeopolitical: "Géopolitique",
    crisisBadgeInfo: "Info",
    crisisBadgeModerate: "Modéré",
    crisisBadgeHigh: "Élevé",
    crisisDetailTitle: "Détails de crise",
    crisisDetailMissing: "Événement introuvable.",
    crisisDetailTimeline: "Chronologie",
    crisisDetailOpenSource: "Ouvrir la source",
    crisisDetailTimeLabel: "Moment : %s",
    crisisDetailSourceLabel: "Source : %s",
    crisisEventTitleGovernance: "Instabilité politique en %s",
    crisisEventTitleRecession: "Récession en %s",
    crisisGovernanceSummary: "Indice de gouvernance %s",
    crisisRecessionSummary: "Croissance réelle du PIB %s%",
    regionGlobal: "Monde",
    regionEurope: "Europe",
    sampleNewsTitle: "Le stress bancaire en Europe s’intensifie",
    sampleNewsSummary: "Les tensions financières augmentent dans plusieurs pays de l’UE.",
    consultationExpectationsTitle: "Ce qui vous attend",
    consultationExpectations: [
      "Première consultation gratuite avec des experts en métaux précieux",
      "Structuration patrimoniale individuelle",
      "Informations sur le stockage en entrepôt sous douane",
      "Aspects fiscaux et protection juridique"
    ],
    consultationMoreInfoTitle: "Plus d’informations",
    consultationInfo1Title: "Stockage en entrepôt sous douane",
    consultationInfo1Text:
      "Séparation physique du système bancaire, assurance et surveillance 24/7 pour une sécurité et une flexibilité maximales.",
    consultationInfo2Title: "La valeur - la structure gagne",
    consultationInfo2Text:
      "Une allocation claire en métaux précieux crée de la stabilité en période d’inflation, de réformes monétaires et de crises.",
    consultationPrivacyNote:
      "En envoyant, vous acceptez que nous répondions à votre demande conformément à la politique de confidentialité. Nous ne stockons aucune donnée sur cet appareil.",
    consultationSuccessTitle: "Merci",
    consultationSuccessMessage: "Votre demande a été envoyée. Nous revenons vers vous rapidement.",
    consultationFailureTitle: "Échec de l’envoi",
    consultationFailureMessage: "Échec de l’envoi de la demande.",
    consultationErrorName: "Veuillez indiquer votre nom.",
    consultationErrorEmail: "Veuillez saisir une adresse e-mail valide.",
    consultationErrorPhone: "Veuillez indiquer votre numéro de téléphone.",
    consultationErrorMessage: "Votre message doit comporter au moins 10 caractères.",
    notificationsActive: "Actives",
    notificationsDenied: "Désactivées",
    notificationsUnknown: "Inconnu",
    notificationsActiveDesc: "Vous recevrez des alertes en cas de changement de prévision ou de crises majeures.",
    notificationsDeniedDesc: "Les notifications sont désactivées. Activez-les dans les paramètres du navigateur.",
    notificationsUnknownDesc: "Aucune autorisation demandée pour le moment.",
    notificationsActionEnable: "Activer les notifications",
    notificationsActionOpenSettings: "Ouvrir les paramètres du navigateur",
    notificationsCrisisTitle: "Alerte de crise : %s",
    notificationsCrisisBody: "Région : %s. Catégorie : %s.",
    notificationsUnsupportedStatus: "Indisponible",
    notificationsUnsupportedDescription: "Ce navigateur ne prend pas en charge les notifications.",
    notificationsUnsupportedToast: "Les notifications ne sont pas disponibles dans ce navigateur.",
    notificationsEnabledToast: "Notifications activées.",
    notificationsSettingsToast: "Veuillez activer les notifications dans les paramètres du navigateur.",
    privacyIntro:
      "Nous traitons vos données exclusivement sur votre appareil ou lors de l’envoi de votre demande. Il n’y a pas de trackers cachés ni de profils cloud.",
    privacySections: [
      {
        title: "Responsable",
        body: "VermögensKompass (Vibecode GmbH) traite uniquement les données que vous partagez activement."
      },
      {
        title: "Résumé de la collecte",
        body: [
          "Les données de marché et de crise proviennent d’APIs publiques (World Bank, USGS, NOAA, GoldPrice.org) et sont évaluées localement.",
          "Nous ne stockons aucune donnée personnelle sur nos serveurs."
        ]
      },
      {
        title: "Contact",
        body:
          "Lorsque vous appuyez sur \"Demander une consultation\", nous envoyons votre message à notre équipe. Le transfert est sécurisé; nous ne conservons aucune copie."
      },
      {
        title: "Notifications",
        body:
          "Les notifications de crise sont traitées exclusivement sur votre appareil. Vous pouvez révoquer l’autorisation à tout moment dans les paramètres du navigateur."
      },
      {
        title: "Analytics & tracking",
        body: "Pas de suivi, pas de SDK tiers. L’application fonctionne entièrement hors ligne avec les dernières données synchronisées."
      },
      {
        title: "Vos droits",
        body:
          "Vous pouvez demander l’accès, la correction ou la suppression de votre contact en écrivant à datenschutz@vermoegenskompass.de."
      }
    ],
    crisisSummaryHeadlineNone: "Aucun événement à haut risque détecté",
    crisisSummaryHeadlineCountOne: "%s événement à haut risque actif",
    crisisSummaryHeadlineCountOther: "%s événements à haut risque actifs",
    crisisSummaryHighlightRegion: "%sx événements en %s",
    crisisSummaryHighlightCategory: "%sx catégorie %s",
    crisisSummaryHighlightLatest: "Dernier %s à %s",
    syncBannerWithTime: "Hors ligne : dernière synchronisation %s.",
    syncBannerWithoutTime: "Hors ligne : dernière synchronisation.",
    syncPartialOffline: "Partiellement hors ligne (%s)",
    syncFailed: "Synchronisation échouée",
    offlineToastPrefix: "Hors ligne : %s",
    syncFailureMetals: "Métaux",
    syncFailureMacro: "Macro",
    syncFailureCrisis: "Crises",
    notAvailableShort: "n/d",
    macroDeltaNoTrend: "Aucune tendance",
    macroDeltaVsPrevious: "%s%s%s vs. année précédente",
    chartAriaLabel: "Graphique de données"
  };

  STRINGS.es = {
    appName: "CRISIS 2050",
    skipLink: "Saltar al contenido",
    navLabel: "Navegación principal",
    refreshAriaLabel: "Actualizar datos",
    settingsAriaLabel: "Abrir ajustes",
    settingsCloseAriaLabel: "Cerrar ajustes",
    privacyCloseAriaLabel: "Cerrar la política de privacidad",
    overviewHeaderTitle: "Resumen",
    overviewHeaderSubtitle: "Protección patrimonial, metales preciosos y panorama macro de un vistazo.",
    overviewCtaTitle: "Solicitar asesoría",
    overviewCtaSubtitle: "Obtener una evaluación personal",
    comparisonHeaderTitle: "Comparación",
    comparisonHeaderSubtitle: "Clases de activos en comparación histórica y pronóstico.",
    metalsHeaderTitle: "Metales",
    metalsHeaderSubtitle: "Enfoque de precios, resiliencia y proyección a largo plazo hasta 2050.",
    metalsCtaTitle: "Hablar de estrategia",
    metalsCtaSubtitle: "Optimizar la cuota de metales",
    crisisHeaderTitle: "Crisis",
    crisisHeaderSubtitle: "Señales de alerta geopolíticas y financieras en tiempo real.",
    crisisDetailHeaderTitle: "Detalles de crisis",
    crisisDetailHeaderSubtitle: "Contexto y línea de tiempo del evento seleccionado.",
    crisisDetailBack: "Volver",
    consultationHeaderTitle: "Asesoría",
    consultationHeaderSubtitle: "Solicite una evaluación personalizada para proteger su patrimonio.",
    consultationFormTitle: "Contacto",
    consultationNameLabel: "Nombre*",
    consultationEmailLabel: "Correo electrónico*",
    consultationPhoneLabel: "Teléfono*",
    consultationMessageLabel: "Mensaje*",
    consultationSubmitLabel: "Enviar solicitud",
    consultationFormHint: "Al enviar, acepta el tratamiento de sus datos conforme a la política de privacidad.",
    settingsTitle: "Ajustes",
    settingsSectionGeneral: "General",
    settingsCurrencyLabel: "Moneda",
    settingsCurrencyHint: "Tipo de cambio del BCE, actualizaciones cada 12 horas.",
    settingsLanguageLabel: "Idioma de la app",
    settingsLanguageHint: "Cambia el idioma de la interfaz.",
    settingsSectionWatchlist: "Filtros de crisis",
    settingsWatchlistGeopolitical: "Lista geopolítica",
    settingsWatchlistFinancial: "Lista financiera",
    settingsSectionThresholds: "Umbrales",
    settingsThresholdLabel: "Umbrales",
    settingsThresholdStandard: "Estándar",
    settingsThresholdSensitive: "Sensible",
    settingsThresholdConservative: "Conservador",
    settingsThresholdHint: "Controla cuándo un evento se marca como de alto riesgo.",
    settingsSectionNotifications: "Notificaciones",
    settingsNotificationsStatusLabel: "Estado",
    settingsNotificationsHint: "Las notificaciones se procesan localmente.",
    settingsSectionPrivacy: "Privacidad",
    settingsPrivacyButton: "Política de privacidad",
    settingsPrivacyHint: "Sin seguimiento, sin SDK ocultos. Solo procesamiento local.",
    settingsNewsApiTitle: "NewsAPI (opcional)",
    settingsNewsApiLabel: "Clave API",
    settingsNewsApiPlaceholder: "X-Api-Key",
    settingsNewsApiHint: "Se guarda solo localmente y nunca se sube.",
    privacyTitle: "Política de privacidad",
    noscriptMessage: "Habilite JavaScript para usar la app web CRISIS 2050.",
    languageLabels: {
      de: "Alemán",
      en: "Inglés",
      fr: "Francés",
      es: "Español"
    },
    watchlistCountries: {
      UKR: "Ucrania",
      ISR: "Israel",
      TWN: "Taiwán",
      ZAF: "Sudáfrica",
      DEU: "Alemania",
      USA: "Estados Unidos",
      GBR: "Reino Unido",
      JPN: "Japón",
      CHN: "China"
    },
    assetGroups: {
      equities: "Mercados de acciones",
      real_estate: "Precios inmobiliarios",
      metals: "Metales"
    },
    assetLabels: {
      EQUITY_DE: "Acciones Alemania",
      EQUITY_USA: "Acciones EE. UU.",
      EQUITY_LON: "Acciones Londres",
      REAL_ESTATE_DE: "Inmobiliario Alemania",
      REAL_ESTATE_ES: "Inmobiliario España",
      REAL_ESTATE_FR: "Inmobiliario Francia",
      REAL_ESTATE_LON: "Inmobiliario Londres",
      GOLD: "Oro",
      SILVER: "Plata"
    },
    macroKinds: {
      INFLATION: {
        title: "Inflación",
        description: "Inflación anual de precios al consumidor (Banco Mundial)",
        unit: "%"
      },
      GROWTH: {
        title: "Crecimiento",
        description: "Crecimiento real del PIB",
        unit: "%"
      },
      DEFENSE: {
        title: "Defensa",
        description: "Gasto militar como porcentaje del PIB",
        unit: "% del PIB"
      }
    },
    bennerPhases: {
      panic: {
        title: "Año de pánico",
        subtitle: "Presión de venta extrema - Fase A",
        guidance:
          "Históricamente, estos años fueron seguidos por fuertes caídas del mercado. Asegure liquidez y limite el riesgo."
      },
      good: {
        title: "Buenos tiempos",
        subtitle: "Precios altos - Fase B (preferir ventas)",
        guidance: "Valoraciones superiores a la media. Asegure ganancias y reduzca la exposición."
      },
      hard: {
        title: "Tiempos difíciles",
        subtitle: "Precios bajos - Fase C (acumulación)",
        guidance: "Los precios se consideran atractivos. Se recomiendan posiciones y planes de ahorro."
      }
    },
    heroTitle: "Protección del patrimonio",
    heroSubtitle: "Pronóstico actual",
    heroLabel: "Pronóstico",
    heroHint: "Se recomienda precaución - priorice la protección.",
    metalsFocusTitle: "Metales en foco",
    metalsFocusSubtitle: "Oro y plata en el contexto de mercado actual",
    macroTitle: "Panorama macro",
    macroSubtitle: "Inflación, tipo de cambio y crecimiento por región",
    whyMetalsTitle: "Por qué metales y estructura",
    whyMetalsBullets: [
      "Valor físico independiente de las monedas",
      "Protección contra la inflación y la pérdida de poder adquisitivo",
      "Estabilidad en guerras y crisis económicas",
      "Protección patrimonial estructurada mediante una asignación planificada",
      "Almacenamiento seguro en depósito aduanero fuera del sistema bancario"
    ],
    comparisonSectionTitle: "Comparación de clases de activos",
    comparisonSectionSubtitle: "Histórico y pronóstico 2025–2050",
    comparisonModeHistory: "Histórico",
    comparisonModeForecast: "Pronóstico",
    comparisonChartTitle: "Evolución del valor",
    comparisonChartSubtitle: "Toque el gráfico para ver detalles.",
    comparisonPerformanceTitle: "Resumen de rendimiento",
    comparisonPerformanceSubtitle: "Histórico y pronóstico",
    comparisonPerformanceFormat: "Histórico %s / Pronóstico %s",
    comparisonNoData: "No hay datos de mercado disponibles.",
    comparisonLoading: "Cargando datos de mercado…",
    comparisonMacroTitle: "Comparación macro",
    comparisonMacroSubtitle: "Tendencias regionales lado a lado",
    comparisonMacroLoading: "Cargando datos macro.",
    comparisonMacroNoData: "No hay datos macro disponibles.",
    comparisonScenarioTitle: "Laboratorio de escenarios",
    comparisonScenarioSubtitle: "Ajustar inflación, crecimiento y defensa",
    scenarioInflation: "Inflación (%)",
    scenarioGrowth: "Crecimiento (%)",
    scenarioDefense: "Defensa (% del PIB)",
    scenarioEquities: "Acciones",
    scenarioRealEstate: "Inmobiliario",
    scenarioMetals: "Metales",
    portfolioTitle: "Resiliencia del portafolio",
    portfolioSubtitle: "Mezcla de acciones, inmobiliario y metales",
    metalsSelectorTitle: "Seleccionar metal",
    metalInsight24h: "24h",
    metalInsightChange: "Variación",
    metalsUpdatedLabel: "Actualizado: %s",
    metalsProjectionTitle: "Pronóstico a 3 años",
    metalsProjectionSubtitle: "Perspectiva de %s",
    metalsTrendTitle: "Histórico y pronóstico hasta 2050",
    metalsTrendSubtitle: "Evolución del índice %s",
    metalsTrendHistoryLabel: "Histórico de %s",
    metalsTrendForecastLabel: "Pronóstico de %s",
    metalsTrendLoading: "Cargando datos de mercado…",
    metalsResilienceTitle: "Resiliencia en crisis",
    metalsResilienceSubtitle: "%s en distintos escenarios",
    metalsScenarioInflation: "Inflación",
    metalsScenarioInflationDetail: "%s reacciona históricamente de forma positiva al aumento de los precios al consumidor.",
    metalsScenarioWars: "Conflictos",
    metalsScenarioWarsDetail: "Las tensiones geopolíticas aumentan la demanda de activos refugio.",
    metalsScenarioRecession: "Recesiones",
    metalsScenarioRecessionDetail: "En recesiones, %s actúa como reserva de liquidez.",
    metalsBadgeProtection: "Protección",
    metalsBadgeShield: "Cobertura",
    metalsBadgeDiversification: "Diversificación",
    crisisOverviewTitle: "Situación de crisis",
    crisisOverviewSubtitle: "Señales actuales de fuentes externas",
    crisisOverviewEmpty: "No hay señales actuales.",
    crisisFeedTitle: "Feed de crisis",
    crisisFeedSubtitle: "Noticias de NewsAPI y del Banco Mundial",
    crisisFeedEmpty: "No hay titulares de crisis actuales.",
    crisisCategoryFinancial: "Finanzas",
    crisisCategoryGeopolitical: "Geopolítica",
    crisisBadgeInfo: "Info",
    crisisBadgeModerate: "Moderado",
    crisisBadgeHigh: "Alto",
    crisisDetailTitle: "Detalles de crisis",
    crisisDetailMissing: "Evento no encontrado.",
    crisisDetailTimeline: "Línea de tiempo",
    crisisDetailOpenSource: "Abrir fuente",
    crisisDetailTimeLabel: "Momento: %s",
    crisisDetailSourceLabel: "Fuente: %s",
    crisisEventTitleGovernance: "Inestabilidad política en %s",
    crisisEventTitleRecession: "Recesión en %s",
    crisisGovernanceSummary: "Índice de gobernanza %s",
    crisisRecessionSummary: "Crecimiento real del PIB %s%",
    regionGlobal: "Global",
    regionEurope: "Europa",
    sampleNewsTitle: "El estrés bancario en Europa aumenta",
    sampleNewsSummary: "Las tensiones financieras crecen en varios países de la UE.",
    consultationExpectationsTitle: "Qué puede esperar",
    consultationExpectations: [
      "Primera asesoría gratuita con expertos en metales preciosos",
      "Estructuración patrimonial individual",
      "Información sobre almacenamiento en depósito aduanero",
      "Aspectos fiscales y protección legal"
    ],
    consultationMoreInfoTitle: "Más información",
    consultationInfo1Title: "Almacenamiento en depósito aduanero",
    consultationInfo1Text:
      "Separación física del sistema bancario, seguro y vigilancia 24/7 para máxima seguridad y flexibilidad.",
    consultationInfo2Title: "El valor - la estructura gana",
    consultationInfo2Text: "Una asignación clara en metales preciosos crea estabilidad en inflación, reformas monetarias y crisis.",
    consultationPrivacyNote:
      "Al enviar, acepta que respondamos a su solicitud conforme a la política de privacidad. No almacenamos datos de forma permanente en este dispositivo.",
    consultationSuccessTitle: "Gracias",
    consultationSuccessMessage: "Su solicitud fue enviada. Nos pondremos en contacto pronto.",
    consultationFailureTitle: "Envío fallido",
    consultationFailureMessage: "Error al enviar la solicitud.",
    consultationErrorName: "Por favor, indique su nombre.",
    consultationErrorEmail: "Por favor, introduzca una dirección de correo válida.",
    consultationErrorPhone: "Por favor, indique su número de teléfono.",
    consultationErrorMessage: "Su mensaje debe tener al menos 10 caracteres.",
    notificationsActive: "Activas",
    notificationsDenied: "Desactivadas",
    notificationsUnknown: "Desconocido",
    notificationsActiveDesc: "Recibirá alertas cuando cambien los pronósticos o haya crisis importantes.",
    notificationsDeniedDesc: "Las notificaciones están desactivadas. Actívelas en los ajustes del navegador.",
    notificationsUnknownDesc: "Aún no se solicitó permiso.",
    notificationsActionEnable: "Activar notificaciones",
    notificationsActionOpenSettings: "Abrir ajustes del navegador",
    notificationsCrisisTitle: "Alerta de crisis: %s",
    notificationsCrisisBody: "Región: %s. Categoría: %s.",
    notificationsUnsupportedStatus: "No disponible",
    notificationsUnsupportedDescription: "Este navegador no admite notificaciones.",
    notificationsUnsupportedToast: "Las notificaciones no están disponibles en este navegador.",
    notificationsEnabledToast: "Notificaciones activadas.",
    notificationsSettingsToast: "Active las notificaciones en los ajustes del navegador.",
    privacyIntro:
      "Procesamos sus datos solo en el dispositivo o al enviar su solicitud. No hay rastreadores ocultos ni perfiles en la nube.",
    privacySections: [
      {
        title: "Responsable",
        body: "VermögensKompass (Vibecode GmbH) procesa solo los datos que usted comparte activamente."
      },
      {
        title: "Resumen de la recopilación",
        body: [
          "Los datos de mercado y crisis provienen de APIs públicas (World Bank, USGS, NOAA, GoldPrice.org) y se evalúan localmente.",
          "No almacenamos datos personales en nuestros servidores."
        ]
      },
      {
        title: "Contacto",
        body:
          "Cuando toca \"Solicitar asesoría\", enviamos su mensaje a nuestro equipo. El envío es seguro; no almacenamos una copia."
      },
      {
        title: "Notificaciones",
        body:
          "Las notificaciones de crisis se procesan solo en su dispositivo. Puede revocar el permiso en cualquier momento en los ajustes del navegador."
      },
      {
        title: "Analítica y seguimiento",
        body: "Sin seguimiento, sin SDKs de terceros. La app funciona totalmente sin conexión con los últimos datos sincronizados."
      },
      {
        title: "Sus derechos",
        body:
          "Puede solicitar acceso, corrección o eliminación de su contacto escribiéndonos a datenschutz@vermoegenskompass.de."
      }
    ],
    crisisSummaryHeadlineNone: "No se detectan eventos de alto riesgo",
    crisisSummaryHeadlineCountOne: "%s evento de alto riesgo activo",
    crisisSummaryHeadlineCountOther: "%s eventos de alto riesgo activos",
    crisisSummaryHighlightRegion: "%sx eventos en %s",
    crisisSummaryHighlightCategory: "%sx categoría %s",
    crisisSummaryHighlightLatest: "Último %s a las %s",
    syncBannerWithTime: "Sin conexión: última sincronización %s.",
    syncBannerWithoutTime: "Sin conexión: última sincronización.",
    syncPartialOffline: "Parcialmente sin conexión (%s)",
    syncFailed: "Sincronización fallida",
    offlineToastPrefix: "Sin conexión: %s",
    syncFailureMetals: "Metales",
    syncFailureMacro: "Macro",
    syncFailureCrisis: "Crisis",
    notAvailableShort: "n/d",
    macroDeltaNoTrend: "Sin tendencia",
    macroDeltaVsPrevious: "%s%s%s vs. año anterior",
    chartAriaLabel: "Gráfico de datos"
  };

  let TEXT = STRINGS[DEFAULT_LANGUAGE];

  const state = {
    settings: null,
    snapshot: null,
    lastSyncAt: null,
    lastError: null,
    fxRate: null,
    stooqCache: readJson(STORAGE_KEYS.stooqCache, {}),
    newsCache: readJson(STORAGE_KEYS.newsCache, null),
    bennerEntries: [],
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

  function normalizeLanguage(value) {
    if (SUPPORTED_LANGUAGES.includes(value)) return value;
    return DEFAULT_LANGUAGE;
  }

  function configureLanguage(value) {
    const normalized = normalizeLanguage(value);
    state.settings.language = normalized;
    TEXT = STRINGS[normalized] || STRINGS[DEFAULT_LANGUAGE];
    state.bennerEntries = makeBennerEntries();
  }

  function applyStaticText() {
    document.documentElement.lang = state.settings.language;
    document.title = TEXT.appName;

    $$("[data-i18n]").forEach((element) => {
      const key = element.getAttribute("data-i18n");
      if (!key || !(key in TEXT)) return;
      element.textContent = TEXT[key];
    });

    $$("[data-i18n-aria]").forEach((element) => {
      const key = element.getAttribute("data-i18n-aria");
      if (!key || !(key in TEXT)) return;
      element.setAttribute("aria-label", TEXT[key]);
    });

    $$("[data-i18n-placeholder]").forEach((element) => {
      const key = element.getAttribute("data-i18n-placeholder");
      if (!key || !(key in TEXT)) return;
      element.setAttribute("placeholder", TEXT[key]);
    });
  }

  function init() {
    state.settings = loadSettings();
    configureLanguage(state.settings.language);
    state.snapshot = loadSnapshot() || makeSampleSnapshot();
    state.lastSyncAt = readJson(STORAGE_KEYS.snapshotAt, null);
    state.fxRate = readJson(STORAGE_KEYS.fxRate, null);
    state.selectedMetalId = state.snapshot.metals[0]?.id || null;
    state.scenario = seedScenarioFromSnapshot(state.snapshot);
    state.route = parseRoute(window.location.hash) || "overview";

    cacheElements();
    bindEvents();
    applyStaticText();
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
      if (target.dataset.language) {
        updateLanguage(target.dataset.language);
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

  function watchlistLabel(code) {
    return TEXT.watchlistCountries?.[code] || code;
  }

  function assetGroupLabel(groupId) {
    return TEXT.assetGroups?.[groupId] || groupId;
  }

  function assetLabel(assetId) {
    return TEXT.assetLabels?.[assetId] || assetId;
  }

  function macroKindMeta(kindId) {
    const localized = TEXT.macroKinds?.[kindId];
    const fallback = MACRO_KIND_MAP.get(kindId);
    return {
      title: localized?.title || kindId,
      description: localized?.description || "",
      unit: localized?.unit || fallback?.unit || ""
    };
  }

  function bennerPhaseText(phaseId) {
    return TEXT.bennerPhases?.[phaseId] || { title: phaseId, subtitle: phaseId, guidance: "" };
  }

  function metalLabel(id, fallback) {
    if (id === "XAU") return TEXT.assetLabels?.GOLD || fallback || "Gold";
    if (id === "XAG") return TEXT.assetLabels?.SILVER || fallback || "Silver";
    return fallback || id;
  }

  function localizedCrisisTitle(event) {
    if (event.source === "WORLD_BANK_GOVERNANCE") {
      return formatText(TEXT.crisisEventTitleGovernance, localizedRegion(event.region));
    }
    if (event.source === "WORLD_BANK_FINANCE") {
      return formatText(TEXT.crisisEventTitleRecession, localizedRegion(event.region));
    }
    return event.title;
  }

  function localizedRegion(region) {
    if (!region) return region;
    const normalized = region.trim().toUpperCase();
    if (TEXT.watchlistCountries?.[normalized]) return TEXT.watchlistCountries[normalized];
    const map = {
      GERMANY: "DEU",
      UNITED_STATES: "USA",
      UNITEDKINGDOM: "GBR",
      UK: "GBR",
      JAPAN: "JPN",
      CHINA: "CHN",
      SOUTHAFRICA: "ZAF",
      UKRAINE: "UKR",
      ISRAEL: "ISR",
      TAIWAN: "TWN"
    };
    const key = normalized.replace(/[\s.-]/g, "");
    const mapped = map[key];
    return mapped ? TEXT.watchlistCountries?.[mapped] || region : region;
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
      { id: "history", label: TEXT.comparisonModeHistory },
      { id: "forecast", label: TEXT.comparisonModeForecast }
    ].forEach((mode) => {
      const button = makeEl("button", "segmented-button", mode.label);
      button.type = "button";
      button.dataset.comparisonMode = mode.id;
      if (state.comparisonMode === mode.id) button.classList.add("is-active");
      modeRow.append(button);
    });
    container.append(modeRow);

    ASSET_GROUPS.forEach((groupId) => {
      container.append(makeEl("p", "label", assetGroupLabel(groupId)));
      const row = makeEl("div", "chip-row");
      COMPARISON_ASSETS.filter((asset) => asset.group === groupId).forEach((asset) => {
        const button = makeEl("button", "chip", assetLabel(asset.id));
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
              label: assetLabel(item.assetId),
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
      row.append(makeEl("span", "label", assetLabel(item.assetId)));
      const value = formatText(
        TEXT.comparisonPerformanceFormat,
        calcCagr(item.history),
        calcProjectionDelta(item.history, item.projection)
      );
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
      const meta = macroKindMeta(kind.id);
      const button = makeEl("button", "segmented-button", meta.title);
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
      const button = makeEl("button", "chip", metalLabel(metal.id, metal.name));
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

    const metalName = metalLabel(metal.id, metal.name);
    const headerRow = makeEl("div", "row");
    headerRow.append(makeEl("h3", null, metalName));
    headerRow.append(makeEl("span", "pill", metal.symbol));

    const valueRow = makeEl("div", "row");
    valueRow.append(makeEl("span", "value", priceText));
    valueRow.append(makeEl("span", changeClass, changeText));

    const updated = metal.lastUpdated ? new Date(metal.lastUpdated) : null;
    const updatedText = updated ? formatText(TEXT.metalsUpdatedLabel, formatDateTime(updated)) : "";

    container.append(headerRow, valueRow, makeEl("p", "hint", updatedText));
    const insights = makeEl("div", "metric-grid");
    const changeValueRaw = Number.isFinite(metal.change)
      ? metal.change
      : metal.dailyChangePercentage * metal.price * 0.01;
    const changeValue = convertCurrency(changeValueRaw, metal.currency, state.settings.currency, state.fxRate);
    insights.append(renderMetric(TEXT.metalInsight24h, formatPercent(metal.dailyChangePercentage)));
    insights.append(renderMetric(TEXT.metalInsightChange, formatNumber(changeValue, 2)));
    container.append(insights);
  }

  function renderMetalsProjection() {
    const container = elements.metalsProjection;
    if (!container) return;
    clearElement(container);

    const metal = selectedMetal();
    if (!metal) return;

    const metalName = metalLabel(metal.id, metal.name);
    container.append(cardHeader(TEXT.metalsProjectionTitle, formatText(TEXT.metalsProjectionSubtitle, metalName)));

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

    const metalName = metalLabel(metal.id, metal.name);
    container.append(cardHeader(TEXT.metalsTrendTitle, formatText(TEXT.metalsTrendSubtitle, metalName)));

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
        label: formatText(TEXT.metalsTrendHistoryLabel, metalName),
        points: historyPoints.map((point) => ({ x: point.year, y: point.value })),
        color: COLORS.strong
      });
    }
    if (projectionPoints.length) {
      series.push({
        label: formatText(TEXT.metalsTrendForecastLabel, metalName),
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

    const metalName = metalLabel(metal.id, metal.name);
    container.append(cardHeader(TEXT.metalsResilienceTitle, formatText(TEXT.metalsResilienceSubtitle, metalName)));

    const inflation = indicatorValue("INFLATION");
    const growth = indicatorValue("GROWTH");
    const defense = indicatorValue("DEFENSE");

    const scenarios = [
      {
        title: TEXT.metalsScenarioInflation,
        description: formatText(TEXT.metalsScenarioInflationDetail, metalName),
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
        description: formatText(TEXT.metalsScenarioRecessionDetail, metalName),
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
    detail.append(makeEl("h2", null, localizedCrisisTitle(event)));
    detail.append(makeEl("p", "hint", localizedRegion(event.region)));
    detail.append(makeEl("span", "pill", categoryLabel(event.category)));

    if (event.summary) {
      detail.append(makeEl("p", "hint", event.summary));
    }

    detail.append(makeEl("p", "hint", formatText(TEXT.crisisDetailTimeLabel, formatDateTime(new Date(event.occurredAt)))));
    if (event.sourceName) {
      detail.append(makeEl("p", "hint", formatText(TEXT.crisisDetailSourceLabel, event.sourceName)));
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

    $$("[data-language]").forEach((button) => {
      const language = button.dataset.language;
      if (!language) return;
      const label = TEXT.languageLabels?.[language];
      if (label) button.textContent = label;
      button.classList.toggle("is-active", language === state.settings.language);
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
      value.textContent = Number.isFinite(amount) ? formatNumber(amount, 1) : TEXT.notAvailableShort;
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

  function updateLanguage(language) {
    const normalized = normalizeLanguage(language);
    if (state.settings.language === normalized) return;
    state.settings.language = normalized;
    saveSettings();
    configureLanguage(normalized);
    applyStaticText();
    renderAll();
    updateSyncBanner();
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
      showToast(TEXT.notificationsUnsupportedToast);
      return;
    }

    if (Notification.permission === "default") {
      const result = await Notification.requestPermission();
      if (result === "granted") {
        showToast(TEXT.notificationsEnabledToast);
      }
      updateNotificationUI();
      return;
    }

    showToast(TEXT.notificationsSettingsToast);
  }

  function updateNotificationUI() {
    if (!elements.notificationStatus || !elements.notificationAction || !elements.notificationDescription) return;

    if (!("Notification" in window)) {
      elements.notificationStatus.textContent = TEXT.notificationsUnsupportedStatus;
      elements.notificationDescription.textContent = TEXT.notificationsUnsupportedDescription;
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
        body: JSON.stringify({ name, email, phone, message, locale: currentLocale() })
      });

      if (!response.ok) {
        throw new Error(TEXT.consultationFailureMessage);
      }

      elements.consultationForm.reset();
      showToast(`${TEXT.consultationSuccessTitle}: ${TEXT.consultationSuccessMessage}`);
    } catch (error) {
      const message = (error && error.message) || TEXT.consultationFailureMessage;
      showToast(`${TEXT.consultationFailureTitle}: ${message}`);
    }
  }

  function validateConsultation(name, email, phone, message) {
    if (name.length < 2) return TEXT.consultationErrorName;
    if (!/^([A-Z0-9._%+-]+)@([A-Z0-9.-]+)\.([A-Z]{2,})$/i.test(email)) {
      return TEXT.consultationErrorEmail;
    }
    if (phone.length < 5) return TEXT.consultationErrorPhone;
    if (message.length < 10) return TEXT.consultationErrorMessage;
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
      if (metalsResult.status === "rejected") failures.push(TEXT.syncFailureMetals);
      if (macroResult.status === "rejected") failures.push(TEXT.syncFailureMacro);
      if (crisisResult.status === "rejected") failures.push(TEXT.syncFailureCrisis);

      if (failures.length === 0) {
        state.lastSyncAt = Date.now();
      }
      state.lastError = failures.length ? formatText(TEXT.syncPartialOffline, failures.join(", ")) : null;
      saveSnapshot(state.snapshot);

      if (!state.scenarioTouched) {
        state.scenario = seedScenarioFromSnapshot(state.snapshot);
      }

      maybeNotify(crises);
    } catch (error) {
      state.lastError = error instanceof Error && error.message ? error.message : TEXT.syncFailed;
    } finally {
      elements.refreshButton?.classList.remove("is-loading");
      updateSyncBanner();
      renderAll();
      if (!options.silent && state.lastError) {
        showToast(formatText(TEXT.offlineToastPrefix, state.lastError));
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
      const base = time ? formatText(TEXT.syncBannerWithTime, time) : TEXT.syncBannerWithoutTime;
      banner.textContent = state.lastError ? `${base} ${state.lastError}` : base;
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
    const meta = macroKindMeta(kind.id);

    return {
      indicator: {
        id: kind.id,
        title: meta.title,
        latestValue: latest?.value ?? null,
        previousValue: previous?.value ?? null,
        unit: meta.unit || kind.unit,
        description: meta.description
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
    } catch {
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
      region: article.source?.name || TEXT.regionGlobal,
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
    const active = WATCHLISTS.geopolitical.filter((code) => state.settings.watchlistGeo.includes(code));
    if (!active.length) return [];

    const results = await Promise.allSettled(
      active.map(async (code) => {
        const value = await fetchWorldBankLatest(code, "PV.PSR.PIND");
        if (!value || value.value >= profile.governanceCutoff) return null;
        const region = watchlistLabel(code);
        return {
          id: `geo-${code}`,
          title: formatText(TEXT.crisisEventTitleGovernance, region),
          summary: formatText(TEXT.crisisGovernanceSummary, formatNumber(value.value, 2)),
          region,
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
    const active = WATCHLISTS.financial.filter((code) => state.settings.watchlistFinancial.includes(code));
    if (!active.length) return [];

    const results = await Promise.allSettled(
      active.map(async (code) => {
        const value = await fetchWorldBankLatest(code, "NY.GDP.MKTP.KD.ZG");
        if (!value || value.value >= profile.recessionCutoff) return null;
        const region = watchlistLabel(code);
        return {
          id: `finance-${code}`,
          title: formatText(TEXT.crisisEventTitleRecession, region),
          summary: formatText(TEXT.crisisRecessionSummary, formatNumber(value.value, 1)),
          region,
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
    } catch {
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
    } catch {
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
        entries.push(makeBennerEntry(panicYear, "panic", 1, 1));
      }

      const availableYears = Math.max(Math.min(nextPanic, BENNER_CONFIG.rangeEnd + 1) - panicYear - 1, 0);
      const cycleGoodYears = Math.min(BENNER_CONFIG.goodSpan, availableYears);
      const cycleHardYears = Math.max(availableYears - cycleGoodYears, 0);

      for (let offset = 1; offset <= cycleGoodYears; offset += 1) {
        const year = panicYear + offset;
        if (year >= BENNER_CONFIG.rangeStart && year <= BENNER_CONFIG.rangeEnd) {
          entries.push(makeBennerEntry(year, "good", offset, cycleGoodYears));
        }
      }

      for (let i = 0; i < cycleHardYears; i += 1) {
        const year = panicYear + cycleGoodYears + 1 + i;
        if (year >= BENNER_CONFIG.rangeStart && year <= BENNER_CONFIG.rangeEnd) {
          entries.push(makeBennerEntry(year, "hard", i + 1, cycleHardYears));
        }
      }
    }

    return entries.sort((a, b) => a.year - b.year);
  }

  function makeBennerEntry(year, phaseId, order, length) {
    const base = BENNER_PHASES[phaseId] || { id: phaseId, metalTrendMultiplier: 0 };
    const localized = bennerPhaseText(phaseId);
    return {
      year,
      phase: { ...base, ...localized },
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
      ? formatText(
          severe.length === 1 ? TEXT.crisisSummaryHeadlineCountOne : TEXT.crisisSummaryHeadlineCountOther,
          String(severe.length)
        )
      : TEXT.crisisSummaryHeadlineNone;

    const dominantRegion = dominantGroup(events, (event) => event.region);
    const dominantCategory = dominantGroup(events, (event) => event.category);

    const highlights = [];
    if (dominantRegion) {
      highlights.push(
        formatText(TEXT.crisisSummaryHighlightRegion, String(dominantRegion.count), localizedRegion(dominantRegion.key))
      );
    }
    if (dominantCategory) {
      highlights.push(
        formatText(TEXT.crisisSummaryHighlightCategory, String(dominantCategory.count), categoryLabel(dominantCategory.key))
      );
    }

    const latest = events.reduce((acc, event) => (event.occurredAt > acc.occurredAt ? event : acc), events[0]);
    highlights.push(
      formatText(
        TEXT.crisisSummaryHighlightLatest,
        localizedCrisisTitle(latest),
        formatDateTime(new Date(latest.occurredAt))
      )
    );

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
    header.append(makeEl("h3", null, localizedCrisisTitle(event)));
    const badge = makeEl("span", `badge ${severityClass(event.severityScore)}`, severityBadge(event.severityScore));
    header.append(badge);

    card.append(header);
    if (event.summary) {
      card.append(makeEl("p", "hint", event.summary));
    }

    const meta = makeEl("div", "row");
    meta.append(makeEl("span", "hint", localizedRegion(event.region)));
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
    content.append(makeEl("span", "label", localizedCrisisTitle(event)));
    content.append(makeEl("span", "hint", formatDateTime(new Date(event.occurredAt))));
    row.append(content);
    return row;
  }

  function renderScenarioSlider(name, label, min, max, value) {
    const wrapper = makeEl("div", "slider-row");
    const header = makeEl("div", "row");
    header.append(makeEl("label", "label", label));
    const valueLabel = makeEl("span", "hint", formatNumber(value, 1));
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
    const meta = macroKindMeta(indicator.id);
    header.append(makeEl("span", "label", meta.title));
    header.append(makeEl("span", "pill", region));
    card.append(header);

    const latest = indicator.latestValue;
    const previous = indicator.previousValue;
    const hasLatest = Number.isFinite(latest);
    const hasPrevious = Number.isFinite(previous);
    const unit = meta.unit || indicator.unit || "";
    const formatted = hasLatest ? `${formatNumber(latest, 1)}${unit}` : TEXT.notAvailableShort;
    card.append(makeEl("div", "value", formatted));

    let delta = TEXT.macroDeltaNoTrend;
    if (hasLatest && hasPrevious) {
      const diff = latest - previous;
      const sign = diff >= 0 ? "+" : "";
      delta = formatText(TEXT.macroDeltaVsPrevious, sign, formatNumber(diff, 1), unit);
    }
    card.append(makeEl("p", "hint", delta));

    return card;
  }

  function renderMetalCard(metal) {
    const card = makeEl("div", "stack");

    const header = makeEl("div", "row");
    header.append(makeEl("h3", null, metalLabel(metal.id, metal.name)));
    header.append(makeEl("span", "pill", metal.symbol));
    card.append(header);

    const converted = convertCurrency(metal.price, metal.currency, state.settings.currency, state.fxRate);
    card.append(makeEl("div", "value", formatCurrency(converted, state.settings.currency)));

    const change = formatSignedPercent(metal.dailyChangePercentage);
    card.append(makeEl("p", "hint", `${TEXT.metalInsight24h}: ${change}`));

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
    svg.setAttribute("aria-label", TEXT.chartAriaLabel);

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

  function formatText(template, ...values) {
    if (!template) return "";
    return values.reduce((acc, value) => acc.replace("%s", value), template);
  }

  function currentLocale() {
    return LOCALE_BY_LANGUAGE[state.settings.language] || LOCALE_BY_LANGUAGE[DEFAULT_LANGUAGE];
  }

  function formatCurrency(value, currency) {
    if (!Number.isFinite(value)) return "-";
    try {
      return new Intl.NumberFormat(currentLocale(), {
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
    return new Intl.NumberFormat(currentLocale(), {
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
    return new Intl.DateTimeFormat(currentLocale(), {
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
    if (!first || !last || first.year === last.year) return TEXT.notAvailableShort;
    const years = last.year - first.year;
    const base = Math.max(last.value, 0.1) / Math.max(first.value, 0.1);
    const growth = Math.pow(base, 1 / years) - 1;
    return `${formatNumber(growth * 100, 1)}%`;
  }

  function calcProjectionDelta(history, projection) {
    const lastHistory = history[history.length - 1];
    const lastProjection = projection[projection.length - 1];
    if (!lastHistory || !lastProjection) return TEXT.notAvailableShort;
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
      language: normalizeLanguage(saved.language),
      thresholdProfile: THRESHOLD_PROFILES[saved.thresholdProfile] ? saved.thresholdProfile : "standard",
      watchlistGeo: convertToSet(saved.watchlistGeo).filter(Boolean),
      watchlistFinancial: convertToSet(saved.watchlistFinancial).filter(Boolean),
      newsApiKey: saved.newsApiKey || ""
    };
  }

  function saveSettings() {
    writeJson(STORAGE_KEYS.settings, {
      currency: state.settings.currency,
      language: state.settings.language,
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

    const title = formatText(TEXT.notificationsCrisisTitle, localizedCrisisTitle(topEvent));
    const body = formatText(
      TEXT.notificationsCrisisBody,
      localizedRegion(topEvent.region),
      categoryLabel(topEvent.category)
    );

    new Notification(title, { body });

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

    list.forEach((code) => {
      const wrapper = makeEl("label", "toggle");
      const label = makeEl("span", null, watchlistLabel(code));
      const input = document.createElement("input");
      input.type = "checkbox";
      input.checked = activeList.includes(code);
      input.value = code;
      input.dataset.watchlist = type;
      wrapper.append(label, input);
      container.append(wrapper);
    });
  }

  function makeSampleSnapshot() {
    const now = Date.now();
    const goldName = metalLabel("XAU", "Gold");
    const silverName = metalLabel("XAG", "Silver");
    const inflationMeta = macroKindMeta("INFLATION");
    const growthMeta = macroKindMeta("GROWTH");
    const defenseMeta = macroKindMeta("DEFENSE");
    const regionEurope = TEXT.regionEurope;
    const regionUkraine = watchlistLabel("UKR");
    const regionGermany = watchlistLabel("DEU");
    return {
      metals: [
        {
          id: "XAU",
          name: goldName,
          symbol: "XAU",
          price: 2328.2,
          dailyChangePercentage: 0.8,
          change: 18.6,
          currency: "USD",
          lastUpdated: now - 60 * 60 * 1000
        },
        {
          id: "XAG",
          name: silverName,
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
            title: inflationMeta.title,
            latestValue: 3.1,
            previousValue: 4.0,
            unit: inflationMeta.unit,
            description: inflationMeta.description
          },
          {
            id: "GROWTH",
            title: growthMeta.title,
            latestValue: 0.6,
            previousValue: 1.2,
            unit: growthMeta.unit,
            description: growthMeta.description
          },
          {
            id: "DEFENSE",
            title: defenseMeta.title,
            latestValue: 1.8,
            previousValue: 1.6,
            unit: defenseMeta.unit,
            description: defenseMeta.description
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
          title: TEXT.sampleNewsTitle,
          summary: TEXT.sampleNewsSummary,
          region: regionEurope,
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
          title: formatText(TEXT.crisisEventTitleGovernance, regionUkraine),
          summary: formatText(TEXT.crisisGovernanceSummary, formatNumber(-1.1, 2)),
          region: regionUkraine,
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
          title: formatText(TEXT.crisisEventTitleRecession, regionGermany),
          summary: formatText(TEXT.crisisRecessionSummary, formatNumber(-0.4, 1)),
          region: regionGermany,
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
