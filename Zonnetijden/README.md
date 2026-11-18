# Zonnetijden – simpele iPhone-app (SwiftUI)

Toont zonsopgang, zonsondergang en daglichtduur voor jouw locatie, met een knop voor vorige/volgende dag.
Alles wordt op het toestel berekend; er is geen internet of API-sleutel nodig.

## In Xcode zetten (±3 minuten)
1. Xcode → File → New → Project → iOS → **App** (Interface: SwiftUI, Language: Swift), naam `Zonnetijden`.
2. Verwijder de standaard `ContentView.swift` en `ZonnetijdenApp.swift` en sleep deze 4 `.swift`-bestanden in het project.
3. Target → **Info** → voeg toe: `Privacy - Location When In Use Usage Description` =
   `Om de zonsopgang en zonsondergang voor jouw locatie te tonen.`
4. Kies een iPhone-simulator of je eigen iPhone en druk op Run (▶).

Zonder locatietoestemming wordt Amsterdam gebruikt.
