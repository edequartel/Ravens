<!doctype html>
<html lang="nl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Ravens is een iPhone-app voor natuurwaarnemingen uit Waarneming.nl en Observation.org.">
  <title>Ravens - natuurwaarnemingen op je iPhone</title>
  <link href="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/css/tabler.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css" rel="stylesheet">
  <style>
    :root {
      --ravens-ink: #14213d;
      --ravens-green: #1b8a5a;
      --ravens-leaf: #dff3e7;
      --ravens-sky: #e9f5ff;
      --ravens-sun: #ffd166;
      --ravens-coral: #ef476f;
    }

    body {
      background:
        radial-gradient(circle at 12% 8%, rgba(255, 209, 102, .24), transparent 30%),
        radial-gradient(circle at 88% 18%, rgba(27, 138, 90, .18), transparent 28%),
        linear-gradient(180deg, #f8fbff 0%, #eef6f0 100%);
      color: var(--ravens-ink);
    }

    .hero {
      min-height: 620px;
      overflow: hidden;
      position: relative;
    }

    .app-logo {
      border-radius: 24px;
      box-shadow: 0 18px 48px rgba(20, 33, 61, .18);
      height: 104px;
      width: 104px;
    }

    .island {
      background: rgba(255, 255, 255, .82);
      border: 1px solid rgba(20, 33, 61, .08);
      border-radius: 18px;
      box-shadow: 0 24px 70px rgba(20, 33, 61, .10);
      backdrop-filter: blur(18px);
    }

    .feature-island {
      height: 100%;
      transition: transform .2s ease, box-shadow .2s ease;
    }

    .feature-island:hover {
      box-shadow: 0 30px 80px rgba(20, 33, 61, .14);
      transform: translateY(-3px);
    }

    .icon-bubble {
      align-items: center;
      background: var(--ravens-leaf);
      border-radius: 16px;
      color: var(--ravens-green);
      display: inline-flex;
      font-size: 1.35rem;
      height: 48px;
      justify-content: center;
      width: 48px;
    }

    .screenshot-stack {
      min-height: 560px;
      position: relative;
    }

    .phone-shot {
      border: 10px solid #111827;
      border-radius: 34px;
      box-shadow: 0 28px 70px rgba(20, 33, 61, .24);
      max-width: 240px;
      overflow: hidden;
      position: absolute;
    }

    .phone-shot img {
      display: block;
      width: 100%;
    }

    .phone-shot.primary {
      right: 110px;
      top: 0;
      z-index: 3;
    }

    .phone-shot.secondary {
      right: 0;
      top: 110px;
      transform: rotate(5deg);
      z-index: 2;
    }

    .phone-shot.tertiary {
      right: 220px;
      top: 155px;
      transform: rotate(-6deg);
      z-index: 1;
    }

    .badge-soft {
      background: var(--ravens-sky);
      color: #0f4c81;
    }

    .stat {
      border-left: 4px solid var(--ravens-green);
      padding-left: 1rem;
    }

    .cta-band {
      background: var(--ravens-ink);
      color: #fff;
    }

    @media (max-width: 991.98px) {
      .hero {
        min-height: auto;
      }

      .screenshot-stack {
        min-height: 440px;
      }

      .phone-shot {
        max-width: 190px;
      }

      .phone-shot.primary {
        left: calc(50% - 95px);
        right: auto;
      }

      .phone-shot.secondary {
        left: calc(50% + 20px);
        right: auto;
        top: 96px;
      }

      .phone-shot.tertiary {
        left: calc(50% - 205px);
        right: auto;
        top: 118px;
      }
    }

    @media (max-width: 575.98px) {
      .phone-shot.secondary,
      .phone-shot.tertiary {
        display: none;
      }

      .screenshot-stack {
        min-height: 410px;
      }
    }
  </style>
</head>
<body>
  <div class="page">
    <header class="navbar navbar-expand-md bg-transparent py-4">
      <div class="container-xl">
        <a class="navbar-brand d-flex align-items-center gap-3" href="https://www.tastenbraille.com/ravens/index.php">
          <img src="images/ravens.png" class="rounded-3" width="44" height="44" alt="Ravens logo">
          <span class="fw-bold fs-2">Ravens</span>
        </a>
        <div class="navbar-nav flex-row gap-2">
          <a class="btn btn-outline-primary" href="https://apps.apple.com/nl/app/ravens/id6475675260">
            <i class="ti ti-brand-apple me-2"></i>App Store
          </a>
        </div>
      </div>
    </header>

    <main>
      <section class="hero">
        <div class="container-xl py-5">
          <div class="row align-items-center g-5">
            <div class="col-lg-6">
              <img src="images/ravens.png" class="app-logo mb-4" alt="Ravens app icoon">
              <div class="mb-3">
                <span class="badge badge-soft">Waarneming.nl</span>
                <span class="badge badge-soft">Observation.org</span>
                <span class="badge badge-soft">VoiceOver ready</span>
              </div>
              <h1 class="display-4 fw-bold mb-3">Ravens brengt natuurwaarnemingen dichtbij.</h1>
              <p class="fs-2 text-secondary mb-4">
                Bekijk recente waarnemingen op kaart en in lijsten, ontdek soorten in je omgeving en open direct de details die je nodig hebt in het veld.
              </p>
              <div class="d-flex flex-wrap gap-3">
                <a class="btn btn-primary btn-lg" href="https://apps.apple.com/nl/app/ravens/id6475675260">
                  <i class="ti ti-download me-2"></i>Download Ravens
                </a>
                <a class="btn btn-outline-primary btn-lg" href="privacy-policy/indexdutch.html">
                  <i class="ti ti-shield-lock me-2"></i>Privacy
                </a>
                <a class="btn btn-outline-primary btn-lg" href="manual.html">
                  <i class="ti ti-book me-2"></i>Handleiding
                </a>
              </div>
            </div>

            <div class="col-lg-6">
              <div class="screenshot-stack">
                <div class="phone-shot primary">
                  <img src="images/speciesList.png" alt="Ravens soortenlijst">
                </div>
                <div class="phone-shot secondary">
                  <img src="images/radiusMap.png" alt="Ravens kaart">
                </div>
                <div class="phone-shot tertiary">
                  <img src="images/audioListPlay.png" alt="Ravens geluiden">
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="container-xl pb-5">
        <div class="row g-4">
          <div class="col-md-6 col-xl-3">
            <div class="island feature-island p-4">
              <span class="icon-bubble mb-3"><i class="ti ti-map-pin"></i></span>
              <h2 class="h3">Dichtbij</h2>
              <p class="text-secondary mb-0">Zie wat er rond jouw locatie is waargenomen en pas radius, periode en soortgroep aan.</p>
            </div>
          </div>
          <div class="col-md-6 col-xl-3">
            <div class="island feature-island p-4">
              <span class="icon-bubble mb-3"><i class="ti ti-map"></i></span>
              <h2 class="h3">Kaart en lijst</h2>
              <p class="text-secondary mb-0">Schakel soepel tussen overzichtelijke lijsten en kaarten met waarnemingen.</p>
            </div>
          </div>
          <div class="col-md-6 col-xl-3">
            <div class="island feature-island p-4">
              <span class="icon-bubble mb-3"><i class="ti ti-leaf"></i></span>
              <h2 class="h3">Soorten</h2>
              <p class="text-secondary mb-0">Open foto, Wikipedia-informatie, waarnemingen en geluiden vanuit de soortdetails.</p>
            </div>
          </div>
          <div class="col-md-6 col-xl-3">
            <div class="island feature-island p-4">
              <span class="icon-bubble mb-3"><i class="ti ti-accessible"></i></span>
              <h2 class="h3">Toegankelijk</h2>
              <p class="text-secondary mb-0">Ravens is gebouwd voor iPhone en is bruikbaar met VoiceOver.</p>
            </div>
          </div>
        </div>
      </section>

      <section class="container-xl pb-5">
        <div class="island p-4 p-lg-5">
          <div class="row g-4 align-items-center">
            <div class="col-lg-5">
              <h2 class="display-6 fw-bold mb-3">Voor snelle natuurverkenning.</h2>
              <p class="text-secondary fs-3 mb-4">
                Ravens gebruikt gegevens van vrijwilligers via Waarneming.nl en Observation.org. Je kunt inloggen met je Waarneming.nl-account en je eigen omgeving, soorten en observaties bekijken.
              </p>
              <div class="row g-3">
                <div class="col-sm-6">
                  <div class="stat">
                    <div class="h2 mb-0">iOS 17+</div>
                    <div class="text-secondary">iPhone app</div>
                  </div>
                </div>
                <div class="col-sm-6">
                  <div class="stat">
                    <div class="h2 mb-0">NL / EN</div>
                    <div class="text-secondary">Meertalig</div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-lg-7">
              <div class="row g-3">
                <div class="col-sm-6">
                  <img src="images/viewsLocation.png" class="img-fluid rounded-4 shadow-sm" alt="Ravens locatiescherm">
                </div>
                <div class="col-sm-6">
                  <img src="images/audioListPlay.png" class="img-fluid rounded-4 shadow-sm" alt="Ravens geluidenlijst">
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="cta-band py-5">
        <div class="container-xl">
          <div class="row align-items-center g-4">
            <div class="col-lg-8">
              <h2 class="display-6 fw-bold mb-2">Download Ravens in de App Store.</h2>
              <p class="fs-3 text-white-50 mb-0">Voor iedereen die recente natuurwaarnemingen snel wil bekijken op een iPhone.</p>
            </div>
            <div class="col-lg-4 text-lg-end">
              <a class="btn btn-light btn-lg" href="https://apps.apple.com/nl/app/ravens/id6475675260">
                <i class="ti ti-brand-apple me-2"></i>Open App Store
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>

    <footer class="py-4">
      <div class="container-xl d-flex flex-column flex-md-row justify-content-between gap-3 text-secondary">
        <div>Ravens - natuurwaarnemingen voor iPhone</div>
        <div class="d-flex gap-3">
          <a href="https://www.tastenbraille.com/ravens/index.php">Website</a>
          <a href="manual.html">Handleiding</a>
          <a href="privacy-policy/indexdutch.html">Privacy</a>
          <a href="mailto:edequartel@protonmail.com">Contact</a>
        </div>
      </div>
    </footer>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/@tabler/core@latest/dist/js/tabler.min.js"></script>
</body>
</html>
