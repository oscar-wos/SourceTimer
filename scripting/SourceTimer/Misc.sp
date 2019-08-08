bool Misc_CheckPlayer(int iClient, int iType, bool bMessage = false) {
	char[] cBuffer = new char[512];

	if (iType >= PLAYER_ALIVE) if (!IsPlayerAlive(iClient)) {
		if (bMessage) { Format(cBuffer, 512, "%s%s%t", TEXT_PREFIX, TEXT_DEFAULT, "check_alive", TEXT_HIGHLIGHT, TEXT_DEFAULT); Timer_CommandReply(iClient, cBuffer); }
		return false;
	}

	if (iType >= PLAYER_INGAME) if (iClient == 0 || !IsValidEntity(iClient) || !IsClientInGame(iClient)) {
		if (bMessage) { Format(cBuffer, 512, "%s%s%t", TEXT_PREFIX, TEXT_DEFAULT, "check_ingame", TEXT_HIGHLIGHT, TEXT_DEFAULT); Timer_CommandReply(iClient, cBuffer); }
		return false;
	}

	if (iType >= PLAYER_VALID) if (IsFakeClient(iClient)) return false;

	return true;
}

void Misc_PrecacheModels() {
	g_Global.Models.BlueGlow = PrecacheModel("sprites/blueglow1.vmt");
	g_Global.Models.RedGlow = PrecacheModel("sprites/purpleglow1.vmt");
	g_Global.Models.Laser = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_Global.Models.Glow = PrecacheModel("materials/sprites/glow01.vmt");
	g_Global.Models.Zone = PrecacheModel("models/error.mdl");
}

void Misc_CalculateCentre(float xPos[3], float yPos[3], float fCentre[3]) {
	for (int i = 0; i < 3; i++) { fCentre[i] = (xPos[i] + yPos[i]) / 2; }
}

/*
void Misc_CalculateSpawn(float xPos[3], float yPos[3], float fSpawn[3]) {
	for (int i = 0; i < 3; i++) { fSpawn[i] = (xPos[i] + yPos[i]) / 2; }

	if (xPos[2] <= yPos[2]) { fSpawn[2] = xPos[2] + 100.0; }
	else { fSpawn[2] = yPos[2] + 100.0; }
}
*/

int Misc_CalculateZoneType(int iType) {
	return iType % ZONES_TOTAL;
}

int Misc_CalculateZoneGroup(int iGroup) {
	return iGroup % g_Global.ZoneGroups;
}
