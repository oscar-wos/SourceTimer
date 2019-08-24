void Command_Start() {
	RegConsoleCmd("sm_r", Command_Restart);
}

public Action Command_Restart(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_INGAME)) return Plugin_Handled;
	if (GetClientTeam(iClient) != 1) Zone_TeleportToStart(iClient);
	else {
		ChangeClientTeam(iClient, 2);
		CS_RespawnPlayer(iClient);
	}

	return Plugin_Handled;
}