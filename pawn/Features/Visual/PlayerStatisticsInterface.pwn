// Copyright 2006-2015 Las Venturas Playground. All rights reserved.
// Use of this source code is governed by the GPLv2 license, a copy of which can
// be found in the LICENSE file.

new bool: g_InterfaceBlockedByJavaScript[MAX_PLAYERS];

/**
 * Players need a direct feed of information regarding some usefull statistics; ping, FPS, packetloss,
 * kills, death and kill/death ratio. This is, besides from money, important information a player
 * likes to know.
 *
 * @author Max "Cake" Blokker <cake@sa-mp.nl>
 */
class PlayerStatisticsInterface {
    // How many textdraws does the interface consist of?
    const PlayerStatisticsTextDraws = 9;

    // Mark if the statistics box is hidden or not.
    new bool: m_playerStatisticsHidden[MAX_PLAYERS];

    // For every player we create 9 player textdraws to show them their own statistics.
    new PlayerText: m_playerStatisticsTextDraw[PlayerStatisticsTextDraws][MAX_PLAYERS];

    // A cache that stores the current integral values displayed in a player's text draws.
    new m_textDrawIntCache[MAX_PLAYERS][4];

    // A cache that stores the current floating point values displayed in a player's text draws.
    new Float: m_textDrawFloatCache[MAX_PLAYERS];

    /**
     * Clears the stored cached values for the |player|.
     */
    private clearCacheForPlayer(playerId) {
        for (new i = 0; i < sizeof(m_textDrawIntCache[]); ++i)
            m_textDrawIntCache[playerId][i] = -1;

        m_textDrawFloatCache[playerId] = -1.0;
    }

    /**
     * A function showing the needed textdraws if the statistics interface needs to be shown.
     *
     * @param playerId Id of the player we are showing the player statistics for.
     */
    public showPlayerStatistics(playerId) {
        if (m_playerStatisticsHidden[playerId] == false)
            return 0;

        for (new textDraw = 0; textDraw < PlayerStatisticsTextDraws; textDraw++)
            PlayerTextDrawShow(playerId, m_playerStatisticsTextDraw[textDraw][playerId]);

        this->clearCacheForPlayer(playerId);

        m_playerStatisticsHidden[playerId] = false;

        return 1;
    }

    /**
     * A function hiding the needed textdraws if the statistics interface needs to be hidden.
     *
     * @param playerId Id of the player we are hiding the player statistics for.
     */
    public hidePlayerStatistics(playerId) {
        if (m_playerStatisticsHidden[playerId] == true)
            return 0;

        for (new textDraw = 0; textDraw < PlayerStatisticsTextDraws; textDraw++)
            PlayerTextDrawHide(playerId, m_playerStatisticsTextDraw[textDraw][playerId]);

        this->clearCacheForPlayer(playerId);

        m_playerStatisticsHidden[playerId] = true;

        return 1;
    }

