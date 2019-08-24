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
		for (int k = 0; k < 3; k++) yPos[k] = xPos[k];

		yPos[i] += 66.6;
		Zone_DrawLine(xPos, yPos, C_Colors[i], TIMER_INTERVAL, false, iClient);
	}
}

void Zone_RayTrace(int iClient, float fPos[3]) {
	float fEye[3], fAngle[3];
	GetClientEyePosition(iClient, fEye);
	GetClientEyeAngles(iClient, fAngle);

	TR_TraceRayFilter(fEye, fAngle, MASK_SOLID, RayType_Infinite, Filter_HitSelf, iClient);
	if (TR_DidHit()) TR_GetEndPosition(fPos);
}

void Zone_DrawSprite(float fPos[3], int iModel, float fSize, bool bAll, int iClient = 0) {
	if (iModel == 0) TE_SetupGlowSprite(fPos, g_Global.Models.BlueGlow, TIMER_INTERVAL, fSize, 249);
	else TE_SetupGlowSprite(fPos, g_Global.Models.RedGlow, TIMER_INTERVAL, fSize, 249);

	if (bAll) TE_SendToAll();
	else TE_SendToClient(iClient);
}

void Zone_DrawLine(float xPos[3], float yPos[3], int iColor[4], float fDisplay, bool bAll, int iClient = 0) {
	TE_SetupBeamPoints(xPos, yPos, g_Global.Models.Laser, g_Global.Models.Glow, 0, 30, fDisplay, 1.0, 1.0, 2, 1.0, iColor, 0);

	if (bAll) TE_SendToAll();
	else TE_SendToClient(iClient);
}

void Zone_New(float xPos[3], float yPos[3], int iType, int iGroup, int iId) {
	if (iType == ZONE_START || iType == ZONE_END) {
		int iIndex = g_Global.Zones.FindSingleZone(iType, iGroup);
		if (iIndex != -1) {
			Zone zZone;
			g_Global.Zones.GetArray(iIndex, zZone);

			if (iId != zZone.Id) {
				Zone_DeleteZone(zZone.Id);
				Sql_DeleteZone(zZone.Id);
			}
		}
	}

	if (iId != 0) {
		Zone_UpdateZone(xPos, yPos, iType, iGroup, iId);
		Sql_UpdateZone(iId, xPos, yPos, iType, iGroup);
	} else {
		Zone_AddZone(xPos, yPos, iType, iGroup);
		Sql_AddZone(g_Global.Zones.Length - 1, xPos, yPos, iType, iGroup);
	}

	Zone_Reload();
}

void Zone_DeleteZone(int iId) {
	int iIndex = g_Global.Zones.FindByZoneId(iId);
	if (iIndex == -1) return;
	g_Global.Zones.Erase(iIndex);
}

void Zone_UpdateZone(float xPos[3], float yPos[3], int iType, int iGroup, int iId) {
	int iIndex = g_Global.Zones.FindByZoneId(iId);
	if (iIndex == -1) return;

	Zone zZone;
	g_Global.Zones.GetArray(iIndex, zZone);
	if (zZone.Type != iType) for (int i = 0; i <= MaxClients; i++) zZone.RecordIndex[i] = -1;

	zZone.SetX(xPos);
	zZone.SetY(yPos);
	zZone.Type = iType;
	zZone.Group = iGroup;
	g_Global.Zones.SetArray(iIndex, zZone);
}

void Zone_AddZone(float xPos[3], float yPos[3], int iType, int iGroup, int iId = 0) {
	Zone zZone;
	for (int i = 0; i <= MaxClients; i++) zZone.RecordIndex[i] = -1;

	zZone.SetX(xPos);
	zZone.SetY(yPos);
	zZone.Type = iType;
	zZone.Group = iGroup;
	zZone.Id = iId;
	g_Global.Zones.PushArray(zZone);
}

void Zone_Reload() {
	char [] cEntityName = new char[512];

	for (int i = 0; i <= GetMaxEntities(); i++) {
		if (!IsValidEdict(i) || !IsValidEntity(i)) continue;
		if (!HasEntProp(i, Prop_Send, "m_iName")) continue;
		GetEntPropString(i, Prop_Send, "m_iName", cEntityName, 512);

		if (StrContains(cEntityName, "timer_zone") == -1) continue;
		AcceptEntityInput(i, "Kill");
	}

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		Zone zZone;
		g_Global.Zones.GetArray(i, zZone);

		int iEntity = CreateEntityByName("trigger_multiple");
		if (iEntity == 0 || !IsValidEntity(iEntity)) continue;

		char[] cBuffer = new char[512];
		Format(cBuffer, 512, "%i: timer_zone", i);

		SetEntityModel(iEntity, "models/error.mdl");
		DispatchKeyValue(iEntity, "targetname", cBuffer);
		DispatchKeyValue(iEntity, "spawnflags", "1088");
		DispatchKeyValue(iEntity, "StartDisabled", "0");

		if (!DispatchSpawn(iEntity)) continue;

		float xPos[3], yPos[3], fMid[3], fVecMin[3], fVecMax[3];
		ActivateEntity(iEntity);

		zZone.GetX(xPos);
		zZone.GetY(yPos);

		Misc_CalculateCentre(xPos, yPos, fMid);
		MakeVectorFromPoints(fMid, xPos, fVecMin);
		MakeVectorFromPoints(yPos, fMid, fVecMax);

		for (int k = 0; k < 3; k++) {
			if (fVecMin[k] > 0.0) fVecMin[k] *= -1;
			else if (fVecMax[k] < 0.0) fVecMax[k] *= -1;
		}

		for (int k = 0; k < 2; k++) {
			fVecMin[k] += 16.0;
			fVecMax[k] -= 16.0;
		}

		SetEntPropVector(iEntity, Prop_Send, "m_vecMins", fVecMin);
		SetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", fVecMax);

		SetEntProp(iEntity, Prop_Send, "m_nSolidType", 2);
		TeleportEntity(iEntity, fMid, NULL_VECTOR, NULL_VECTOR);

		SDKHook(iEntity, SDKHook_StartTouch, Hook_StartTouch);
		SDKHook(iEntity, SDKHook_EndTouch, Hook_EndTouch);
	}
}

