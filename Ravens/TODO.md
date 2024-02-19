#  Todo

- the api calls have to be cached
- show nrofobs on list view
- @AppStorage var bookMarks: [Int] = [] dit moet in swiftui data komen in settings()
- recursive (dont do this)
- login 
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
- errors
- mapobservationpecies no update
- species details crash

## Remarks

- BirdView zorg ervoor dat de bookMarks boven aan komen te staan
- dit betekent dat je ervoor moet zorgen dat de array bookMarks in swiftdata wordt opgeslagen
- bij inloggen zal het password en inlognaam opgehaald moeten worden uit de keychain om de token voor die sessie te verkijgen
- hier staat een voorbeeld van in SnippetsLab

**messages**

import SwiftyBeaver

let log = SwiftyBeaver.self

- log.verbose("not so important")  // prio 1, VERBOSE in silver
- log.debug("something to debug")  // prio 2, DEBUG in green
- log.info("a nice information")   // prio 3, INFO in blue
- log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
- log.error("ouch, an error did occur!")  // prio 5, ERROR in red


