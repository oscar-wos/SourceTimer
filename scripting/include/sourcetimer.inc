enum {
	PLAYER_ENTITY,
	PLAYER_CONNECTED,
	PLAYER_INGAME,
	PLAYER_VALID,
	PLAYER_ALIVE,
}

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

char C_BlockMessages[][] = {
	"#Player_Cash_Award_ExplainSuicide_YouGotCash",
	"#Player_Cash_Award_ExplainSuicide_Spectators",
	"#Player_Cash_Award_ExplainSuicide_EnemyGotCash",
	"#Player_Cash_Award_ExplainSuicide_TeammateGotCash",
	"#game_respawn_as",
	"#game_spawn_as",
	"#Player_Cash_Award_Killed_Enemy",
	"#Team_Cash_Award_Win_Time",
	"#Player_Point_Award_Assist_Enemy_Plural",
	"#Player_Point_Award_Assist_Enemy",
	"#Player_Point_Award_Killed_Enemy_Plural",
	"#Player_Point_Award_Killed_Enemy",
	"#Player_Cash_Award_Respawn",
	"#Player_Cash_Award_Get_Killed",
	"#Player_Cash_Award_Killed_Enemy",
	"#Player_Cash_Award_Killed_Enemy_Generic",
	"#Player_Cash_Award_Kill_Teammate",
	"#Team_Cash_Award_Loser_Bonus",
	"#Team_Cash_Award_Loser_Zero",
	"#Team_Cash_Award_no_income",
	"#Team_Cash_Award_Generic",
	"#Team_Cash_Award_Custom",
	"#Player_Cash_Award_ExplainSuicide_YouGotCash",
	"#Player_Cash_Award_ExplainSuicide_TeammateGotCash",
	"#Player_Cash_Award_ExplainSuicide_EnemyGotCash",
	"#Player_Cash_Award_ExplainSuicide_Spectators"
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

	public Records FindByStyleGroup(int iStyle, int iGroup) {
		Records rRecords = new Records();

		for (int i = 0; i < this.Length; i++) {
			Record rRecord; this.GetArray(i, rRecord);
			if (rRecord.Style == iStyle && rRecord.Group == iGroup) rRecords.PushArray(rRecord);
		}

		return rRecords;
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

enum struct ReplayFrame {
	float fPos[3];
	float fAngle[3];
	float fVel[3];
	int Buttons;

	void GetPos(float fVec[3]) {
		for (int i = 0; i < 3; i++) fVec[i] = this.fPos[i];
	}

	void GetAngle(float fVec[3]) {
		for (int i = 0; i < 3; i++) fVec[i] = this.fAngle[i];
	}

	void GetVel(float fVec[3]) {
		for (int i = 0; i < 3; i++) fVec[i] = this.fVel[i];
	}

	void SetPos(float fVec[3]) {
		for (int i = 0; i < 3; i++) this.fPos[i] = fVec[i];
	}

	void SetAngle(float fVec[3]) {
		for (int i = 0; i < 3; i++) this.fAngle[i] = fVec[i];
	}

	void SetVel(float fVec[3]) {
		for (int i = 0; i < 3; i++) this.fVel[i] = fVec[i];
	}
}

methodmap Replay < StringMap {
	public Replay() {
		StringMap smMap = new StringMap();

		smMap.SetValue("frames", new ArrayList(sizeof(ReplayFrame)));
		return view_as<Replay>(smMap);
	}

	property ArrayList Frames {
		public get() { ArrayList alFrames; this.GetValue("frames", alFrames); return alFrames; }
		public set(ArrayList alFrames) { this.SetValue("frames", alFrames); }
	}

	property int Frame {
		public get() { int iFrame; this.GetValue("frame", iFrame); return iFrame; }
		public set(int iFrame) { this.SetValue("frame", iFrame); }
	}
}

enum struct Bot {
	Replay Replay;
	int Client;
}

enum struct Player {
	Checkpoints RecordCheckpoints;
	Records Records;
	Records CloneRecords;

	Checkpoints Checkpoints;
	Record Record;
	Replay Replay;
	int Style;
	int CurrentZone;
	int PreviousZone;
	int EndZoneIndex;
	float PreviousTime;
	bool RecentlyAbused;
	int CloneRecordsIndex;
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
		smMap.SetValue("convars", new StringMap());
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

	property StringMap Convars {
		public get() { StringMap smConvars; this.GetValue("convars", smConvars); return smConvars; }
		public set(StringMap smConvars) { this.SetValue("convars", smConvars); }
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

stock void Timer_Message(int iClient, const char[] cMessage, any ...) {
	char[] cCMessage = new char[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(iClient);
	VFormat(cCMessage, MAX_MESSAGE_LENGTH, cMessage, 3);
	ChangeTags(cCMessage, MAX_MESSAGE_LENGTH);

	if (iClient != 0) PrintToChat(iClient, cCMessage);
	else {
		RemoveTags(cCMessage, MAX_MESSAGE_LENGTH);
		PrintToServer(cCMessage);
	}
}

void ChangeTags(char[] cMessage, int iLength) {
	for (int i = 0; i < COLORS_MAX; i++) ReplaceString(cMessage, iLength, C_Tags[i], C_TagCodes[i]);
}

void RemoveTags(char[] cMessage, int iLength) {
	for (int i = 0; i < COLORS_MAX; i++) ReplaceString(cMessage, iLength, C_TagCodes[i], "");
}