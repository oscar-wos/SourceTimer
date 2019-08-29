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

void Misc_FormatTimeHud(float fTime, float fDiff, char[] cBuffer, int iMaxLength) {
	if (fTime == 0) Format(cBuffer, iMaxLength, "<font color=\"#B0C3D9\">%s", cBuffer);
	else if (fDiff == 0) Format(cBuffer, iMaxLength, "<font color=\"#E4AE39\">%s", cBuffer);
	else if (fDiff > 0) Format(cBuffer, iMaxLength, "<font color=\"#A2FF47\">+%s", cBuffer);
	else Format(cBuffer, iMaxLength, "<font color=\"#FF4040\">-%s", cBuffer);
}

Action Misc_Run(int iClient) {
	if (IsClientObserver(iClient)) {
		int iTarget = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
		if (iTarget != -1) Misc_ShowHud(iClient, iTarget);
	} else {
		Misc_ShowHud(iClient, iClient);
	}

	if (gP_Player[iClient].Record.StartTime > 0.0) {
		float fTime = GetGameTime() - gP_Player[iClient].Record.StartTime;

		for (int i = 0; i < ARRAYLIST_BUFFER_SIZE && gP_Player[iClient].GlobalRecordsIndex < g_Global.Records.Length; i++) {
			Record rRecord; g_Global.Records.GetArray(gP_Player[iClient].GlobalRecordsIndex, rRecord);
			if (fTime > rRecord.EndTime) gP_Player[iClient].GlobalRecordsIndex++;
			else break;
		}

		for (int i = 0; i < ARRAYLIST_BUFFER_SIZE && gP_Player[iClient].PlayerRecordsIndex < gP_Player[iClient].Records.Length; i++) {
			Record rRecord; gP_Player[iClient].Records.GetArray(gP_Player[iClient].PlayerRecordsIndex, rRecord);
			if (fTime > rRecord.EndTime) gP_Player[iClient].PlayerRecordsIndex++;
			else break;
		}

		for (int i = 0; i < ARRAYLIST_BUFFER_SIZE && gP_Player[iClient].GlobalCheckpointsIndex < g_Global.Checkpoints.Length; i++) {
			Checkpoint cCheckpoint; g_Global.Checkpoints.GetArray(gP_Player[iClient].GlobalCheckpointsIndex, cCheckpoint);
			if (fTime > cCheckpoint.Time) gP_Player[iClient].GlobalCheckpointsIndex++;
			else break;
		}

		for (int i = 0; i < ARRAYLIST_BUFFER_SIZE && gP_Player[iClient].PlayerCheckpointsIndex < gP_Player[iClient].RecordCheckpoints.Length; i++) {
			Checkpoint cCheckpoint; g_Global.Checkpoints.GetArray(gP_Player[iClient].PlayerCheckpointsIndex, cCheckpoint);
			if (fTime > cCheckpoint.Time) gP_Player[iClient].PlayerCheckpointsIndex++;
			else break;
		}

		for (int i = 0; i < ARRAYLIST_BUFFER_SIZE && gP_Player[iClient].CloneRecordsIndex < gP_Player[iClient].CloneRecords.Length; i++) {
			Record rRecord; gP_Player[iClient].CloneRecords.GetArray(gP_Player[iClient].CloneRecordsIndex, rRecord);
			if (fTime > rRecord.EndTime) gP_Player[iClient].CloneRecordsIndex++;
			else break;
		}
	}
}

