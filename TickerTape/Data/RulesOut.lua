local AllRules = {

	--      CMD     {Offset    Format   Decode   Name  {Logic    Table  Extra
	--                bit                                 Flag}
	--                 #bits}

--	Standard Header -----------------------------------------------------------

[0xFFF] = {

	[1]  =  {  {},  {0},   'byte',    'raw',    'Packet ID'	},
	[2]  =  {  {},  {1},   'byte',    'psize',  'Data Size'	},
	[3]  =  {  {},  {2},   'rword',   'raw',    'Sync'	    },
	[4]  =  {  {'return' } },

	},	--	[[ COMPLETE ]]

--	Client Leave --------------------------------------------------------------

[0x00D] = {

	[1] =   {	{ 'call', 0xFFF }, 							},
	[2] =	{  {}, {-1},   'byte',   'info',    'INFO', 		{},  0,	'There is no data in this packet' },
	[3] =	{  {}, {-1},   'byte',   'info',    'INFO', 		{},  0,	'that is used by the server' },

	},	--	[[ COMPLETE ]]

--	Standard Client -----------------------------------------------------------

[0x015] = {

	[1] =   {	{ 'call', 0xFFF }, 							    },
	[2] =   {	{},  {4},  '12bytes',   'xyz',     'Position'	},
	[3] =   {	{},  {20}, 'byte',      'dir',     'Dir'		},
	[4] =   {	{},  {18}, 'byte',      'raw',     'Run Count'	},
	[5] =   {	{},  {22}, 'rword',     'eid',     'Target ID'	},
	[6] =   {	{},  {24}, 'rdword',    'time',    'Timestamp'	},

	},	--	[[ COMPLETE ]]

--	Action	-------------------------------------------------------------------

[0x01A] = {

	[1] =   {	{ 'call', 0xFFF }, 							   },
	[2]   =	{	{},  {4},   'rdword',  'player', 'Target ID'	   },
	[3]   =	{	{},  {8},   'rword',   'raw',    'Target Index'	   },
	[4]   =	{	{},  {10},  'rword',   'action', 'Action Type'	   },

	[5]  =  {  { 'switch', 0x0A, 1},										    	},

	[6]  =  {  { 'case', 0x1A },	     											},
	[7]  =	{  {}, {0x1A},  'byte',   'raw',     'Mode (Mounts)'      			},
	[8]   =	{  {}, {0x0C},  'rword',   'raw',    'Type',  {},  7 },
	[9]  =  {  { 'break' },          											},

	[10]  =  {  { 'end' },          											},

	},

--	Speach --------------------------------------------------------------------

[0x0B5] = {

	[1]  =  {  { 'call', 0xFFF }, 									},
	[2]  =	{  {}, {6},       'byte',     'string',  'Command'  	},

	},	--	[[ COMPLETE ]]

}

return AllRules
