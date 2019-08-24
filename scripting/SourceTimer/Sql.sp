char g_SqlTables[][] = {
	"CREATE TABLE IF NOT EXISTS `zones` (`id` INT AUTO_INCREMENT PRIMARY KEY, `mapname` VARCHAR(64), `type` INT, `group` INT, `x0` FLOAT, `x1` FLOAT, `x2` FLOAT, `y0` FLOAT, `y1` FLOAT, `y2` FLOAT);",
	"CREATE TABLE IF NOT EXISTS `records` (`id` INT AUTO_INCREMENT PRIMARY KEY, `mapname` VARCHAR(64), `playerid` INT, `time` FLOAT, `type` INT, `group` INT);",
	"CREATE TABLE IF NOT EXISTS `checkpoints` (`id` INT AUTO_INCREMENT PRIMARY KEY, `playerid` INT, `recordid` INT, `zoneid` INT, `time` FLOAT);"
};

char g_SqlLiteTables[][] = {
	"CREATE TABLE IF NOT EXISTS `zones` (`mapname` VARCHAR(64), `type` INT, `group` INT, `x0` FLOAT, `x1` FLOAT, `x2` FLOAT, `y0` FLOAT, `y1` FLOAT, `y2` FLOAT);",
	"CREATE TABLE IF NOT EXISTS `records` (`mapname` VARCHAR(64), `playerid` INT, `time` FLOAT, `style` INT, `group` INT);",
	"CREATE TABLE IF NOT EXISTS `checkpoints` (`playerid` INT, `recordid` INT, `zoneid` INT, `time` FLOAT);"
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
		
		if (g_Global.IsMySql) qQuery.SetQuery(g_SqlTables[i]);
		else qQuery.SetQuery(g_SqlLiteTables[i]);

		qQuery.Type = QUERY_CREATETABLE;
		g_Global.Queries.Push(qQuery);
	}
}

void Sql_AddZone(int iIndex, float xPos[3], float yPos[3], int iType, int iGroup) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];
	char[] cMapName = new char[64];

	GetCurrentMap(cBuffer, 512);
	g_Global.Storage.Escape(cBuffer, cMapName, 64);

	if (g_Global.IsMySql) Format(cBuffer, 512, "INSERT INTO `zones` (`mapname`, `type`, `group`, `x0`, `x1`, `x2`, `y0`, `y1`, `y2`) VALUES ('%s', %i, %i, %f, %f, %f, %f, %f, %f);", cMapName, iType, iGroup, xPos[0], xPos[1], xPos[2], yPos[0], yPos[1], yPos[2]);
	else Format(cBuffer, 512, "INSERT INTO `zones` ('mapname', 'type', 'group', 'x0', 'x1', 'x2', 'y0', 'y1', 'y2') VALUES ('%s', %i, %i, %f, %f, %f, %f, %f, %f);", cMapName, iType, iGroup, xPos[0], xPos[1], xPos[2], yPos[0], yPos[1], yPos[2]);
	

	qQuery.SetQuery(cBuffer);
	qQuery.Index = iIndex;
	qQuery.Type = QUERY_INSERTZONE;
	g_Global.Queries.Push(qQuery);
}

void Sql_SelectZones() {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];
	char[] cMapName = new char[64];

	GetCurrentMap(cMapName, 64);
	if (g_Global.IsMySql) Format(cBuffer, 512, "SELECT `id`, `type`, `group`, `x0`, `x1`, `x2`, `y0`, `y1`, `y2` FROM `zones` WHERE `mapname`='%s';", cMapName);
	else Format(cBuffer, 512, "SELECT `rowid`, `type`, `group`, `x0`, `x1`, `x2`, `y0`, `y1`, `y2` FROM `zones` WHERE `mapname`='%s';", cMapName);

	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_SELECTZONE;
	g_Global.Queries.Push(qQuery);
}

