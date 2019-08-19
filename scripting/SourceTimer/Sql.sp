char g_SqlTables[][] = {
	"CREATE TABLE IF NOT EXISTS `zones` (`id` INT AUTO_INCREMENT, `mapname` VARCHAR(64)`, `type` INT, `group` INT, `x0` FLOAT, `x1` FLOAT, `x2` FLOAT, `y0` FLOAT, `y1` FLOAT, `y2` FLOAT);",
	"CREATE TABLE IF NOT EXISTS `records` (`id` INT AUTO_INCREMENT, `mapname` VARCHAR(64), `playerid` INT, `time` FLOAT, `type` INT, `group` INT);",
	"CREATE TABLE IF NOT EXISTS `checkpoints` (`id` INT AUTO_INCREMENT, `recordid` INT, `zoneid` INT, `time` FLOAT);"
};

char g_SqlLiteTables[][] = {
	"CREATE TABLE IF NOT EXISTS `zones` (`mapname` VARCHAR(64), `type` INT, `group` INT, `x0` FLOAT, `x1` FLOAT, `x2` FLOAT, `y0` FLOAT, `y1` FLOAT, `y2` FLOAT);",
	"CREATE TABLE IF NOT EXISTS `records` (`mapname` VARCHAR(64), `playerid` INT, `time` FLOAT, `style` INT, `group` INT);",
	"CREATE TABLE IF NOT EXISTS `checkpoints` (`recordid` INT, `zoneid` INT, `time` FLOAT);"
};

void T_Connect(Database dStorage, const char[] cError, any aData) {
	if (dStorage == null) LogError("SQL Error, %s", cError);
	char[] cDriver = new char[32];
	dStorage.Driver.GetIdentifier(cDriver, 32);

	if (StrEqual(cDriver, "mysql")) g_Global.IsMySql = true;
	g_Global.Storage = dStorage;

	Sql_CreateTables();
	Sql_SelectZones();
}

void Sql_CreateTables() {
	for (int i = 0; i < sizeof(g_SqlTables); i++) {
		Query qQuery = new Query();
		qQuery.Type = QUERY_CREATETABLE;

		if (g_Global.IsMySql) qQuery.SetQuery(g_SqlTables[i]);
		else qQuery.SetQuery(g_SqlLiteTables[i]);

		g_Global.Queries.Push(qQuery);
	}
}

void Sql_AddZone(float xPos[3], float yPos[3], int iType, int iGroup, int iIndex) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];
	char[] cMapName = new char[64];

	GetCurrentMap(cBuffer, 512);
	g_Global.Storage.Escape(cBuffer, cMapName, 64);

	Format(cBuffer, 512, "INSERT INTO `zones` ('mapname', 'type', 'group', 'x0', 'x1', 'x2', 'y0', 'y1', 'y2') VALUES ('%s', %i, %i, %f, %f, %f, %f, %f, %f);", cMapName, iType, iGroup, xPos[0], xPos[1], xPos[2], yPos[0], yPos[1], yPos[2]);
	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_INSERTZONE;
	qQuery.Index = iIndex;

	g_Global.Queries.Push(qQuery);
}

void Sql_UpdateZone(float xPos[3], float yPos[3], int iType, int iGroup, int iZoneId) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];

	if (g_Global.IsMySql) Format(cBuffer, 512, "UPDATE `zones` SET `type` = %i, `group` = %i, `x0` = %f, `x1` = %f, `x2` = %f, `y0` = %f, `y1` = %f, `y2` = %f WHERE `id` = %i", iType, iGroup, xPos[0], xPos[1], xPos[2], yPos[0], yPos[1], yPos[2], iZoneId);
	else Format(cBuffer, 512, "UPDATE `zones` SET `type` = %i, `group` = %i, `x0` = %f, `x1` = %f, `x2` = %f, `y0` = %f, `y1` = %f, `y2` = %f WHERE `rowid` = %i", iType, iGroup, xPos[0], xPos[1], xPos[2], yPos[0], yPos[1], yPos[2], iZoneId);

	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_UPDATEZONE;

	g_Global.Queries.Push(qQuery);
}

void Sql_DeleteZone(int iZoneId) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];

	if (g_Global.IsMySql) Format(cBuffer, 512, "DELETE FROM `zones` WHERE `id` = %i", iZoneId);
	else Format(cBuffer, 512, "DELETE FROM `zones` WHERE `rowid` = %i", iZoneId);

	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_DELETEZONE;

	g_Global.Queries.Push(qQuery);
}