void Zone_Message(int iClient, float fTime, float fServerTime, float fPersonalTime, int iZoneType) {
	char cBuffer[512], cTime[32], cServerTime[32], cPersonalTime[32], cServerDiff[32], cPersonalDiff[32];

	if (iZoneType == ZONE_END) Format(cBuffer, sizeof(cBuffer), "END:");
	else if (iZoneType == ZONE_CHECKPOINT) Format(cBuffer, sizeof(cBuffer), "CP:");

	Misc_FormatTime(fTime, cTime, sizeof(cTime));
	Misc_FormatTime(fServerTime, cServerTime, sizeof(cServerTime));
	Misc_FormatTime(fPersonalTime, cPersonalTime, sizeof(cPersonalTime));
	Misc_FormatTime(fServerTime - fTime, cServerDiff, sizeof(cServerDiff));
	Misc_FormatTime(fPersonalTime - fTime, cPersonalDiff, sizeof(cPersonalDiff));

	Misc_FormatTimePrefix(fServerTime, fServerTime - fTime, cServerDiff, sizeof(cServerDiff));
	Misc_FormatTimePrefix(fPersonalTime, fPersonalTime - fTime, cPersonalDiff, sizeof(cPersonalDiff));
	// PrintToChatAll("%s %s (PB: \x0B%s\x01) | %s (WB: \x0B%s\x01)", cBuffer, cPersonalDiff, cPersonalTime, cServerDiff, cServerTime);
	PrintToChat(iClient, "%s %s (PB: \x0B%s\x01) | %s (WB: \x0B%s\x01)", cBuffer, cPersonalDiff, cPersonalTime, cServerDiff, cServerTime);
}

void Zone_Timer() {
	for (int i = 0; i < TIMER_ZONES && g_Global.Render < g_Global.Zones.Length; i++) {
		Zone zZone;
		g_Global.Zones.GetArray(g_Global.Render, zZone);

		float xPos[3], yPos[3];
		zZone.GetX(xPos);
		zZone.GetY(yPos);

		int iColor = zZone.Type + 5;
		if (zZone.Group > 0) iColor += 3;

		Zone_Draw(xPos, yPos, iColor, TIMER_INTERVAL + (g_Global.Zones.Length / TIMER_ZONES) * TIMER_INTERVAL, true);
		g_Global.Render++;
	}

	if (g_Global.Render == g_Global.Zones.Length) g_Global.Render = 0;
}

void Zone_TeleportToStart(int iClient) {
	int iIndex = g_Global.Zones.FindSingleZone(1, 0);
	if (iIndex == -1) return;

	float xPos[3], yPos[3], fSpawn[3];
	Zone zZone; g_Global.Zones.GetArray(iIndex, zZone);
	zZone.GetX(xPos);
	zZone.GetY(yPos);
	Misc_CalculateSpawn(xPos, yPos, fSpawn);
	gP_Player[iClient].RecentlyAbused = true;
	gP_Player[iClient].Record.StartTime = -1.0;
	TeleportEntity(iClient, fSpawn, NULL_VECTOR, NULL_VECTOR);
}

Action Zone_Run(int iClient, int& iButtons) {
	if (gP_Player[iClient].CurrentZone == ZONE_START) {
		if (gP_Player[iClient].Record.StartTime == -1.0) if (GetEntityFlags(iClient) & FL_ONGROUND) gP_Player[iClient].Record.StartTime = 0.0;
		if (gP_Player[iClient].Record.StartTime == 0.0) if (!(GetEntityFlags(iClient) & FL_ONGROUND) && (iButtons & IN_JUMP)) Misc_StartTimer(iClient);
		if (GetEntityFlags(iClient) & FL_ONGROUND) gP_Player[iClient].Record.StartTime = 0.0;
	}

	if (gP_Player[iClient].CurrentZone != ZONE_START) {
		if (!(GetEntityMoveType(iClient) & MOVETYPE_LADDER) && !(GetEntityFlags(iClient) & FL_ONGROUND) && (GetEntProp(iClient, Prop_Data, "m_nWaterLevel") < 2)) {
			iButtons &= ~IN_JUMP;
		}
	}
}

bool Filter_HitSelf(int iEntity, int iMask, any aData) {
	if (iEntity == aData) return false;
	return true;
}