void Sql_UpdateZone(int iZoneId, float xPos[3], float yPos[3], int iType, int iGroup) {
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

	if (g_Global.IsMySql) Format(cBuffer, 512, "INSERT INTO `records` (`mapname`, `playerid`, `style`, `group`, `time`) VALUES ('%s', %i, %i, %i, %f);", cMapName, iClientId, iStyle, iGroup, fTime);
	else Format(cBuffer, 512, "INSERT INTO `records` ('mapname', 'playerid', 'style', 'group', 'time') VALUES ('%s', %i, %i, %i, %f);", cMapName, iClientId, iStyle, iGroup, fTime);
	
	qQuery.SetQuery(cBuffer);
	qQuery.Client = iClientId;
	qQuery.Checkpoints = cCheckpoints;
	qQuery.Type = QUERY_INSERTRECORD;
	g_Global.Queries.Push(qQuery);
}

void Sql_AddCheckpoint(int iClientId, int iRecordId, int iZoneId, float fTime) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];

	if (g_Global.IsMySql) Format(cBuffer, 512, "INSERT INTO `checkpoints` (`playerid`, `recordid`, `zoneid`, `time`) VALUES (%i, %i, %i, %f);", iClientId, iRecordId, iZoneId, fTime);
	else Format(cBuffer, 512, "INSERT INTO `checkpoints` ('playerid', 'recordid', 'zoneid', 'time') VALUES (%i, %i, %i, %f);", iClientId, iRecordId, iZoneId, fTime);

	qQuery.SetQuery(cBuffer);
	qQuery.Type = QUERY_INSERTCHECKPOINT;
	g_Global.Queries.Push(qQuery);
}

void Sql_SelectRecord(int iClient, int iIndex, int iGroup) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];
	char[] cMapName = new char[64];

	GetCurrentMap(cBuffer, 512);
	g_Global.Storage.Escape(cBuffer, cMapName, 64);

	if (g_Global.IsMySql) Format(cBuffer, 512, "SELECT `id`, `time`, `group`, `style` FROM `records` WHERE `mapname`='%s' AND `group`=%i", cMapName, iGroup, ZONE_END);
	else Format(cBuffer, 512, "SELECT `rowid`, `time`, `group`, `style` FROM `records` WHERE `mapname`='%s' AND `group`=%i", cMapName, iGroup, ZONE_END);

	if (iClient != 0) {
		int iClientId = GetSteamAccountID(iClient);
		qQuery.Client = GetClientUserId(iClient);
		Format(cBuffer, 512, "%s AND `playerid`=%i", cBuffer, iClientId);
	}

	Format(cBuffer, 512, "%s ORDER BY `time` ASC", cBuffer);
	qQuery.SetQuery(cBuffer);
	qQuery.Index = iIndex;
	qQuery.Type = QUERY_SELECTRECORD;
	g_Global.Queries.Push(qQuery);
}

