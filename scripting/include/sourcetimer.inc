#define PLAYER_VALID 0
#define PLAYER_INGAME 1
#define PLAYER_ALIVE 2
#define ZONES_TOTAL 3

// csgocolors.inc - Author: exvel, Editor: Popoklopsi, Powerlord, Zipcore, Bara
#define COLORS_MAX 19
#define MAX_MESSAGE_LENGTH 250

char C_Tags[][] = {
	"{default}",
	"{white}",
	"{darkred}",
	"{green}",
	"{lightyellow}",
	"{lightblue}",
	"{olive}",
	"{lime}",
	"{red}",
	"{purple}",
	"{grey}",
	"{yellow}",
	"{orange}",
	"{silver}",
	"{blue}",
	"{darkblue}",
	"{bluegrey}",
	"{magenta}",
	"{lightred}"
};

char C_TagCodes[][] = {
	"\x01",
	"\x01",
	"\x02",
	"\x04",
	"\x03",
	"\x03",
	"\x05",
	"\x06",
	"\x07",
	"\x03",
	"\x08",
	"\x09",
	"\x10",
	"\x0A",
	"\x0B",
	"\x0C",
	"\x0D",
	"\x0E",
	"\x0F"
};

int C_Colors[][] = {
	{ 255, 0, 0, 255 }, // Red
	{ 0, 255, 0, 255 }, // Green
	{ 0, 0, 255, 255 }, // Blue
	{ 255, 255, 127, 255 }, // Admin Zoning In-Progress
	{ 0, 255, 127, 255 }, // Admin Zoning Complete
	{ 255, 127, 0, 255 }, // N Checkpoint
	{ 0, 255, 0, 255 }, // N Start
	{ 255, 0, 0, 255 }, // N End
	{ 200, 100, 0, 255 }, // B Checkpoint
	{ 23, 150, 102, 255 }, // B Start
	{ 153, 0, 153, 255 } // B End
};

enum struct Checkpoint {
	float Time;
	int ZoneId;
	int RecordId;
}

methodmap Checkpoints < ArrayList {
	public Checkpoints() { return view_as<Checkpoints>(new ArrayList(sizeof(Checkpoint))); }

	public Checkpoints FindByRecordId(int iRecordId) {
		Checkpoints cCheckpoints = new Checkpoints();

		for (int i = 0; i < this.Length; i++) {
			Checkpoint cCheckpoint;
			this.GetArray(i, cCheckpoint);
			if (cCheckpoint.RecordId == iRecordId) cCheckpoints.PushArray(cCheckpoint);
		}

		return cCheckpoints;
	}

	public Checkpoints FindByZoneId(int iZoneId) {
		Checkpoints cCheckpoints = new Checkpoints();

		for (int i = 0; i < this.Length; i++) {
			Checkpoint cCheckpoint;
			this.GetArray(i, cCheckpoint);
			if (cCheckpoint.ZoneId == iZoneId) cCheckpoints.PushArray(cCheckpoint);
		}

		return cCheckpoints;
	}
}

enum struct Record {
	float StartTime;
	float EndTime;
	int Group;
	int Style;
	int Id;
}

methodmap Records < ArrayList {
	public Records() { return view_as<Records>(new ArrayList(sizeof(Record))); }

	public int FindByRecordId(int iRecordId) {
		for (int i = 0; i < this.Length; i++) {
			Record rRecord;
			this.GetArray(i, rRecord);
			if (rRecord.Id == iRecordId) return i;
		}

		return -1;
	}
}

enum struct Zone {
	int RecordIndex[MAXPLAYERS + 1];
	int Id;
	int Type;
	int Group;
	float xPos[3];
	float yPos[3];

	void GetX(float fPos[3]) {
		for (int i = 0; i < 3; i++) fPos[i] = this.xPos[i];
	}

	void GetY(float fPos[3]) {
		for (int i = 0; i < 3; i++) fPos[i] = this.yPos[i];
	}

