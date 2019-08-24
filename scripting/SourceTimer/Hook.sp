Action Hook_OnTakeDamage(int iVictim, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType) {
	fDamage *= 0;
	return Plugin_Handled;
}

Action Hook_StartTouch(int iCaller, int iActivator) {
	if (!Misc_CheckPlayer(iActivator, PLAYER_ALIVE)) return;
	char[] cEntityName = new char[512];
	char[] cEntityIndex = new char[16];
	int iIndex;

	GetEntPropString(iCaller, Prop_Send, "m_iName", cEntityName, 512);
	SplitString(cEntityName, ":", cEntityIndex, 16);
	iIndex = StringToInt(cEntityIndex);

	if (iIndex == -1) return;

	Zone zZone;
	g_Global.Zones.GetArray(iIndex, zZone);

	switch (zZone.Type) {
		case ZONE_START: {
			gP_Player[iActivator].Record.StartTime = -1.0;
			ConVar cnBunny = FindConVar("sv_autobunnyhopping");
			SendConVarValue(iActivator, cnBunny, "0");
		} case ZONE_END: {
			if (gP_Player[iActivator].Record.StartTime <= 0.0) return;
			if (gP_Player[iActivator].Record.Group != zZone.Group) return;

			gP_Player[iActivator].Record.EndTime = GetGameTime() - gP_Player[iActivator].Record.StartTime;
			gP_Player[iActivator].Record.StartTime = 0.0;

			float fServerTime, fPersonalTime;
			if (zZone.RecordIndex[0] != -1) {
				Record rServerBest;
				g_Global.Records.GetArray(zZone.RecordIndex[0], rServerBest);
				fServerTime = rServerBest.EndTime;
			}

			if (zZone.RecordIndex[iActivator] != -1) {
				Record rPersonalBest;
				gP_Player[iActivator].Records.GetArray(zZone.RecordIndex[iActivator], rPersonalBest);
				fPersonalTime = rPersonalBest.EndTime;
			}

			Zone_Message(iActivator, gP_Player[iActivator].Record.EndTime, fServerTime, fPersonalTime, ZONE_END);
			Sql_AddRecord(iActivator, gP_Player[iActivator].Record.Style, gP_Player[iActivator].Record.Group, gP_Player[iActivator].Record.EndTime, view_as<Checkpoints>(gP_Player[iActivator].Checkpoints.Clone()));
			Replay_Save(iActivator, gP_Player[iActivator].Record.Style, gP_Player[iActivator].Record.Group, gP_Player[iActivator].Record.EndTime, gP_Player[iActivator].Replay.Frames.Clone());

			for (int i = 0; i < gP_Player[iActivator].Checkpoints.Length; i++) {
				Checkpoint cCheckpoint;
				gP_Player[iActivator].Checkpoints.GetArray(i, cCheckpoint);

				Zone zCheckpoint;
				int iZoneIndex = g_Global.Zones.FindByZoneId(cCheckpoint.ZoneId);
				g_Global.Zones.GetArray(iZoneIndex, zCheckpoint);

				if (zCheckpoint.RecordIndex[0] == -1) zCheckpoint.RecordIndex[0] = g_Global.Checkpoints.Length;
				else {
					Checkpoint cCheckpointServerBest;
					g_Global.Checkpoints.GetArray(zCheckpoint.RecordIndex[0], cCheckpointServerBest);
					if (cCheckpoint.Time < cCheckpointServerBest.Time || cCheckpointServerBest.Time == 0) zCheckpoint.RecordIndex[0] = g_Global.Checkpoints.Length;
				}

				if (zCheckpoint.RecordIndex[iActivator] == -1) zCheckpoint.RecordIndex[iActivator] = gP_Player[iActivator].RecordCheckpoints.Length;
				else {
					Checkpoint cCheckpointPersonalBest;
					gP_Player[iActivator].RecordCheckpoints.GetArray(zCheckpoint.RecordIndex[iActivator], cCheckpointPersonalBest);
					if (cCheckpoint.Time < cCheckpointPersonalBest.Time || cCheckpointPersonalBest.Time == 0) zCheckpoint.RecordIndex[iActivator] = gP_Player[iActivator].RecordCheckpoints.Length;
				}

				g_Global.Zones.SetArray(iZoneIndex, zCheckpoint);
				g_Global.Checkpoints.PushArray(cCheckpoint);
				gP_Player[iActivator].RecordCheckpoints.PushArray(cCheckpoint);
			}

			if (zZone.RecordIndex[0] == -1) zZone.RecordIndex[0] = g_Global.Records.Length;
			else {
				Record rServerBest;
				g_Global.Records.GetArray(zZone.RecordIndex[0], rServerBest);
				if (gP_Player[iActivator].Record.EndTime < rServerBest.EndTime) zZone.RecordIndex[0] = g_Global.Records.Length;
			}

			if (zZone.RecordIndex[iActivator] == -1) zZone.RecordIndex[iActivator] = gP_Player[iActivator].Records.Length;
			else {
				Record rPersonalBest;
				gP_Player[iActivator].Records.GetArray(zZone.RecordIndex[iActivator], rPersonalBest);
				if (gP_Player[iActivator].Record.EndTime < rPersonalBest.EndTime) zZone.RecordIndex[iActivator] = gP_Player[iActivator].Records.Length;
			}

			g_Global.Zones.SetArray(iIndex, zZone);
			g_Global.Records.PushArray(gP_Player[iActivator].Record);
			gP_Player[iActivator].Records.PushArray(gP_Player[iActivator].Record);
		} case ZONE_CHECKPOINT: {
			if (gP_Player[iActivator].Record.StartTime <= 0.0) return;
			if (gP_Player[iActivator].Record.Group != zZone.Group) return;

			Checkpoints cCheckpoints = gP_Player[iActivator].Checkpoints.FindByZoneId(zZone.Id);
			if (cCheckpoints.Length == 1) return;
			delete cCheckpoints;

			Checkpoint cCheckpoint;
			cCheckpoint.Time = GetGameTime() - gP_Player[iActivator].Record.StartTime;
			cCheckpoint.ZoneId = zZone.Id;

			float fServerTime, fPersonalTime;
			if (zZone.RecordIndex[0] != -1) {
				Checkpoint cServerBest;
				g_Global.Checkpoints.GetArray(zZone.RecordIndex[0], cServerBest);
				fServerTime = cServerBest.Time;
			}

			if (zZone.RecordIndex[iActivator] != -1) {
				Checkpoint cPersonalBest;
				gP_Player[iActivator].RecordCheckpoints.GetArray(zZone.RecordIndex[iActivator], cPersonalBest);
				fPersonalTime = cPersonalBest.Time;
			}

			Zone_Message(iActivator, cCheckpoint.Time, fServerTime, fPersonalTime, ZONE_CHECKPOINT);
			gP_Player[iActivator].Checkpoints.PushArray(cCheckpoint);
		}
	}

	gP_Player[iActivator].CurrentZone = zZone.Type;
}

