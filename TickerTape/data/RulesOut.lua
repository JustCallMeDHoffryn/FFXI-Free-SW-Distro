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

--	Standard Client -----------------------------------------------------------

[0x015] = {

	[1] =   {	{ 'call', 0xFFF }, 							},
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
	[5]   =	{	{},  {12},  'rword',   'raw',    'Action',  {},  2 },

	},	--	[[ COMPLETE ]]

--	Speach --------------------------------------------------------------------

[0x0B5] = {

	[1]  =  {  { 'call', 0xFFF }, 									},
	[2]  =	{  {}, {6},       'byte',     'string',  'Command'  	},

	},	--	[[ COMPLETE ]]

}

return AllRules
