#include "sourcemod"

public void T_Connect(Database dStorage, const char[] cError, any aData) {
	if (dStorage == null) { LogError("SQL Connect Error"); return; }

	char[] cBuffer = new char[512];
	dStorage.Driver.GetIdentifier(cBuffer, 512);

	if (StrEqual(cBuffer, "mysql")) { g_Global.IsMySQL = true; }
	g_Global.Storage = dStorage;

	if (g_Global.IsMySQL) {
		Format(cBuffer, 512, "CREATE TABLE IF NOT EXISTS `players` (`steamid` int PRIMARY KEY, `uid` INT NOT NULL AUTO_INCREMENT);");
	} else {
		Format(cBuffer, 512, "CREATE TABLE IF NOT EXISTS `players` (`steamid` int PRIMARY KEY);")
	}
}

/*
void Sql_LoadPlayer(int iClient) {
	char[] cBuffer = new char[512];
	int iSteamId = GetSteamAccountID(iClient);

	Format(cBuffer, 512, "SELECT * FROM `players` WHERE `steamid` = `%i`", iSteamId);
	g_Global.Storage.Query(T_LoadPlayer, cBuffer, iClient, DBPrio_High);
}

void T_LoadPlayer(Database dStorage, DBResultSet dbResults, const char[] cError, int iClient) {
	// Player pPlayer = g_Global.Players.Get(iClient);
}
*/