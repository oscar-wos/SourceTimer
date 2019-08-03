void Zone_Draw(int iClient, float fX[3], float fY[3], int iColor, float fDisplay, bool bAll) {
	float fPoints[8][3];
	int iColors[4];

	LineColor(iColor, iColors);

	fPoints[0] = fX;
	fPoints[7] = fY;

	/* TO DO MATH
	for (int x = 0; x < 2; x++) {
		for (int y = 0; y < 3; y++) {
			fPoints[]
		}
	}
	*/

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

	for (int i = 0; i < 4; i++) {
		TE_SetupBeamPoints(fPoints[i], fPoints[i + 4], gH_Models[LaserMaterial], gH_Models[HaloMaterial], 0, 30, fDisplay, 2.0, 5.0, 2, 1.0, iColors, 0);

		if (bAll) {
			TE_SendToAll();
		} else {
			TE_SendToClient(iClient);
		}
	}

	for (int i = 0; i < 2; i++) {
		TE_SetupBeamPoints(fPoints[0], fPoints[i + 1], gH_Models[LaserMaterial], gH_Models[HaloMaterial], 0, 30, fDisplay, 2.0, 5.0, 2, 1.0, iColors, 0);

		if (bAll) {
			TE_SendToAll();
		} else {
			TE_SendToClient(iClient);
		}
	}

	for (int i = 0; i < 2; i++) {
		TE_SetupBeamPoints(fPoints[3], fPoints[i + 1], gH_Models[LaserMaterial], gH_Models[HaloMaterial], 0, 30, fDisplay, 2.0, 5.0, 2, 1.0, iColors, 0);

		if (bAll) {
			TE_SendToAll();
		} else {
			TE_SendToClient(iClient);
		}
	}

	for (int i = 0; i < 2; i++) {
		TE_SetupBeamPoints(fPoints[4], fPoints[i + 5], gH_Models[LaserMaterial], gH_Models[HaloMaterial], 0, 30, fDisplay, 2.0, 5.0, 2, 1.0, iColors, 0);

		if (bAll) {
			TE_SendToAll();
		} else {
			TE_SendToClient(iClient);
		}
	}

	for (int i = 0; i < 2; i++) {
		TE_SetupBeamPoints(fPoints[7], fPoints[i + 5], gH_Models[LaserMaterial], gH_Models[HaloMaterial], 0, 30, fDisplay, 2.0, 5.0, 2, 1.0, iColors, 0);

		if (bAll) {
			TE_SendToAll();
		} else {
			TE_SendToClient(iClient);
		}
	}
}

void Zone_AdminDraw(int iClient, float xPos[3]) {
	float yPos[3];
	int iColors[4];

	for (int i = 0; i < 3; i++) {
		for (int a = 0; a < 3; a++) {
			yPos[a] = xPos[a];
		}

		yPos[i] += 100.0;
		LineColor(8 + i, iColors);

		TE_SetupBeamPoints(xPos, yPos, gH_Models[LaserMaterial], gH_Models[HaloMaterial], 0, 30, 0.1, 2.0, 10.0, 2, 1.0, iColors, 0);
		TE_SendToClient(iClient);
	}
}

void LineColor(int iColor, int iColors[4]) {
	switch (iColor) {
		case 0: { //N Start
			iColors = { 0, 255, 0, 255 };
		} case 1: { //N End
			iColors = { 255, 0, 0, 255 };
		} case 2: { //N CP
			iColors = { 255, 165, 0, 255 };
		} case 3: { //B Start
			iColors = { 23, 150, 102, 255 };
		} case 4: { //B End
			iColors = { 153, 0, 153, 255 };
		} case 5: { //B CP
			iColors = { 200, 100, 0, 255 };
		} case 6: { //Admin Zoning
			iColors = { 255, 255, 102, 255 };
		} case 7: { // Admin Zoning 2
			iColors = { 0, 255, 102, 255 };
		} case 8: { // Red
			iColors = { 255, 0, 0, 255 };
		} case 9: { // Green
			iColors = { 0, 255, 0, 255 };
		} case 10: { // Blue
			iColors = { 0, 0, 255, 255 };
		}
	}
}
