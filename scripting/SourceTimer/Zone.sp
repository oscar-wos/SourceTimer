void Zone_Draw(int iClient, float fX[3], float fY[3], int iColor, bool bAll) {
	float fPoints[8][3];

	fPoints[0] = fX;
	fPoints[7] = fY;

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

	for (int i = 0; i < 4; i++) { Zone_DrawLine(fPoints[i], fPoints[i + 4], C_Colors[iColor], bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[0], fPoints[i + 1], C_Colors[iColor], bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[3], fPoints[i + 1], C_Colors[iColor], bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[4], fPoints[i + 5], C_Colors[iColor], bAll, iClient); }
	for (int i = 0; i < 2; i++) { Zone_DrawLine(fPoints[7], fPoints[i + 5], C_Colors[iColor], bAll, iClient); }
}

void Zone_DrawAdmin(int iClient, float xPos[3]) {
	float yPos[3];

	for (int i = 0; i < 3; i++) {
		for (int k = 0; k < 3; k++) { yPos[k] = xPos[k]; }

		yPos[i] += 66.6;
		Zone_DrawLine(xPos, yPos, C_Colors[i], false, iClient)
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
	if (iModel == 0) { TE_SetupGlowSprite(fPos, g_Global.Models.BlueGlow, TIMER_INTERVAL, fSize, 249); }
	else { TE_SetupGlowSprite(fPos, g_Global.Models.RedGlow, TIMER_INTERVAL, fSize, 249); }

	if (bAll) { TE_SendToAll(); }
	else { TE_SendToClient(iClient); }
}

void Zone_DrawLine(float xPos[3], float yPos[3], int iColor[4], bool bAll, int iClient = 0) {
	TE_SetupBeamPoints(xPos, yPos, g_Global.Models.Laser, g_Global.Models.Glow, 0, 1, TIMER_INTERVAL, 1.0, 1.0, 1, 1.0, iColor, 1);

	if (bAll) { TE_SendToAll(); }
	else { TE_SendToClient(iClient); }
}

bool Filter_HitSelf(int iEntity, int iMask, any aData) {
	if (iEntity == aData) return false;
	return true;
}
