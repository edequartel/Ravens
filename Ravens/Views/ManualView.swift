//
//  ManualView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import SwiftUI
import MarkdownUI

//## Installatie
//1. Download en installeer de *Ravens* app vanuit de [App Store](link-naar-app-store) of [Google Play Store](link-naar-google-play) op je mobiele apparaat.

struct ManualView: View {
    let markdownString = """
      # Ravens

      De **Ravens** app biedt gebruikers de mogelijkheid om **waarnemingen** te zien in zowel op een kaart als in een lijst. Deze app haalt de meest recente informatie van [www.waarneming.nl](https://www.waarneming.nl) en presenteert deze gegevens op een overzichtelijke manier. Hieronder volgt een uitleg over hoe je de app kunt gebruiken en instellen.

      ### Weergave van waarnemingen
      - De app toont waarnemingen in zowel een kaart als in een lijst.
      - Door op de kaart een locatie aan te tikken zie je in een straal de waarneming die in dit gebied voor de gekozen periode zijn gemeld.
      - Kies de datum waarvan je de waarneming wilt zien. Het aantal dagen zijn de dagen voor de datum.
      - Op de kaart en lijst worden de meest zeldzame soorten met kleuren aangegeven. (groen: algemeen, blauw: minder algemeen, oranje: zeldzaam, rood: zeer zeldzaam). In de lijst staan de meest zeldzame bovenaan. Door op de waarneming te tikken ga je naar de waarneming van op waarneming.nl
        
      ### Gegevensbron
      - De app haalt de meest recente informatie van [www.waarneming.nl](https://www.waarneming.nl).

      ### Instellingen
      - Ga naar de instellingen van de app om specifieke voorkeuren in te stellen.
      - Bepaal welke soortengroepen je wilt zien.
      - Stel de straal in waarin je waarnemingen wilt bekijken.
      - Stel het aantal dagen in waarvan je de waarneming wilt zien.


      ### Limiet van waarnemingen
      - Om het overzichtelijk te houden, toont de app niet meer dan 100 waarnemingen.
      - Als er meer dan 100 waarnemingen zijn in het geselecteerde gebied, overweeg dan de straal en het aantal dagen te verkleinen.
      

      ## Belangrijk om te weten

      - Deze app maakt gebruik van de data die vrij wordt gegeven door [www.waarneming.nl](https://www.waarneming.nl).
      - Er is geen inlogcode of inlognaam nodig om de app te gebruiken. De maakt daarom ook geen inbreuk op je privacy.
      
      Deze app heb is gemaakt om het struinen in de natuur nog leuker te maken. De app is gratis. Heb je een opmerkingen om de app beter te maken mail me dan (edequartel@protonmail).

      Met de *Ravens* app heb je snel en eenvoudig toegang tot recente waarnemingen in jouw geselecteerde gebied. Veel plezier met het ontdekken van de natuur om je heen!

      """

    var body: some View {
        Form {
            Markdown(markdownString)
        }
        
    }
}

#Preview {
    ManualView()
}