void Misc_Frame() {
	for (int i = 0; i < ARRAYLIST_BUFFER_SIZE && i < g_Global.Queue.Length; i++) {
		Queue qQueue; g_Global.Queue.GetArray(i, qQueue);
		int iClient = GetClientOfUserId(qQueue.Client);
		int iGlobalIndex, iPlayerIndex;
		
		if (!(iClient == 0 && qQueue.Client != 0)) {
			switch (qQueue.Type) {
				case QUEUE_RECORD: {
					if (iClient == 0) iGlobalIndex = Misc_InsertGlobalRecord(qQueue.Time, qQueue.Group, qQueue.Style, qQueue.Index);
					else iPlayerIndex = Misc_InsertPlayerRecord(iClient, qQueue.Time, qQueue.Group, qQueue.Style, qQueue.Index);
				} case QUEUE_CHECKPOINT: {
					if (iClient == 0) iGlobalIndex = Misc_InsertGlobalCheckpoint(qQueue.Time, qQueue.ZoneId, qQueue.Index);
					else iPlayerIndex = Misc_InsertPlayerCheckpoint(iClient, qQueue.Time, qQueue.ZoneId, qQueue.Index);
				}
			}

			if (qQueue.Index == 0) {
				Zone zZone; g_Global.Zones.GetArray(qQueue.ZoneIndex, zZone);
				if (iClient == 0) zZone.RecordIndex[0] = iGlobalIndex;
				else zZone.RecordIndex[iClient] = iPlayerIndex;
				g_Global.Zones.SetArray(qQueue.ZoneIndex, zZone);
			}
		}

		g_Global.Queue.Erase(i);
	}
}

void Misc_ShowHud(int iClient, int iTarget) {
	if (gP_Player[iTarget].Record.StartTime > 0.0) {
		char[] cBuffer = new char[4096];
		char[] cTime = new char[32];
		float fTime = GetGameTime();

		Misc_FormatTime(gP_Player[iTarget].Record.StartTime - fTime, cTime, 32);
		FormatEx(cBuffer, 4096, "<pre>Time: %s", cTime);

		if (gP_Player[iTarget].PreviousTime != 0.0 && (fTime - gP_Player[iTarget].PreviousTime) < HUD_SHOWPREVIOUS) {
			if (gP_Player[iTarget].Checkpoints.Length > 0) {
				char cServerDiff[64], cPersonalDiff[64];
				float fServerTime, fPersonalTime;
				Checkpoint cCheckpoint; gP_Player[iTarget].Checkpoints.GetArray(gP_Player[iTarget].Checkpoints.Length - 1, cCheckpoint);

				int iZoneIndex;

				if (gP_Player[iTarget].PreviousZone != -1) iZoneIndex = gP_Player[iTarget].PreviousZone;
				else iZoneIndex = gP_Player[iTarget].CurrentZone;

				if (iZoneIndex != -1) {
					Zone zZone; g_Global.Zones.GetArray(iZoneIndex, zZone);

					if (zZone.RecordIndex[0] != -1) {
						Checkpoint cServerBest; g_Global.Checkpoints.GetArray(zZone.RecordIndex[0], cServerBest);
						fServerTime = cServerBest.Time;
					}

					if (zZone.RecordIndex[iTarget] != -1) {
						Checkpoint cPersonalBest; gP_Player[iTarget].RecordCheckpoints.GetArray(zZone.RecordIndex[iTarget], cPersonalBest);
						fPersonalTime = cPersonalBest.Time;
					}
				}

				Misc_FormatTime(fServerTime - cCheckpoint.Time, cServerDiff, sizeof(cServerDiff));
				Misc_FormatTime(fPersonalTime - cCheckpoint.Time, cPersonalDiff, sizeof(cPersonalDiff));
				Misc_FormatTimeHud(fServerTime, fServerTime - cCheckpoint.Time, cServerDiff, sizeof(cServerDiff));
				Misc_FormatTimeHud(fPersonalTime, fPersonalTime - cCheckpoint.Time, cPersonalDiff, sizeof(cPersonalDiff));
				FormatEx(cBuffer, 4096, "%s\t%s\n", cBuffer, cServerDiff);
				FormatEx(cBuffer, 4096, "%s\t\t\t\t\t%s", cBuffer, cPersonalDiff);
			}
		} else {
			char cServerTime[64], cPersonalTime[64];
			float fServerTime, fPersonalTime;

			if (gP_Player[iTarget].EndZone != -1) {
				Zone zZone; g_Global.Zones.GetArray(gP_Player[iTarget].EndZone, zZone);

				if (zZone.RecordIndex[0] != -1) {
					Record rServerBest; g_Global.Records.GetArray(zZone.RecordIndex[0], rServerBest);
					fServerTime = rServerBest.EndTime;
				}

				if (zZone.RecordIndex[iTarget] != -1) {
					Record rPersonalBest; gP_Player[iTarget].Records.GetArray(zZone.RecordIndex[iTarget], rPersonalBest);
					fPersonalTime = rPersonalBest.EndTime;
				}
			}

			Misc_FormatTime(fServerTime, cServerTime, sizeof(cServerTime));
			Misc_FormatTime(fPersonalTime, cPersonalTime, sizeof(cPersonalTime));
			FormatEx(cBuffer, 4096, "%s\t%s\n", cBuffer, cServerTime);
			FormatEx(cBuffer, 4096, "%s\t\t\t\t\t%s", cBuffer, cPersonalTime);
		}
		
		FormatEx(cBuffer, 4096, "%s</pre>", cBuffer);
		PrintHintText(iClient, cBuffer);
	}
}