	void SetX(float fPos[3]) {
		for (int i = 0; i < 3; i++) this.xPos[i] = fPos[i];
	}

	void SetY(float fPos[3]) {
		for (int i = 0; i < 3; i++) this.yPos[i] = fPos[i];
	}
}

methodmap Zones < ArrayList {
	public Zones() { return view_as<Zones>(new ArrayList(sizeof(Zone))); }

	public int FindByZoneId(int iZoneId) {
		for (int i = 0; i < this.Length; i++) {
			Zone zZone;
			this.GetArray(i, zZone);
			if (zZone.Id == iZoneId) return i;
		}

		return -1;
	}

	public int FindSingleZone(int iType, int iGroup) {
		for (int i = 0; i < this.Length; i++) {
			Zone zZone;
			this.GetArray(i, zZone);
			if ((zZone.Type == iType) && (zZone.Group == iGroup)) return i;
		}

		return -1;
	}

	public int GetTotalZoneGroups() {
		int iTotalZoneGroups;

		for (int i = 0; i < this.Length; i++) {
			Zone zZone;
			this.GetArray(i, zZone);
			if (zZone.Group > iTotalZoneGroups) iTotalZoneGroups = zZone.Group;
		}

		return iTotalZoneGroups;
	}
}

enum struct Player {
	Checkpoints RecordCheckpoints;
	Records Records;

	Checkpoints Checkpoints;
	Record Record;
	int CurrentZone;
	int Style;
}

methodmap Models < StringMap {
	public Models() { return view_as<Models>(new StringMap()); }

	property int BlueGlow {
		public get() { int iIndex; this.GetValue("blueglow", iIndex); return iIndex; }
		public set(int iIndex) { this.SetValue("blueglow", iIndex); }
	}

	property int RedGlow {
		public get() { int iIndex; this.GetValue("redglow", iIndex); return iIndex; }
		public set(int iIndex) { this.SetValue("redglow", iIndex); }
	}

	property int Laser {
		public get() { int iIndex; this.GetValue("laser", iIndex); return iIndex; }
		public set(int iIndex) { this.SetValue("laser", iIndex); }
	}

	property int Glow {
		public get() { int iIndex; this.GetValue("glow", iIndex); return iIndex; }
		public set(int iIndex) { this.SetValue("glow", iIndex); }
	}

	property int Zone {
		public get() { int iIndex; this.GetValue("zone", iIndex); return iIndex; }
		public set(int iIndex) { this.SetValue("zone", iIndex); }
	}
}

enum {
	QUERY_CREATETABLE = 0,
	QUERY_INSERTZONE = 1,
	QUERY_UPDATEZONE = 3,
	QUERY_SELECTZONE = 2,
	QUERY_DELETEZONE = 4,
	QUERY_INSERTRECORD = 5,
	QUERY_SELECTRECORD = 6,
	QUERY_DELETERECORD = 7,
	QUERY_INSERTCHECKPOINT = 8,
	QUERY_SELECTCHECKPOINT = 9,
	QUERY_DELETECHECKPOINT = 10
}

enum {
	ZONE_UNDEFINED = -1,
	ZONE_CHECKPOINT = 0,
	ZONE_START = 1,
	ZONE_END = 2
}

methodmap Query < StringMap {
	public Query() { return view_as<Query>(new StringMap()); }

	public void GetQuery(char[] cQuery, int iLength) {
		this.GetString("query", cQuery, iLength);
	}

	public void SetQuery(char[] cQuery) {
		this.SetString("query", cQuery);
	}

	property int Type {
		public get() { int iType; this.GetValue("type", iType); return iType; }
		public set(int iType) { this.SetValue("type", iType); }
	}

	property int Index {
		public get() { int iIndex; this.GetValue("index", iIndex); return iIndex; }
		public set(int iIndex) { this.SetValue("index", iIndex); }
	}

	property int Client {
		public get() { int iClient; this.GetValue("client", iClient); return iClient; }
		public set(int iClient) { this.SetValue("client", iClient); }
	}

	property Checkpoints Checkpoints {
		public get() { Checkpoints cCheckpoints; this.GetValue("checkpoints", cCheckpoints); return cCheckpoints; }
		public set(Checkpoints cCheckpoints) { this.SetValue("checkpoints", cCheckpoints); }
	}
}

