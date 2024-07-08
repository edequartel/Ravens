# Remarks development

## 24
- are some design issues.
- The filter here will be adjusted in the future. Not optimal yet.
- In next version the selected image should be zoomable.
- The map should not overlap the safe area.

## 23
! cameraposition < span teruggeven naar callers >
- bug in settings, talen, vreemde response (!.pickerStyle(.navigationLink) changed)
! door de dagen en de waarneming gaan, kind of sheetview met instellingen
! opstarten met te veel fetches, fetches verspreiden over app (visie), 
    ! SpeciesViewModel, observationsSpeciesViewModel
    ! check how this is done with obs (is een system daar)
! folders obs /check these
! folder for data ones like regions (welke weg worden gehaald wanneer cache wordt geleegd)
! filemanager uitbreiden en in login setten als easter eggs (alleen onder mijn naam, if user is)
!! player in view no obs

? graphs
- second language
? notifications
? stats
? verstoringen 30 in radius geeft een foutmelding (ws waarneming)

## 22
- more accessible

## 20
- adjustments in lists location, observations
- adding locations

## 19

## 18
+ images now cached

## 17
+ scrolling through days (done in speciesview)
+ scrolling through obs (done in userview)
+ user positions (a start)
+ data requests timed 
+ data requests cached so data usage is less
+ audio-recording streamed

## ToDo

- the api calls have to be cached
- show nrofobs on list view
- @AppStorage var bookMarks: [Int] = [] dit moet in swiftui data komen in settings()
- recursive (dont do this)
- login x
- check dataload?
- shareview
- alerts new species
- colors
- select all species
- overview project in views pdf (v)
- camera position at start
- check log.'s
- species change name
- 200 regions error
- mapobservationpecies no update
- species details crash