void Misc_StartTimer(int iClient) {
	if (GetEntityMoveType(iClient) != MOVETYPE_WALK) return;
	gP_Player[iClient].Record.StartTime = GetGameTime();
	gP_Player[iClient].RecentlyAbused = false;
	gP_Player[iClient].Replay.Frame = 0;
	gP_Player[iClient].PreviousTime = 0.0;
	gP_Player[iClient].GlobalRecordsIndex = 0;
	gP_Player[iClient].PlayerRecordsIndex = 0;
	gP_Player[iClient].GlobalCheckpointsIndex = 0;
	gP_Player[iClient].PlayerCheckpointsIndex = 0;
	gP_Player[iClient].CloneRecordsIndex = 0;
	gP_Player[iClient].ClonePersonalRecordsIndex = 0;
	gP_Player[iClient].EndZone = g_Global.Zones.FindSingleZone(ZONE_END, gP_Player[iClient].Record.Group);
	gP_Player[iClient].CloneRecords = g_Global.Records.FindByStyleGroup(gP_Player[iClient].Style, gP_Player[iClient].Record.Group);
	gP_Player[iClient].ClonePersonalRecords = gP_Player[iClient].Records.FindByStyleGroup(gP_Player[iClient].Style, gP_Player[iClient].Record.Group);
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

void Misc_SegmentMessage(int iClient, char[] cMessage) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_VALID)) continue;
		if (i == iClient) PrintToChat(iClient, "%s", cMessage);
		else {
			if (!IsClientObserver(i)) return;
			int iTarget = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
			if (i == iTarget) PrintToChat(iClient, "%s", cMessage);
		}
	}
}

void Misc_EndMessage(int iClient, int iStyle, int iGroup, float fTime) {
	char[] cBuffer = new char[512];
	char[] cClientName = new char[64];
	char[] cTime = new char[64];

	GetClientName(iClient, cClientName, 64);
	Misc_FormatTime(fTime, cTime, 64);
	Format(cBuffer, 512, "Finished %i on %i - %s (%i/%i)", iGroup, iStyle, cTime, gP_Player[iClient].CloneRecordsIndex + 1, gP_Player[iClient].CloneRecords.Length + 1);

	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_VALID)) continue;
		if (i != iClient) Timer_Message(i, "%s%s%s %s", TEXT_PREFIX, TEXT_DEFAULT, cClientName, cBuffer); 
		else Timer_Message(i, "%s%s%s", TEXT_PREFIX, TEXT_DEFAULT, cBuffer); 
	}
}