methodmap Global < StringMap {
	public Global() {
		StringMap smMap = new StringMap();

		smMap.SetValue("timer", INVALID_HANDLE);
		smMap.SetValue("storage", INVALID_HANDLE);
		smMap.SetValue("queries", new ArrayList());
		smMap.SetValue("checkpoints", new Checkpoints());
		smMap.SetValue("records", new Records());
		smMap.SetValue("zones", new Zones());
		smMap.SetValue("models", new Models());
		smMap.SetValue("render", 0);
		return view_as<Global>(smMap);
	}

	property Handle Timer {
		public get() { Handle hTimer; this.GetValue("timer", hTimer); return hTimer; }
		public set(Handle hTimer) { this.SetValue("timer", hTimer); }
	}

	property Database Storage {
		public get() { Database dStorage; this.GetValue("storage", dStorage); return dStorage; }
		public set(Database dStorage) { this.SetValue("storage", dStorage); }
	}

	property bool IsMySql {
		public get() { bool bIsMySql; this.GetValue("ismysql", bIsMySql); return bIsMySql; }
		public set(bool bIsMySql) { this.SetValue("ismysql", bIsMySql); }
	}

	property ArrayList Queries {
		public get() { ArrayList alQueries; this.GetValue("queries", alQueries); return alQueries; }
		public set(ArrayList alQueries) { this.SetValue("queries", alQueries); }
	}

	property Checkpoints Checkpoints {
		public get() { Checkpoints cCheckpoints; this.GetValue("checkpoints", cCheckpoints); return cCheckpoints; }
		public set(Checkpoints cCheckpoints) { this.SetValue("checkpoints", cCheckpoints); }
	}

	property Records Records {
		public get() { Records rRecords; this.GetValue("records", rRecords); return rRecords; }
		public set(Records rRecords) { this.SetValue("records", rRecords); }
	}

	property Zones Zones {
		public get() { Zones zZones; this.GetValue("zones", zZones); return zZones; }
		public set(Zones zZones) { this.SetValue("zones", zZones); }
	}

	property Models Models {
		public get() { Models mModels; this.GetValue("models", mModels); return mModels; }
		public set(Models mModels) { this.SetValue("models", mModels); }
	}

	property int Render {
		public get() { int iRender; this.GetValue("render", iRender); return iRender; }
		public set(int iRender) { this.SetValue("render", iRender); }
	}
}

stock void Timer_CommandReply(int iClient, const char[] cMessage, any ...) {
	char[] cCMessage = new char[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(iClient);
	VFormat(cCMessage, MAX_MESSAGE_LENGTH, cMessage, 3);
	ChangeTags(cCMessage, MAX_MESSAGE_LENGTH);

	if (iClient == 0 || GetCmdReplySource() == SM_REPLY_TO_CONSOLE) RemoveTags(cCMessage, MAX_MESSAGE_LENGTH);

	if (iClient == 0) PrintToServer(cCMessage);
	else if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE) PrintToConsole(iClient, cCMessage);
	else PrintToChat(iClient, cCMessage);
}

void ChangeTags(char[] cMessage, int iLength) {
	for (int i = 0; i < COLORS_MAX; i++) ReplaceString(cMessage, iLength, C_Tags[i], C_TagCodes[i]);
}

void RemoveTags(char[] cMessage, int iLength) {
	for (int i = 0; i < COLORS_MAX; i++) ReplaceString(cMessage, iLength, C_TagCodes[i], "");
}