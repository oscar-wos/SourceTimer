void Misc_PrecacheModels() {
	gH_Models[LaserMaterial] = PrecacheModel("materials/sprites/laserbeam.vmt");
	gH_Models[HaloMaterial] = PrecacheModel("materials/sprites/glow01.vmt");
	gH_Models[GlowSprite] = PrecacheModel("materials/sprites/blueflare1.vmt");
	gH_Models[BlueGlowSprite] = PrecacheModel("sprites/blueglow1.vmt");
	gH_Models[PurpleGlowSprite] = PrecacheModel("sprites/purpleglow1.vmt");
	gH_Models[Barrel] = PrecacheModel("models/props/de_train/barrel.mdl");
}

bool Misc_CheckPlayer(int iClient, int iType, bool bMessage = false) {
	char[] cBuffer = new char[512];

	if (iType <= PLAYER_VALID) if (IsFakeClient(iClient)) return false;

	if (iType <= PLAYER_INGAME) if (iClient == 0 || !IsValidEntity(iClient) || !IsClientConnected(iClient) || !IsClientInGame(iClient)) {
		if (bMessage) { Format(cBuffer, 512, "%s%s%t", TEXT_PREFIX, TEXT_DEFAULT, "check_ingame", TEXT_HIGHLIGHT, TEXT_DEFAULT); Timer_CommandReply(iClient, cBuffer); }
		return false;
	}

	if (iType <= PLAYER_ALIVE) if (!IsPlayerAlive(iClient)) {
		if (bMessage) { Format(cBuffer, 512, "%s%s%t", TEXT_PREFIX, TEXT_DEFAULT, "check_alive", TEXT_HIGHLIGHT, TEXT_DEFAULT); Timer_CommandReply(iClient, cBuffer); }
		return false;
	}

	return true;
}
