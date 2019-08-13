char g_SqlTables[][] = {
	"CREATE TABLE IF NOT EXISTS `zones` (`id` INT AUTO_INCREMENT, `mapname` VARCHAR(64)`, `type` INT, `group` INT, `x0` FLOAT, `x1` FLOAT, `x2` FLOAT, `y0` FLOAT, `y1` FLOAT, `y2` FLOAT);"
};

char g_SqlLiteTables[][] = {
	"CREATE TABLE IF NOT EXISTS `zones` (`mapname` VARCHAR(64), `type` INT, `group` INT, `x0` FLOAT, `x1` FLOAT, `x2` FLOAT, `y0` FLOAT, `y1` FLOAT, `y2` FLOAT);"
};

void T_Connect(Database dStorage, const char[] cError, any aData) {
	if (dStorage == null) LogError("SQL Error, %s", cError);
	char[] cDriver = new char[32];
	dStorage.Driver.GetIdentifier(cDriver, 32);

	if (StrEqual(cDriver, "mysql")) g_Global.IsMySql = true;
	g_Global.Storage = dStorage;
}

void Sql_CreateTables() {
	for (int i = 0; i < sizeof(g_SqlTables); i++) {
		Query qQuery = new Query();
		qQuery.Type = view_as<int>(QUERY_CREATETABLE);

		if (g_Global.IsMySql) qQuery.SetQuery(g_SqlTables[i]);
		else qQuery.SetQuery(g_SqlLiteTables[i]);

		g_Global.Queries.Push(qQuery);
	}
}

void Sql_Timer() {
	if (g_Global.Queries.Length == 0) return;
	Transaction tQueries = new Transaction();

	for (int i = 0; i < g_Global.Queries.Length; i++) {
		Query qQuery = g_Global.Queries.Get(i);
		char[] cQuery = new char[512];
		Query qNewQuery = new Query();

		qQuery.GetQuery(cQuery, 512);
		qNewQuery.Type = qQuery.Type;
		tQueries.AddQuery(cQuery, qNewQuery);
		delete qQuery;
	}

	g_Global.Queries.Clear();
	SQL_ExecuteTransaction(g_Global.Storage, tQueries, T_Success, T_Error);
}

void T_Success(Database dStorage, any aData, int iQueries, DBResultSet[] rResults, Query[] qQuery) {
	PrintToChatAll("Executed: %i", iQueries);
	for (int i = 0; i < iQueries; i++) {
		delete qQuery[i];
	}
}

void T_Error(Database dStorage, any aData, int iQueries, const char[] cError, int iFailIndex, Query[] qQuery) {
	LogError("SQL Error: %s", cError);
	for (int i = 0; i < iQueries; i++) delete qQuery[i];
}