void Sql_AddRecord(int iClient, int iStyle, int iGroup, float fTime, Checkpoints cCheckpoints) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];
	char[] cMapName = new char[64];

	GetCurrentMap(cBuffer, 512);
	g_Global.Storage.Escape(cBuffer, cMapName, 64);
	int iClientId = GetSteamAccountID(iClient);

	Format(cBuffer, 512, "INSERT INTO `records` ('mapname', 'playerid', 'style', 'group', 'time') VALUES ('%s', %i, %i, %i, %f);", cMapName, iClientId, iStyle, iGroup, fTime);
	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_INSERTRECORD;
	qQuery.Checkpoints = cCheckpoints;
	g_Global.Queries.Push(qQuery);
}

void Sql_AddCheckpoint(int iRecordId, int iZoneId, float fTime) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];

	Format(cBuffer, 512, "INSERT INTO `checkpoints` ('recordid', 'zoneid', 'time') VALUES (%i, %i, %f);", iRecordId, iZoneId, fTime);
	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_INSERTCHECKPOINT;
	g_Global.Queries.Push(qQuery);
}

void Sql_SelectZones() {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];
	char[] cMapName = new char[64];

	GetCurrentMap(cBuffer, 512);
	g_Global.Storage.Escape(cBuffer, cMapName, 64);

	if (g_Global.IsMySql) Format(cBuffer, 512, "SELECT `id`, `type`, `group`, `x0`, `x1`, `x2`, `y0`, `y1`, `y2` FROM `zones` WHERE `mapname`='%s';", cMapName);
	else Format(cBuffer, 512, "SELECT `rowid`, `type`, `group`, `x0`, `x1`, `x2`, `y0`, `y1`, `y2` FROM `zones` WHERE `mapname`='%s';", cMapName);

	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_SELECTZONE;
	g_Global.Queries.Push(qQuery);
}

void Sql_Timer() {
	if (g_Global.Queries.Length == 0) return;
	Transaction tQueries = new Transaction();

	for (int i = 0; i < g_Global.Queries.Length; i++) {
		Query qQuery = g_Global.Queries.Get(i);
		char[] cQuery = new char[512];

		qQuery.GetQuery(cQuery, 512);
		tQueries.AddQuery(cQuery, qQuery);
		PrintToServer("%s", cQuery);
	}

	g_Global.Queries.Clear();
	SQL_ExecuteTransaction(g_Global.Storage, tQueries, T_Success, T_Error);
}

void T_Success(Database dStorage, any aData, int iQueries, DBResultSet[] rResults, Query[] qQuery) {
	for (int i = 0; i < iQueries; i++) {
		switch (qQuery[i].Type) {
			case QUERY_INSERTZONE: {
				Zone zZone;
				g_Global.Zones.GetArray(qQuery[i].Index, zZone);

				zZone.Id = rResults[i].InsertId;
				g_Global.Zones.SetArray(qQuery[i].Index, zZone);
			} case QUERY_SELECTZONE: {
				float xPos[3], yPos[3];

				for (int k = 0; k < rResults[i].RowCount; k++) {
					rResults[i].FetchRow();

					for (int l = 0; l < 3; l++) {
						xPos[l] = rResults[i].FetchFloat(3 + l);
						yPos[l] = rResults[i].FetchFloat(6 + l);
					}

					Zone_AddZone(xPos, yPos, rResults[i].FetchInt(1), rResults[i].FetchInt(2), rResults[i].FetchInt(0));
					// Sql_LoadRecord(rResults[i].FetchInt(0));
				}

				Zone_Reload();
			} case QUERY_INSERTRECORD: {
				for (int k = 0; k < qQuery[i].Checkpoints.Length; k++) {
					Checkpoint cCheckpoint;
					qQuery[i].Checkpoints.GetArray(k, cCheckpoint);
					Sql_AddCheckpoint(rResults[i].InsertId, cCheckpoint.ZoneId, cCheckpoint.Time);
				}

				delete qQuery[i].Checkpoints;
			}
		}
		delete qQuery[i];
	}
}

void T_Error(Database dStorage, any aData, int iQueries, const char[] cError, int iFailIndex, Query[] qQuery) {
	LogError("SQL Error: %s", cError);
	for (int i = 0; i < iQueries; i++) delete qQuery[i];
}