void Sql_SelectCheckpoint(int iClient, int iIndex, int iZoneId) {
	Query qQuery = new Query();
	char[] cBuffer = new char[512];

	if (g_Global.IsMySql) Format(cBuffer, 512, "SELECT `id`, `recordid`, `zoneid`, `time` FROM `checkpoints` WHERE `zoneid`=%i", iZoneId);
	else Format(cBuffer, 512, "SELECT `rowid`, `recordid`, `zoneid`, `time` FROM `checkpoints` WHERE `zoneid`=%i", iZoneId);

	if (iClient != 0) {
		int iClientId = GetSteamAccountID(iClient);
		qQuery.Client = GetClientUserId(iClient);
		Format(cBuffer, 512, "%s AND `playerid`=%i", cBuffer, iClientId);
	}

	Format(cBuffer, 512, "%s ORDER BY `time` ASC", cBuffer);
	qQuery.SetQuery(cBuffer);
	qQuery.Index = iIndex;
	qQuery.Type = QUERY_SELECTCHECKPOINT;
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

void Query_InsertZone(DBResultSet rResults, Query qQuery) {
	Zone zZone; g_Global.Zones.GetArray(qQuery.Index, zZone);
	zZone.Id = rResults.InsertId;
	g_Global.Zones.SetArray(qQuery.Index, zZone);
}

void Query_SelectZone(DBResultSet rResults) {
	float xPos[3], yPos[3];

	for (int i = 0; i < rResults.RowCount; i++) {
		rResults.FetchRow();

		for (int k = 0; k < 3; k++) {
			xPos[k] = rResults.FetchFloat(3 + k);
			yPos[k] = rResults.FetchFloat(6 + k);
		}

		Zone_AddZone(xPos, yPos, rResults.FetchInt(1), rResults.FetchInt(2), rResults.FetchInt(0));

		for (int k = 0; k <= MaxClients; k++) {
			if (!Misc_CheckPlayer(k, PLAYER_INGAME) && k != 0) continue;
			switch (rResults.FetchInt(1)) {
				case ZONE_END: Sql_SelectRecord(k, g_Global.Zones.Length - 1, rResults.FetchInt(2));
				case ZONE_CHECKPOINT: Sql_SelectCheckpoint(k, g_Global.Zones.Length - 1, rResults.FetchInt(0));
			}
		}
	}

	Zone_Reload();
}

void Query_InsertRecord(DBResultSet rResults, Query qQuery) {
	for (int i = 0; i < qQuery.Checkpoints.Length; i++) {
		Checkpoint cCheckpoint; qQuery.Checkpoints.GetArray(i, cCheckpoint);
		Sql_AddCheckpoint(qQuery.Client, rResults.InsertId, cCheckpoint.ZoneId, cCheckpoint.Time);
	}
	delete qQuery.Checkpoints;
}

void Query_SelectRecord(DBResultSet rResults, Query qQuery) {
	int iClient = GetClientOfUserId(qQuery.Client);
	if (iClient == 0 && qQuery.Client != 0) return;

	Zone zZone; g_Global.Zones.GetArray(qQuery.Index, zZone);

	for (int i = 0; i < rResults.RowCount; i++) {
		rResults.FetchRow();
		Record rRecord;

		rRecord.Id = rResults.FetchInt(0);
		rRecord.EndTime = rResults.FetchFloat(1);
		rRecord.Group = rResults.FetchInt(2);
		rRecord.Style = rResults.FetchInt(3);

		if (iClient == 0) {
			if (i == 0) zZone.RecordIndex[0] = g_Global.Records.Length;
			g_Global.Records.PushArray(rRecord);
		} else {
			if (i == 0) zZone.RecordIndex[iClient] = gP_Player[iClient].Records.Length;
			gP_Player[iClient].Records.PushArray(rRecord);
		}

		g_Global.Zones.SetArray(qQuery.Index, zZone);
	}
}

void Query_SelectCheckpoint(DBResultSet rResults, Query qQuery) {
	int iClient = GetClientOfUserId(qQuery.Client);
	if (iClient == 0 && qQuery.Client != 0) return;

	Zone zZone; g_Global.Zones.GetArray(qQuery.Index, zZone);

	for (int i = 0; i < rResults.RowCount; i++) {
		rResults.FetchRow();
		Checkpoint cCheckpoint;

		cCheckpoint.RecordId  = rResults.FetchInt(1);
		cCheckpoint.ZoneId = rResults.FetchInt(2);
		cCheckpoint.Time = rResults.FetchFloat(3);

		if (iClient == 0) {
			if (i == 0) zZone.RecordIndex[0] = g_Global.Checkpoints.Length;
			g_Global.Checkpoints.PushArray(cCheckpoint);
		} else {
			if (i == 0) zZone.RecordIndex[iClient] = gP_Player[iClient].RecordCheckpoints.Length;
			gP_Player[iClient].RecordCheckpoints.PushArray(cCheckpoint);
		}
	}

	g_Global.Zones.SetArray(qQuery.Index, zZone);
}

void T_Success(Database dStorage, any aData, int iQueries, DBResultSet[] rResults, Query[] qQuery) {
	for (int i = 0; i < iQueries; i++) {
		switch (qQuery[i].Type) {
			case QUERY_INSERTZONE: Query_InsertZone(rResults[i], qQuery[i]);
			case QUERY_SELECTZONE: Query_SelectZone(rResults[i]);
			case QUERY_INSERTRECORD: Query_InsertRecord(rResults[i], qQuery[i]);
			case QUERY_SELECTRECORD: Query_SelectRecord(rResults[i], qQuery[i]);
			case QUERY_SELECTCHECKPOINT: Query_SelectCheckpoint(rResults[i], qQuery[i]);
		}
		delete qQuery[i];
	}
}

void T_Error(Database dStorage, any aData, int iQueries, const char[] cError, int iFailIndex, Query[] qQuery) {
	LogError("SQL Error: %s", cError);
	for (int i = 0; i < iQueries; i++) delete qQuery[i];
}