//
//  Accessibility.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/11/2024.
//

// File: AccessibilityConstants.swift

struct AccessibilityConstants {
  struct Buttons {
    static let submit = "Submit button"
    static let cancel = "Cancel button"

//audioplayer
    static let play = "play the sound"
    static let pause = "pause the sound"
    static let next = "play the next sound"
    static let previous = "play the previous sound"
//buttons
    static let share = "Share this observation"
    static let information = "Get information about the species"
    static let linkObservation = "Go to the observation at waarneming.nl"
    static let favoriteSpecies = "Add or remove species to favorites"
    static let favoriteObserver = "Add or remove observer to favorites"
    static let favoriteLocation = "Add or Remove location to favorites"

//Toolbar
    static let sortAndFilterObservationList = "Sort and filter the list with observations"
    static let updateLocation = "Update the location of the observations"
    static let listWithFavoriteLocation = "List with favorite locations"
    static let searchForLocation = "Search for a location"

    static let addLocationToFavorite = "Add this location to favorites"
    static let removeLocationFromFavorite = "Remove this location from favorites"

    static let toggleViewMapList = "Toggle between map or list view"


  }

  struct Labels {
//    static let userName = "User Name label"
//    static let password = "Password label"
    static let searchForLocation = "Search for a location"
  }

  struct Hints {
    static let submitHint = "Double-tap to submit the form"
//    static let cancelHint = "Double-tap to cancel and go back"
  }

  struct Images {
    static let logo = "App logo"
//    static let profilePicture = "User profile picture"
  }
}
