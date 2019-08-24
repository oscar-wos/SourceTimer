void Misc_Start() {
	Misc_PrecacheModels();
	Misc_ConVars();
}

bool Misc_CheckPlayer(int iClient, int iType) {
	if (iClient < 1 || iClient >= MaxClients) return false;

	if (iType >= PLAYER_ENTITY) if (!IsValidEntity(iClient)) return false;
	if (iType >= PLAYER_CONNECTED) if (!IsClientConnected(iClient)) return false;
	if (iType >= PLAYER_INGAME) if (!IsClientInGame(iClient)) return false;
	if (iType >= PLAYER_VALID) if (IsFakeClient(iClient)) return false;
	if (iType >= PLAYER_ALIVE) if (!IsPlayerAlive(iClient)) return false;
	return true;
}

void Misc_PrecacheModels() {
	g_Global.Models.BlueGlow = PrecacheModel("sprites/blueglow1.vmt");
	g_Global.Models.RedGlow = PrecacheModel("sprites/purpleglow1.vmt");
	g_Global.Models.Laser = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_Global.Models.Glow = PrecacheModel("materials/sprites/glow01.vmt");
	g_Global.Models.Zone = PrecacheModel("models/error.mdl");
}

int Misc_CalculateZoneType(int iType) {
	return iType % ZONES_TOTAL;
}

int Misc_CalculateZoneGroup(int iGroup) {
	return iGroup % (g_Global.Zones.GetTotalZoneGroups() + 2);
}

void Misc_CalculateCentre(float xPos[3], float yPos[3], float fCentre[3]) {
	for (int i = 0; i < 3; i++) fCentre[i] = (xPos[i] + yPos[i]) / 2;
}

void Misc_CalculateSpawn(float xPos[3], float yPos[3], float fSpawn[3]) {
	for (int i = 0; i < 2; i++) fSpawn[i] = (xPos[i] + yPos[i]) / 2;
	if (xPos[2] < yPos[2]) fSpawn[2] = xPos[2];
	else fSpawn[2] = yPos[2];
}

void Misc_FormatTime(float fTime, char[] cBuffer, int iMaxLength) {
	int iMili = RoundToFloor(fTime * 1000);

	if (iMili < 0) iMili *= -1;
	if (iMili >= 3600000) { Format(cBuffer, iMaxLength, "%02d:", RoundToFloor(float(iMili) / 3600000)); iMili = iMili % 3600000; }
	Format(cBuffer, iMaxLength, "%s%02d:", cBuffer, RoundToFloor(float(iMili) / 60000)); iMili = iMili % 60000;
	Format(cBuffer, iMaxLength, "%s%02d.", cBuffer, RoundToFloor(float(iMili) / 1000)); iMili = iMili % 1000;
	Format(cBuffer, iMaxLength, "%s%03d", cBuffer, iMili);
}

void Misc_FormatTimePrefix(float fTime, float fDiff, char[] cBuffer, int iMaxLength) {
	if (fTime == 0) Format(cBuffer, iMaxLength, "\x0A%s\x01", cBuffer);
	else if (fDiff == 0) Format(cBuffer, iMaxLength, "\x10%s\x01", cBuffer);
	else if (fDiff > 0) Format(cBuffer, iMaxLength, "\x06+%s\x01", cBuffer);
	else Format(cBuffer, iMaxLength, "\x07-%s\x01", cBuffer);
}

Action Misc_Run(int iClient) {
	if (IsClientObserver(iClient)) {
		int iClientSpecMode = GetEntProp(iClient, Prop_Send, "m_iObserverMode");

		if (iClientSpecMode == 4 || iClientSpecMode == 5) {
			int iTarget = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
			if (iTarget != -1) Misc_ShowHud(iClient, iTarget);
		}
	} else {
		Misc_ShowHud(iClient, iClient);
	}
}

void Misc_ShowHud(int iClient, int iTarget) {
	if (gP_Player[iTarget].Record.StartTime > 0.0) {
		char[] cBuffer = new char[4096];
		char cTime[32];

		Misc_FormatTime(gP_Player[iTarget].Record.StartTime - GetGameTime(), cTime, sizeof(cTime));
		FormatEx(cBuffer, 4096, "Time: %s", cTime);
		PrintHintText(iClient, cBuffer);
	}
}

void Misc_StartTimer(int iClient) {
	if (GetEntityMoveType(iClient) != MOVETYPE_WALK) return;
	gP_Player[iClient].Record.StartTime = GetGameTime();
	gP_Player[iClient].RecentlyAbused = false;
	gP_Player[iClient].Replay.Frame = 0;
}

void Misc_ConVars() {
	char[] cBuffer = new char[512];

	BuildPath(Path_SM, cBuffer, 512, "configs/convars.txt");
	if (!FileExists(cBuffer)) return;

	File fConVar = OpenFile(cBuffer, "r");
	while (!fConVar.EndOfFile()) {
		if (fConVar.ReadLine(cBuffer, 512)) {
			char[][] cTemp = new char[2][64];
			ExplodeString(cBuffer, " ", cTemp, 2, 64);
			g_Global.Convars.SetString(cTemp[0], cTemp[1], true);

			ConVar cConVar = FindConVar(cTemp[0]);
			cConVar.SetString(cTemp[1]);
			cConVar.AddChangeHook(Hook_ConVarChange);
		}
	}
}