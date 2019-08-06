void Zone_Draw(float xPos[3], float yPos[3], int iColor, float fDisplay, bool bAll, int iClient = 0) {
	float fPoints[8][3];

	fPoints[0] = xPos;
	fPoints[7] = yPos;

	fPoints[1][0] = fPoints[0][0];
	fPoints[1][1] = fPoints[7][1];
	fPoints[1][2] = fPoints[0][2];

	fPoints[2][0] = fPoints[7][0];
	fPoints[2][1] = fPoints[0][1];
	fPoints[2][2] = fPoints[0][2];

	fPoints[3][0] = fPoints[7][0];
	fPoints[3][1] = fPoints[7][1];
	fPoints[3][2] = fPoints[0][2];

	fPoints[4][0] = fPoints[0][0];
	fPoints[4][1] = fPoints[0][1];
	fPoints[4][2] = fPoints[7][2];

	fPoints[5][0] = fPoints[0][0];
	fPoints[5][1] = fPoints[7][1];
	fPoints[5][2] = fPoints[7][2];

	fPoints[6][0] = fPoints[7][0];
	fPoints[6][1] = fPoints[0][1];
	fPoints[6][2] = fPoints[7][2];

	for (int i = 0; i < 4; i++) { Zone_DrawLine(fPoints[i], fPoints[i + 4], C_Colors[iColor], fDisplay, bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[0], fPoints[i + 1], C_Colors[iColor], fDisplay, bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[3], fPoints[i + 1], C_Colors[iColor], fDisplay, bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[4], fPoints[i + 5], C_Colors[iColor], fDisplay, bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[7], fPoints[i + 5], C_Colors[iColor], fDisplay, bAll, iClient); }
}

void Zone_DrawAdmin(int iClient, float xPos[3]) {
	float yPos[3];

	for (int i = 0; i < 3; i++) {
		for (int k = 0; k < 3; k++) { yPos[k] = xPos[k]; }

		yPos[i] += 66.6;
		Zone_DrawLine(xPos, yPos, C_Colors[i], TIMER_INTERVAL, false, iClient);
	}
}

void Zone_RayTrace(int iClient, float fPos[3]) {
	float fEye[3], fAngle[3];
	GetClientEyePosition(iClient, fEye);
	GetClientEyeAngles(iClient, fAngle);

	TR_TraceRayFilter(fEye, fAngle, MASK_SOLID, RayType_Infinite, Filter_HitSelf, iClient);
	if (TR_DidHit()) { TR_GetEndPosition(fPos); }
}

void Zone_DrawSprite(float fPos[3], int iModel, float fSize, bool bAll, int iClient = 0) {
	if (iModel == 0) { TE_SetupGlowSprite(fPos, g_Global.Models.BlueGlow, TIMER_INTERVAL, fSize, 249); }
	else { TE_SetupGlowSprite(fPos, g_Global.Models.RedGlow, TIMER_INTERVAL, fSize, 249); }

	if (bAll) { TE_SendToAll(); }
	else { TE_SendToClient(iClient); }
}

void Zone_DrawLine(float xPos[3], float yPos[3], int iColor[4], float fDisplay, bool bAll, int iClient = 0) {
	TE_SetupBeamPoints(xPos, yPos, g_Global.Models.Laser, g_Global.Models.Glow, 0, 30, fDisplay, 1.0, 1.0, 2, 1.0, iColor, 0);

	if (bAll) { TE_SendToAll(); }
	else { TE_SendToClient(iClient); }
}

void Zone_SaveZone(int iClient) {
	Player pPlayer = g_Global.Players.Get(iClient);
	float xPos[3], yPos[3];

	pPlayer.Admin.Zone.GetX(xPos);
	pPlayer.Admin.Zone.GetY(yPos);

	Zone_NewZone(xPos, yPos, pPlayer.Admin.Zone.Type, pPlayer.Admin.Zone.Group);
}