int Misc_InsertGlobalCheckpoint(float fTime, int iZoneId, int iIndex) {
	while (iIndex < g_Global.Checkpoints.Length) {
		Checkpoint cCheckpoint; g_Global.Checkpoints.GetArray(iIndex, cCheckpoint);
		if (fTime > cCheckpoint.Time) iIndex++;
		else break;
	}

	if (iIndex >= g_Global.Checkpoints.Length) g_Global.Checkpoints.Resize(iIndex + 1);
	else g_Global.Checkpoints.ShiftUp(iIndex);

	Checkpoint cCheckpoint;
	cCheckpoint.Time = fTime;
	cCheckpoint.ZoneId = iZoneId;
	g_Global.Checkpoints.SetArray(iIndex, cCheckpoint);

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		Zone zZone; g_Global.Zones.GetArray(i, zZone);
		if (zZone.Type != ZONE_CHECKPOINT) continue;
		if (zZone.RecordIndex[0] == -1) continue;
		if (iIndex <= zZone.RecordIndex[0]) { 
			zZone.RecordIndex[0]++;
			g_Global.Zones.SetArray(i, zZone);
		}	
	}

	return iIndex;
}

int Misc_InsertPlayerCheckpoint(int iClient, float fTime, int iZoneId, int iIndex) {
	while (iIndex < gP_Player[iClient].RecordCheckpoints.Length) {
		Checkpoint cCheckpoint; gP_Player[iClient].RecordCheckpoints.GetArray(iIndex, cCheckpoint);
		if (fTime > cCheckpoint.Time) iIndex++;
		else break;
	}

	if (iIndex >= gP_Player[iClient].RecordCheckpoints.Length) gP_Player[iClient].RecordCheckpoints.Resize(iIndex + 1);
	else gP_Player[iClient].RecordCheckpoints.ShiftUp(iIndex);

	Checkpoint cCheckpoint;
	cCheckpoint.Time = fTime;
	cCheckpoint.ZoneId = iZoneId;
	gP_Player[iClient].RecordCheckpoints.SetArray(iIndex, cCheckpoint);

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		Zone zZone; g_Global.Zones.GetArray(i, zZone);
		if (zZone.Type != ZONE_CHECKPOINT) continue;
		if (zZone.RecordIndex[iClient] == -1) continue;
		if (iIndex <= zZone.RecordIndex[iClient]) { 
			zZone.RecordIndex[iClient]++;
			g_Global.Zones.SetArray(i, zZone);
		}	
	}

	return iIndex;
}

int Misc_InsertGlobalRecord(float fTime, int iGroup, int iStyle, int iIndex) {
	while (iIndex < g_Global.Records.Length) {
		Record rRecord; g_Global.Records.GetArray(iIndex, rRecord);
		if (fTime > rRecord.EndTime) iIndex++;
		else break;
	}

	if (iIndex >= g_Global.Records.Length) g_Global.Records.Resize(iIndex + 1);
	else g_Global.Records.ShiftUp(iIndex);

	Record rRecord;
	rRecord.EndTime = fTime;
	rRecord.Group = iGroup;
	rRecord.Style = iStyle;
	g_Global.Records.SetArray(iIndex, rRecord);

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		Zone zZone; g_Global.Zones.GetArray(i, zZone);
		if (zZone.Type != ZONE_END) continue;
		if (zZone.RecordIndex[0] == -1) continue;
		if (iIndex <= zZone.RecordIndex[0]) {
			zZone.RecordIndex[0]++;
			g_Global.Zones.SetArray(i, zZone);
		}
	}

	return iIndex;
}