    /**
     * Upon connecting, the various textdraws have to be created for a player.
     *
     * @param playerId Id of the player who connected to the server.
     */
    @list(OnPlayerConnect)
    public onPlayerConnect(playerId) {
        m_playerStatisticsHidden[playerId] = true;
        g_InterfaceBlockedByJavaScript[playerId] = false;

        for (new textDraw = 0; textDraw < PlayerStatisticsTextDraws; textDraw++)
            m_playerStatisticsTextDraw[textDraw][playerId] = PlayerText: INVALID_TEXT_DRAW;

        this->clearCacheForPlayer(playerId);

        // The white separation line between top and bottom statistics.
        m_playerStatisticsTextDraw[0][playerId] = CreatePlayerTextDraw(playerId, 556.0, 397.0, "_");

        PlayerTextDrawAlignment(playerId, m_playerStatisticsTextDraw[0][playerId], 2);
        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[0][playerId], 255);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[0][playerId], 1);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[0][playerId], 0.5, -0.4);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[0][playerId], -1);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[0][playerId], 0);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[0][playerId], 1);
        PlayerTextDrawSetShadow(playerId, m_playerStatisticsTextDraw[0][playerId], 1);
        PlayerTextDrawUseBox(playerId, m_playerStatisticsTextDraw[0][playerId], 1);
        PlayerTextDrawBoxColor(playerId, m_playerStatisticsTextDraw[0][playerId], -1);
        PlayerTextDrawTextSize(playerId, m_playerStatisticsTextDraw[0][playerId], 0.0, 95.0);

        // The 'Ping/FPS/Loss' string textdraw.
        m_playerStatisticsTextDraw[1][playerId] = CreatePlayerTextDraw(playerId, 532.0, 373.0,
            "PING            FPS");//           LOSS");

        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[1][playerId], -1);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[1][playerId], 2);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[1][playerId], 0.15, 0.799998);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[1][playerId], -1261639425);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[1][playerId], 0);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[1][playerId], 1);
        PlayerTextDrawSetShadow(playerId, m_playerStatisticsTextDraw[1][playerId], 0);

        // The 'Ping' value textdraw.
        m_playerStatisticsTextDraw[2][playerId] = CreatePlayerTextDraw(playerId, 540.0, 381.0, "_");

        PlayerTextDrawAlignment(playerId, m_playerStatisticsTextDraw[2][playerId], 2);
        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[2][playerId], 255);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[2][playerId], 3);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[2][playerId], 0.349999, 1.1);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[2][playerId], Color::PlayerStatistics);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[2][playerId], 1);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[2][playerId], 1);

        // The 'FPS' value textdraw.
        m_playerStatisticsTextDraw[3][playerId] = CreatePlayerTextDraw(playerId, 573.0, 381.0, "_");

        PlayerTextDrawAlignment(playerId, m_playerStatisticsTextDraw[3][playerId], 2);
        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[3][playerId], 255);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[3][playerId], 3);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[3][playerId], 0.349999, 1.1);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[3][playerId], Color::PlayerStatistics);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[3][playerId], 1);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[3][playerId], 1);

        // The 'Packetloss percentage' value textdraw.
        //m_playerStatisticsTextDraw[4][playerId] = CreatePlayerTextDraw(playerId, 590.0, 381.0, "_");

        //PlayerTextDrawAlignment(playerId, m_playerStatisticsTextDraw[4][playerId], 2);
        //PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[4][playerId], 255);
        //PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[4][playerId], 3);
        //PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[4][playerId], 0.349999, 1.1);
        //PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[4][playerId], Color::PlayerStatistics);
        //PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[4][playerId], 1);
        //PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[4][playerId], 1);

        // The 'Kills/Deaths/Ratio' string textdraw.
        m_playerStatisticsTextDraw[5][playerId] = CreatePlayerTextDraw(playerId, 513.0, 409.0,
            "KILLS       DEATHS       RATIO");

        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[5][playerId], -1);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[5][playerId], 2);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[5][playerId], 0.15, 0.799998);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[5][playerId], -1261639425);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[5][playerId], 0);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[5][playerId], 1);
        PlayerTextDrawSetShadow(playerId, m_playerStatisticsTextDraw[5][playerId], 0);

        // The 'Kills' value textdraw.
        m_playerStatisticsTextDraw[6][playerId] = CreatePlayerTextDraw(playerId, 521.0, 398.0, "_");

        PlayerTextDrawAlignment(playerId, m_playerStatisticsTextDraw[6][playerId], 2);
        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[6][playerId], 255);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[6][playerId], 3);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[6][playerId], 0.349999, 1.1);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[6][playerId], Color::PlayerStatistics);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[6][playerId], 1);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[6][playerId], 1);

        // The 'Deaths' value textdraw.
        m_playerStatisticsTextDraw[7][playerId] = CreatePlayerTextDraw(playerId, 553.0, 398.0, "_");

        PlayerTextDrawAlignment(playerId, m_playerStatisticsTextDraw[7][playerId], 2);
        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[7][playerId], 255);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[7][playerId], 3);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[7][playerId], 0.349999, 1.1);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[7][playerId], Color::PlayerStatistics);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[7][playerId], 1);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[7][playerId], 1);

        // The 'Ratio' value textdraw.
        m_playerStatisticsTextDraw[8][playerId] = CreatePlayerTextDraw(playerId, 588.0, 398.0, "_");

        PlayerTextDrawAlignment(playerId, m_playerStatisticsTextDraw[8][playerId], 2);
        PlayerTextDrawBackgroundColor(playerId, m_playerStatisticsTextDraw[8][playerId], 255);
        PlayerTextDrawFont(playerId, m_playerStatisticsTextDraw[8][playerId], 3);
        PlayerTextDrawLetterSize(playerId, m_playerStatisticsTextDraw[8][playerId], 0.349999, 1.1);
        PlayerTextDrawColor(playerId, m_playerStatisticsTextDraw[8][playerId], Color::PlayerStatistics);
        PlayerTextDrawSetOutline(playerId, m_playerStatisticsTextDraw[8][playerId], 1);
        PlayerTextDrawSetProportional(playerId, m_playerStatisticsTextDraw[8][playerId], 1);

        return 1;
    }

    /**
     * Upon disconnecting, the various textdraws have to be destroyed for a player.
     *
     * @param playerId Id of the player who disconnected from the server.
     */
    @list(OnPlayerDisconnect)
    public onPlayerDisconnect(playerId) {
        for (new textDraw = 0; textDraw < PlayerStatisticsTextDraws; textDraw++) {
            PlayerTextDrawDestroy(playerId, m_playerStatisticsTextDraw[textDraw][playerId]);
            m_playerStatisticsTextDraw[textDraw][playerId] = PlayerText: INVALID_TEXT_DRAW;
        }

        return 1;
    }

    /**
     * Every five seconds we check whether the statistics interface needs to be shown or hidden.
     * The statistics are then cycled through to update each one of them.
     * 
     * @param playerId Id of the player of who we update the userbar for.
     */
    @list(FiveSecondTimer)
    public updateStatisticsInterface() {
        for (new playerId = 0; playerId <= PlayerManager->highestPlayerId(); ++playerId) {
            if (!Player(playerId)->isConnected() || Player(playerId)->isNonPlayerCharacter())
                continue;

            if (g_InterfaceBlockedByJavaScript[playerId])
                continue;

            if (IsPlayerInMinigame(playerId) && m_playerStatisticsHidden[playerId] == false) {
                this->hidePlayerStatistics(playerId);
                continue;
            }

            if (!IsPlayerInMinigame(playerId) && m_playerStatisticsHidden[playerId] == true)
                this->showPlayerStatistics(playerId);

            new statisticString[12];

            // Ping
            new const ping = GetPlayerPing(playerId);
            if (m_textDrawIntCache[playerId][0 /* ping */] != ping) {
                m_textDrawIntCache[playerId][0 /* ping */] = ping;

                format(statisticString, sizeof(statisticString), "%d", ping);
                PlayerTextDrawSetString(playerId, m_playerStatisticsTextDraw[2][playerId], statisticString);
            }

            // FPS
            new const fps = PlayerManager->framesPerSecond(playerId);
            if (m_textDrawIntCache[playerId][1 /* fps */] != fps) {
                m_textDrawIntCache[playerId][1 /* fps */] = fps;

                format(statisticString, sizeof(statisticString), "%d", fps);
                PlayerTextDrawSetString(playerId, m_playerStatisticsTextDraw[3][playerId], statisticString);
            }

            // Kills
            new const kills = iPlayerSesKills[playerId];
            if (m_textDrawIntCache[playerId][2 /* kills */] != kills) {
                m_textDrawIntCache[playerId][2 /* kills */] = kills;

                format(statisticString, sizeof(statisticString), "%d", kills);
                PlayerTextDrawSetString(playerId, m_playerStatisticsTextDraw[6][playerId], statisticString);
            }

            // Deaths
            new const deaths = iPlayerSesDeaths[playerId];
            if (m_textDrawIntCache[playerId][3 /* deaths */] != deaths) {
                m_textDrawIntCache[playerId][3 /* deaths */] = deaths;

                format(statisticString, sizeof(statisticString), "%d", deaths);
                PlayerTextDrawSetString(playerId, m_playerStatisticsTextDraw[7][playerId], statisticString);
            }

            // Ratio
            new const Float: ratio =
                iPlayerSesDeaths[playerId] != 0 ? floatdiv(iPlayerSesKills[playerId], iPlayerSesDeaths[playerId])
                                                : float(iPlayerSesKills[playerId]);

            if (m_textDrawFloatCache[playerId] != ratio) {
                m_textDrawFloatCache[playerId] = ratio;

                format(statisticString, sizeof(statisticString), "%.2f", ratio);
                PlayerTextDrawSetString(playerId, m_playerStatisticsTextDraw[8][playerId], statisticString);
            }
        }
    }
};

forward OnToggleStatisticsDisplay(playerId, display);
public OnToggleStatisticsDisplay(playerId, display) {
    if (!Player(playerId)->isConnected())
        return;

    g_InterfaceBlockedByJavaScript[playerId] = !display;

    if (display)
        PlayerStatisticsInterface->showPlayerStatistics(playerId);
    else
        PlayerStatisticsInterface->hidePlayerStatistics(playerId);

    Check_Textdraw();
}

IsInterfaceBlockedByJavaScript(playerId) {
    return g_InterfaceBlockedByJavaScript[playerId];
}