void Zone_NewZone(float xPos[3], float yPos[3], int iType, int iGroup) {
	Zone zZone = new Zone();

	zZone.SetX(xPos);
	zZone.SetY(yPos);
	zZone.Type = iType;
	zZone.Group = iGroup;
	zZone.Entity = CreateEntityByName("trigger_multiple");

	if (zZone.Entity > 0 && IsValidEntity(zZone.Entity)) {
		char[] cBuffer = new char[512];
		SetEntityModel(zZone.Entity, "models/error.mdl");

		Format(cBuffer, 512, "%i: timer_zone", g_Global.Zones.Length);
		DispatchKeyValue(zZone.Entity, "targetname", cBuffer);
		DispatchKeyValue(zZone.Entity, "spawnflags", "257");
		DispatchKeyValue(zZone.Entity, "StartDisabled", "0");

		if (DispatchSpawn(zZone.Entity)) {
			float fMid[3], fVecMin[3], fVecMax[3];
			ActivateEntity(zZone.Entity);

			g_Global.Zones.CalculateCentre(xPos, yPos, fMid);
			MakeVectorFromPoints(fMid, xPos, fVecMin);
			MakeVectorFromPoints(yPos, fMid, fVecMax);

			for (int i = 0; i < 3; i++) {
				if (fVecMin[i] > 0.0) { fVecMin[i] *= -1; }
				else if (fVecMax[i] < 0.0) { fVecMax[i] *= -1; }
			}

			SetEntPropVector(zZone.Entity, Prop_Send, "m_vecMins", fVecMin);
			SetEntPropVector(zZone.Entity, Prop_Send, "m_vecMaxs", fVecMax);

			SetEntProp(zZone.Entity, Prop_Send, "m_nSolidType", 2);
			TeleportEntity(zZone.Entity, fMid, NULL_VECTOR, NULL_VECTOR);

			SDKHook(zZone.Entity, SDKHook_StartTouch, Entity_StartTouch);
			SDKHook(zZone.Entity, SDKHook_EndTouch, Entity_EndTouch);
		}
	}

	g_Global.Zones.Push(zZone);
}

public Action Entity_StartTouch(int iCaller, int iActivator) {
	if (!Misc_CheckPlayer(iActivator, PLAYER_INGAME)) { return; }
	char[] cEntityName = new char[512];
	char[] cEntityIndex = new char[16];
	int iIndex;

	GetEntPropString(iCaller, Prop_Send, "m_iName", cEntityName, 512);
	SplitString(cEntityName, ":", cEntityIndex, 16);
	iIndex = StringToInt(cEntityIndex);

	Player pPlayer = g_Global.Players.Get(iActivator);
	Zone zZone = g_Global.Zones.Get(iIndex);

	switch (zZone.Type) {
		case 0: { if (pPlayer.StartTime != -1.0) { PrintToChatAll("Player Checkpoint: %f", GetGameTime() - pPlayer.StartTime); } }
		case 1: { pPlayer.StartTime = -1.0; }
		case 2: { if (pPlayer.StartTime != -1.0) { PrintToChatAll("Player Finished: %f", GetGameTime() - pPlayer.StartTime); pPlayer.StartTime = -1.0; } }
	}

	pPlayer.ZoneType = zZone.Type;
	pPlayer.ZoneGroup = zZone.Group;
}

public Action Entity_EndTouch(int iCaller, int iActivator) {
	if (!Misc_CheckPlayer(iActivator, PLAYER_INGAME)) { return; }
	char[] cEntityName = new char[512];
	char[] cEntityIndex = new char[16];
	int iIndex;

	GetEntPropString(iCaller, Prop_Send, "m_iName", cEntityName, 512);
	SplitString(cEntityName, ":", cEntityIndex, 16);
	iIndex = StringToInt(cEntityIndex);

	Player pPlayer = g_Global.Players.Get(iActivator);
	Zone zZone = g_Global.Zones.Get(iIndex);

	switch (zZone.Type) {
		case 0: { }
		case 1: { pPlayer.StartTime = GetGameTime(); }
		case 2: { }
	}

	pPlayer.ZoneType = -1;
	pPlayer.ZoneGroup = zZone.Group;
}

void Timer_Zone() {
	for (int i = 0; i < TIMER_ZONES && g_Global.RenderedZone < g_Global.Zones.Length; i++) {
		Zone zZone = g_Global.Zones.Get(g_Global.RenderedZone);

		float xPos[3], yPos[3];
		zZone.GetX(xPos);
		zZone.GetY(yPos);

		int iColor = zZone.Type + 5;
		if (zZone.Group > 0) { iColor += 3; }

		Zone_Draw(xPos, yPos, iColor, TIMER_INTERVAL + (g_Global.Zones.Length / TIMER_ZONES) * TIMER_INTERVAL, true);
		g_Global.RenderedZone++;
	}

	if (g_Global.RenderedZone == g_Global.Zones.Length) { g_Global.RenderedZone = 0; }
}

bool Filter_HitSelf(int iEntity, int iMask, any aData) {
	if (iEntity == aData) { return false; }
	return true;
}
