public void T_Connect(Database dStorage, const char[] cError, any aData) {
	if (dStorage == null) { LogError("SQL Error"); return; }

	char[] cBuffer = new char[512];
	dStorage.Driver.GetIdentifier(cBuffer, 512);

	if (StrEqual(cBuffer, "mysql")) { g_Global.IsMySQL = true; }
	g_Global.Storage = dStorage;

	if (g_Global.IsMySQL) {
		Format(cBuffer, 512, "CREATE TABLE IF NOT EXISTS `players` (steamid VARCHAR(32) PRIMARY KEY, uid INT NOT NULL AUTO_INCREMENT);");
	} else {
		Format(cBuffer, 512, "CREATE TABLE IF NOT EXISTS `players` (steamid VARCHAR(32) PRIMARY KEY);")
	}
}
