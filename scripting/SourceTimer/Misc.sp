bool Misc_CheckPlayer(int iClient, int iType, bool bMessage = false) {
	char[] cBuffer = new char[512];

	if (iType >= PLAYER_VALID) if (IsFakeClient(iClient)) return false;

	if (iType >= PLAYER_INGAME) if (iClient == 0 || !IsValidEntity(iClient) || !IsClientInGame(iClient)) {
		if (bMessage) { Format(cBuffer, 512, "%s%s%t", TEXT_PREFIX, TEXT_DEFAULT, "check_ingame", TEXT_HIGHLIGHT, TEXT_DEFAULT); Timer_CommandReply(iClient, cBuffer); }
		return false;
	}

	if (iType >= PLAYER_ALIVE) if (!IsPlayerAlive(iClient)) {
		if (bMessage) { Format(cBuffer, 512, "%s%s%t", TEXT_PREFIX, TEXT_DEFAULT, "check_alive", TEXT_HIGHLIGHT, TEXT_DEFAULT); Timer_CommandReply(iClient, cBuffer); }
		return false;
	}

	return true;
}

int Misc_CalculateZoneType(int iType) {
	return iType % ZONES_TOTAL;
}

int Misc_CalculateZoneGroup(int iGroup) {
	return iGroup % g_Global.ZoneGroups;
}
