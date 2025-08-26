# Assistant-Friendly Intents

Designing intents that play nicely with Apple Intelligence means choosing clear titles, offering synonyms, and providing useful context through `NSUserActivity`.

* Keep titles action-oriented and easy to pronounce.
* Supply synonyms for entity names so the assistant understands variations.
* When showing a detail screen, publish an `NSUserActivity` with identifiers so the assistant can act on the current screen.