Action Hook_EndTouch(int iCaller, int iActivator) {
	if (!Misc_CheckPlayer(iActivator, PLAYER_ALIVE)) return;
	char[] cEntityName = new char[512];
	char[] cEntityIndex = new char[16];
	int iIndex;

	GetEntPropString(iCaller, Prop_Send, "m_iName", cEntityName, 512);
	SplitString(cEntityName, ":", cEntityIndex, 16);
	iIndex = StringToInt(cEntityIndex);

	if (iIndex == -1) return;

	Zone zZone;
	g_Global.Zones.GetArray(iIndex, zZone);

	switch (zZone.Type) {
		case ZONE_CHECKPOINT: { }
		case ZONE_END: { }
		case ZONE_START: {
			if (gP_Player[iActivator].Record.StartTime == 0.0) Misc_StartTimer(iActivator);

			if (gP_Player[iActivator].Record.StartTime > 0.0) {
				ConVar cnBunny = FindConVar("sv_autobunnyhopping");
				SendConVarValue(iActivator, cnBunny, "1");
			}
			
			gP_Player[iActivator].Record.Group = zZone.Group;
			gP_Player[iActivator].Record.Style = gP_Player[iActivator].Style;
			gP_Player[iActivator].Checkpoints.Clear();
		}	
	}

	if (gP_Player[iActivator].RecentlyAbused) return;
	gP_Player[iActivator].CurrentZone = ZONE_UNDEFINED;
}

void Hook_ConVarChange(ConVar cvConVar, const char[] cOldValue, const char[] cNewValue) {
	char[] cConVar = new char[64];
	char[] cConVarValue = new char[64];
	cvConVar.GetName(cConVar, 64);

	if (!g_Global.Convars.GetString(cConVar, cConVarValue, 64)) return;
	if (StrEqual(cConVarValue, cNewValue)) return;
	cvConVar.SetString(cConVarValue);
}

Action Hook_JoinTeam(int iClient, char[] cCommand, int iArgc) {
	if (!Misc_CheckPlayer(iClient, PLAYER_VALID)) return;
	char[] cArg1 = new char[8];
	GetCmdArg(1, cArg1, 8);

	int iArg1 = StringToInt(cArg1);
	ChangeClientTeam(iClient, iArg1);
	if (iArg1 != 1) CS_RespawnPlayer(iClient);
}