#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <QString>

// sailjail data
const char APP_NAME[] = "harbour-fussball-de";
const char ORGANISATION[] = "de.andreas-wuest-it-consulting";

// Competition that is used as long as the user has not configured any competition.
const char DefaultCompetitionId[] = "ac5e71aa-1ee8-4579-9508-1a2f27fe240d";

// Build the endpoint URL that delivers the JSON payload of one game day of a competition.
inline QString gameResultsEndpoint(const QString &competitionId, int matchDay)
{
    return QStringLiteral("https://next.fussball.de/_next/data/3GE9wzufdQY_tRu-Qkpfs/de/widget/"
                          "competition/%1/spieltag/%2.json")
        .arg(competitionId)
        .arg(matchDay);
}

#endif // CONSTANTS_H