int Misc_InsertPlayerRecord(int iClient, float fTime, int iGroup, int iStyle, int iIndex) {
	while (iIndex < gP_Player[iClient].Records.Length) {
		Record rRecord; gP_Player[iClient].Records.GetArray(iIndex, rRecord);
		if (fTime > rRecord.EndTime) iIndex++;
		else break;
	}

	if (iIndex >= gP_Player[iClient].Records.Length) gP_Player[iClient].Records.Resize(iIndex + 1);
	else gP_Player[iClient].Records.ShiftUp(iIndex);

	Record rRecord;
	rRecord.EndTime = fTime;
	rRecord.Group = iGroup;
	rRecord.Style = iStyle;
	gP_Player[iClient].Records.SetArray(iIndex, rRecord);

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		Zone zZone; g_Global.Zones.GetArray(i, zZone);
		if (zZone.Type != ZONE_END) continue;
		if (zZone.RecordIndex[iClient] == -1) continue;
		if (iIndex <= zZone.RecordIndex[iClient]) {
			zZone.RecordIndex[iClient]++;
			g_Global.Zones.SetArray(i, zZone);
		}
	}

	return iIndex;
}

void Misc_Record(int iClient, int iZoneIndex) {
	int iGlobalIndex = Misc_InsertGlobalRecord(gP_Player[iClient].Record.EndTime, gP_Player[iClient].Record.Group, gP_Player[iClient].Record.Style, gP_Player[iClient].GlobalRecordsIndex);
	int iPlayerIndex = Misc_InsertPlayerRecord(iClient, gP_Player[iClient].Record.EndTime, gP_Player[iClient].Record.Group, gP_Player[iClient].Record.Style, gP_Player[iClient].PlayerRecordsIndex);
	Zone zZone; g_Global.Zones.GetArray(iZoneIndex, zZone);

	if (zZone.RecordIndex[0] == -1) zZone.RecordIndex[0] = iGlobalIndex;
	else {
		Record rRecord; g_Global.Records.GetArray(zZone.RecordIndex[0], rRecord);
		if (gP_Player[iClient].Record.EndTime < rRecord.EndTime) zZone.RecordIndex[0] = iGlobalIndex;
	}

	if (zZone.RecordIndex[iClient] == -1) zZone.RecordIndex[iClient] = iPlayerIndex;
	else {
		Record rRecord; gP_Player[iClient].Records.GetArray(zZone.RecordIndex[iClient], rRecord);
		if (gP_Player[iClient].Record.EndTime < rRecord.EndTime) zZone.RecordIndex[iClient] = iPlayerIndex;
	}

	g_Global.Zones.SetArray(iZoneIndex, zZone);

	for (int i = 0; i < gP_Player[iClient].Checkpoints.Length; i++) {
		Checkpoint cCheckpoint; gP_Player[iClient].Checkpoints.GetArray(i, cCheckpoint);
		int iCheckpointIndex = g_Global.Zones.FindByZoneId(cCheckpoint.ZoneId);
		g_Global.Zones.GetArray(iCheckpointIndex, zZone);
		
		iGlobalIndex = Misc_InsertGlobalCheckpoint(cCheckpoint.Time, cCheckpoint.ZoneId, cCheckpoint.GlobalCheckpointIndex);
		iPlayerIndex = Misc_InsertPlayerCheckpoint(iClient, cCheckpoint.Time, cCheckpoint.ZoneId, cCheckpoint.PlayerCheckpointIndex);

		if (zZone.RecordIndex[0] == -1) zZone.RecordIndex[0] = iGlobalIndex;
		else {
			Checkpoint cServerBest; g_Global.Checkpoints.GetArray(zZone.RecordIndex[0], cServerBest);
			if (cCheckpoint.Time < cServerBest.Time) zZone.RecordIndex[0] = iGlobalIndex;
		}

		if (zZone.RecordIndex[iClient] == -1) zZone.RecordIndex[iClient] = iPlayerIndex;
		else {
			Checkpoint cPlayerBest; gP_Player[iClient].RecordCheckpoints.GetArray(zZone.RecordIndex[iClient], cPlayerBest);
			if (cCheckpoint.Time < cPlayerBest.Time) zZone.RecordIndex[iClient] = iPlayerIndex;
		}

		g_Global.Zones.SetArray(iCheckpointIndex, zZone);
	}
}