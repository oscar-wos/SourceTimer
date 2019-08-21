void Replay_Start() {
	char[] cBuffer = new char[512];
	BuildPath(Path_SM, cBuffer, 512, "data/SourceTimer");

	if (!DirExists(cBuffer)) CreateDirectory(cBuffer, 755);
}

void Replay_Save(int iClient) {
	char[] cBuffer = new char[512];
	BuildPath(Path_SM, cBuffer, 512, "data/SourceTimer/%i", )
}

Action Replay_Run(int iClient, int& iButtons, float fVel[3], float fAngle[3]) {
	if (Misc_CheckPlayer(iClient, PLAYER_INGAME)) {
		if (gP_Player[iClient].Record.StartTime <= 0.0) return;
		ReplayFrame rfFrame;
		float fPos[3];

		GetClientAbsOrigin(iClient, fPos);
		rfFrame.SetPos(fPos);
		rfFrame.SetAngle(fAngle);
		rfFrame.SetVel(fVel);
		rfFrame.Buttons = iButtons;

		gP_Player[iClient].Replay.Frames.Resize(gP_Player[iClient].Replay.Frame + 1);
		gP_Player[iClient].Replay.Frames.SetArray(gP_Player[iClient].Replay.Frame, rfFrame);
		gP_Player[iClient].Replay.Frame++;
	}
}
