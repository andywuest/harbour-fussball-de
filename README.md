# harbour-fussball-de

A Sailfish OS client for the [fussball.de](https://www.fussball.de) widget. It
fetches match results and league tables for one or more configurable
competitions and displays them natively on your phone.
The application has been develop with the help of AI (opencode with the Big Pickle model).

## Features

- Results and table for a selected match day, shown in tabbed views.
- Swipe between match days; previous/next entries appear only within the
  competition's boundaries.
- Configurable list of competitions (competition id + description) in a
  settings page. The current competition and match day are persisted.
- Cover page showing one match at a time, with actions to cycle through the
  results.
- Decodes fussball.de's font-obfuscated JSON responses in C++.
- Caches downloaded fonts and team logos on the local filesystem to reduce
  network traffic.

## Building

Requires the Sailfish OS SDK. From the project directory:

```
sfdk build
```

The application is built with qmake and links against Qt Network and the
bundled Opal Tabs module.

## License

GNU General Public License v3 or later. See [LICENSE](LICENSE).

