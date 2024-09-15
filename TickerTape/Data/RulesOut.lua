
local NewRules = {

--	Decode EID and Entity (from 0x1A) -----------------------------------------

[0xFFE] = {

	[1]		=	{ {},	{4, 4},	'Target ID',	'entity',	},
	[2]		=	{ {},	{8, 2},	'Target Index',	'eid',		},
	[3]		=	{ {'return' } },

	},	--	[[ COMPLETE ]]

--	Standard Header -----------------------------------------------------------

[0xFFF] = {

	[1]		=	{ {},	{0},		'Packet ID',					},
	[2]		=	{ {},	{1,2,0,9},	'Data Size',	{ 'psize' },	},
	[3]		=	{ {},	{2, 2},		'Sync',							},
	[4]		=	{ {'return' } 										},

	},	--	[[ COMPLETE ]]

--	Client Connect ------------------------------------------------------------

[0x00A] = {

	[1]		=	{ { 'call', 0xFFF },							},
	[2]		=	{ {},  {34, 15},	'Name',		{ 'string' },	},
	[3]		=	{ {},  {49, 15},	'Account',	{ 'string' },	},
	[4]		=	{ {},  {80, 4},		'Version'					},
	[5]		=	{ {},  {84, 4},		'Platform',	{ 'string' },	},
	[6]		=	{ {},  {88, 2},		'Language'					},

	},	--	[[ COMPLETE ]]
	
--	Standard Client -----------------------------------------------------------

[0x015] = {

	[1] 	=   { { 'call', 0xFFF }, 													},
	[2]		=	{ {},		{4},  			'Position',			{ 'xyz'   },			},
	[3]		=	{ {},		{0x14},			'Direction',		{ 'dir'   },			},
	[4]		=	{ {},		{0x12},			'Run Count',								},
	[5]		=	{ {},		{0x16, 2},		'Target ID',		{ 'eid', 	'raw' },	},
	[6]		=	{ {},		{0x18, 4},		'Timestamp',		{ 'mstime', 'raw' },	},

	},	--	[[ COMPLETE ]]

}

-- ============================================================================

local AllRules = {

--	Zone In 1 -----------------------------------------------------------------

[0x00C] = {

	[1] =   {	{ 'call', 0xFFF }, 								},
	[2] =	{  {},  {4},	'rdword',		'raw',  	'Client State',	},
	[3] =	{  {},  {8},	'rdword',		'raw',  	'Debug State',	},

	},	--	[[ COMPLETE ]]

--	Client Leave --------------------------------------------------------------

[0x00D] = {

	[1] =   {	{ 'call', 0xFFF }, 							},
	[2] =	{  {}, {-1},   'byte',   'info',    'INFO', 		{},  0,	'There is no data in this packet' },
	[3] =	{  {}, {-1},   'byte',   'info',    'INFO', 		{},  0,	'that is used by the server' },

	},	--	[[ COMPLETE ]]

--	Zone In 2 -----------------------------------------------------------------

[0x00F] = {

	[1] =   {	{ 'call', 0xFFF }, 							},
	[2] =	{  {}, {-1},   'byte',   'info',    'INFO', 		{},  0,	'The status flags can be used by'   },
	[3] =	{  {}, {-1},   'byte',   'info',    'INFO', 		{},  0,	'the client if in a race condition' },
	[4]  =  {  { 'loop', 8, 4, 0 },                        		},
	[5]  =	{  {},  {4},  'rdword',  'raw',    'Status Flag'	},
	[6]  =  {  { 'end' },                                   	},

	},	--	[[ COMPLETE ]]

--	Zone In 3 -----------------------------------------------------------------

[0x011] = {

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

--	Update Request ------------------------------------------------------------

[0x016] = {

	[1] =   {	{ 'call', 0xFFF }, 							    },
	[2] =   {	{},  {4}, 'rword',     	'eid',     'Actor ID'	},

	},	--	[[ COMPLETE ]]

--	NPC Race Error ------------------------------------------------------------

[0x017] = {

	[1] =   {	{ 'call', 0xFFF }, 							    	},
	[2] =   {	{},  {4}, 	'rword', 	'eid',     'Actor ID'		},
	[3] =   {	{},  {8}, 	'rdword',   'raw',     'Unique No 2'	},
	[4] =   {	{},  {12},	'rdword',   'raw',     'Unique No 3'	},
	[6] =   {	{},  {16},	'rword',   	'raw',     'Flag'			},
	[7] =   {	{},  {18},	'rword',   	'raw',     'Flag 2'			},

	},	--	[[ COMPLETE ]]

--	Action	-------------------------------------------------------------------

[0x01A] = {

	[1]  =  { { 'call', 0xFFF }, 							   		},
	[2]  =	{ {},  {10},  'rword', 'action', 	'Action Type'	   	},

	[3]  =  { { 'switch', 0x0A, 1},									},

	[4]  =  { { 'case', 0x03 },	     								},
	[5]  =  { { 'call', 0xFFE }, 							   		},
	[6]  =  { {}, {12}, 'rword',   'spell',     'Spell ID'			},
	[7]  =  { { 'break' },          								},

	[8]  =  {  { 'case', 0x1A },	     							},
	[9]  =	{  {}, {0x1A},  'byte',   'raw',     'Mode (Mounts)'    },
	[10] =	{  {}, {0x0C},  'rword',   'raw',    'Type',  {},  7 	},
	[11] =  {  { 'break' },          								},

	[12] =  { { 'case', 0x00 },	     								},	--	Deliberate drop through
	[13] =  { { 'case', 0x02 },	     								},
	[14] =  { { 'case', 0x05 },	     								},
	[15] =  { { 'case', 0x0C },	     								},
	[16] =  { { 'case', 0x0D },	     								},
	[17] =  { { 'case', 0x0F },	     								},
	[18] =  { { 'case', 0x10 },	     								},
	[19] =  { { 'case', 0x13 },	     								},
	[20] =  { { 'case', 0x14 },	     								},
	[21] =  { { 'call', 0xFFE }, 							   		},
	[22] =  { { 'break' },          								},

	[23] =  { { 'case', 0x07 },	     								},
	[24] =  { { 'call', 0xFFE }, 							   		},
	[25] =  { {}, {12}, 'rword',   'wskill',     'WS ID'			},
	[26] =  { { 'break' },          								},

	[27] =  { { 'case', 0x09 },	     								},
	[28] =  { { 'call', 0xFFE }, 							   		},
	[29] =  { {}, {12}, 'rword',   'ability',    'JA ID',  {}, 2	},
	[30] =  { { 'break' },          								},

	[31] =  {  { 'end' },          									},

	},

--	Drop Item -----------------------------------------------------------------

[0x028] = {

	[1] =   {	{ 'call', 0xFFF }, 							    	},
	[2] =   {	{},  {4}, 'rdword',    	'raw',		'Item Count'	},
	[3] =   {	{},  {8}, 'byte',     	'store',	'Container'		},
	[4] =   {	{},  {8}, 'byte',     	'raw',   	'Item Index'	},

	},	--	[[ COMPLETE ]]

--	Move Item -----------------------------------------------------------------

[0x029] = {

	[1] =   {	{ 'call', 0xFFF }, 							    		},
	[2] =   {	{},  {4},  'rdword',   	'raw',		'Item Count'		},
	[3] =   {	{},  {8},  'byte',     	'store',	'Src Container'		},
	[4] =   {	{},  {10}, 'byte',     	'raw',   	'Src Index'			},
	[5] =   {	{},  {9},  'byte',     	'store',	'Dst Container'		},
	[6] =   {	{},  {11}, 'byte',     	'raw',   	'Dst Index'			},

	},	--	[[ COMPLETE ]]

--	Item Search ---------------------------------------------------------------

[0x02C] = {

	[1] =   {	{ 'call', 0xFFF }, 							    	},
	[2] =   {	{},  {4}, 'byte',    	'raw',		'Language'		},
	[3] =   {	{},  {8}, 'byte',     	'string',  	'Name'			},

	},	--	[[ COMPLETE ]]

--	Offer Trade ---------------------------------------------------------------

[0x032] = {

	[1] =   {	{ 'call', 0xFFF }, 							    	},
	[2] =   {	{},  {4}, 'rdword',    	'raw',		'Unique No'		},
	[3] =   {	{},  {8}, 'rword',    	'eid',		'Actor ID'		},

	},	--	[[ COMPLETE ]]

--	Trade Tell ----------------------------------------------------------------

[0x033] = {

	[1] =   {	{ 'call', 0xFFF }, 							    	},
	[2] =   {	{},  {4}, 'rdword',    	'raw',		'Trade Type'	},
	[3] =   {	{},  {8}, 'rword',    	'raw',		'Counter'		},

	},	--	[[ COMPLETE ]]

--	Trade Item ----------------------------------------------------------------

[0x034] = {

	[1] =   {	{ 'call', 0xFFF }, 							    	},
	[2] =   {	{},  {4}, 'rdword',    	'raw',		'Item Count'	},
	[3] =   {	{},  {8}, 'rword',    	'item',		'Item ID'		},
	[4] =   {	{},  {10},'byte',    	'raw',		'Inv Index'		},
	[5] =   {	{},  {11}, 'byte',    	'raw',		'Trade Slot'	},

	},	--	[[ COMPLETE ]]

--	Menu Item ----------------------------------------------------------------

[0x036] = {

	[1]  = { { 'call', 0xFFF }, 							    },
	[2]  = { {},  {4}, 'rdword',	'entity',	'NPC Name'		},
	[3]  = { {}, {58}, 'rword',		'eid',		'Actor Index'	},
	[4]  = { {}, {60}, 'byte',		'raw',		'Active Slots'	},

	[5]  = { { 'loop', 10, -1, 0 },                        					},
	[6]  = { { 'ifnot', 0, 2 }, {8},  	'rdword',	'raw',  'Item Count' 	},
	[7]  = { { }, {48}, 				'byte', 	'raw',	'Item Index' 	},
	[8]  = { { 'end' },                                   					},

	},	--	[[ COMPLETE ]]

--	Use Item ------------------------------------------------------------------

[0x037] = {

	[1] =   { { 'call', 0xFFF }, 							    		},
	[2] =   { {},  {4},  'rdword',    	'raw',		'Unique ID'			},
	[3] =   { {},  {8},  'rdword',    	'item',		'Item Count'		},
	[4] =   { {},  {12}, 'rword',		'eid',		'Actor Index'		},
	[5] =   { {},  {16}, 'rword',		'store',	'Container'			},
	[6] =   { {},  {14}, 'byte',		'raw',		'Item Index'		},

	},	--	[[ COMPLETE ]]

--	Sort Item -----------------------------------------------------------------

[0x03A] = {

	[1] =   { { 'call', 0xFFF }, 							    		},
	[2] =   { {},  {4}, 'rword',		'store',	'Container'			},

	},	--	[[ COMPLETE ]]

--	Blacklist -----------------------------------------------------------------

[0x03D] = {

	[1] =   { { 'call', 0xFFF }, 							    		},
	[2] =   { {}, {4}, 'rword',		'player',	'ID'					},
	[3] =   { {}, {8}, 'byte',		'string',	'Player Name'			},
	[4] =   { {}, {24},'byte',		'raw',		'Mode'					},

	},	--	[[ COMPLETE ]]

--	Lot Item ------------------------------------------------------------------

[0x041] = {

	[1] =   { { 'call', 0xFFF }, 							    		},
	[2] =   { {},  {4}, 'byte',		'raw',		'Trophy Index'			},
	[3] =   { {},  {5}, 'byte',		'raw',		'Inv Index'				},

	},	--	[[ COMPLETE ]]

--	Pass Item -----------------------------------------------------------------

[0x042] = {

	[1] =   { { 'call', 0xFFF }, 							    		},
	[2] =   { {},  {4}, 'byte',		'raw',		'Trophy Index'			},

	},	--	[[ COMPLETE ]]

--	Servmes -------------------------------------------------------------------

[0x04B] = {

	[1] =   { { 'call', 0xFFF }, 							    		},
	[2] =   { {},  {4},  'byte',	'raw',		'Command'				},
	[3] =   { {},  {5},  'byte',	'raw',		'Result'				},
	[4] =   { {},  {6},  'byte',	'raw',		'Frag No'				},
	[5] =   { {},  {7},  'byte',	'raw',		'Frag Total'			},
	[6] =   { {},  {8},  'rdword',	'time',		'Timestamp'				},
	[7] =   { {},  {12}, 'rdword',	'raw',		'Total Size'			},
	[8] =   { {},  {16}, 'rdword',	'raw',		'Offset'				},
	[9] =   { {},  {20}, 'rdword',	'raw',		'Data Size'				},

	},	--	[[ COMPLETE ]]

--	Delivery Box --------------------------------------------------------------

[0x04D] = {

	[1]  = { { 'call', 0xFFF }, 							    		},
	[2]  = { {},  {4},  'byte',		'dbox',		'Command'				},
	[3]  = { {},  {5},  'byte',		'raw',		'Box No'				},
	[4]  = { {},  {6},  'byte',		'raw',		'Post Work No'			},
	[5]  = { {},  {7},  'byte',		'raw',		'Item Work No'			},
	[6]  = { {},  {8},  'rdword',	'raw',		'Item Stacks'			},
	[7]  = { {},  {12}, 'byte',		'raw',		'Result'				},
	[8]  = { {},  {13}, 'byte',		'raw',		'Param 1'				},
	[9]  = { {},  {14}, 'byte',		'raw',		'Param 2'				},
	[10] = { {},  {15}, 'byte',		'raw',		'Param 3'				},
	[11] = { {},  {16}, 'byte',		'string',	'Target Name'			},

	},	--	[[ COMPLETE ]]

--	Auction -------------------------------------------------------------------

[0x04E] = {

	[1]  = { { 'call', 0xFFF }, 							    	},
	[2]  = { {},  {4},  'byte',		'raw',		'Command'			},
	[3]  = { {},  {5},  'byte',		'raw',		'AucWorkIndex'		},
	[4]  = { {},  {6},  'byte',		'raw',		'Result'			},
	[5]  = { {},  {7},  'byte',		'raw',		'ResultStatus'		},

	[6]  = { { 'switch', 4, 1},										},

	[7]  = { { 'case', 4 },	     									},
	[8]  = { {}, {-1},	'byte',   	'info',    	'MODE 4', {},  	0,	'Before sale confirmation' },
	[9]  = { {}, {8},   'rdword',	'raw',		'Asking Price'		},
	[10] = { {}, {12},  'rword',	'raw',		'Inv Location'		},
	[11] = { {}, {14},  'rword',	'item',		'ItemNo'			},
	[12] = { {}, {16},  'rdword',	'raw',		'Stack Flag'		},
	[13] = { { 'break' },          									},

	[14] = { { 'case', 5 },	     									},
	[15] = { {}, {-1},	'byte',   	'info',    	'MODE 5', {},  	0,	'When opening the sales status window' },
	[16] = { {}, {-1},	'byte',   	'info',    	'', 	  {},  	0,	'No other data in this packet' },
	[17] = { { 'break' },          									},

	[18] = { { 'case', 0x0A },	     									},
	[19] = { {}, {-1},	'byte',   	'info',    	'MODE A', {},  	0,	'When opening the auction house' },
	[20] = { {}, {-1},	'byte',   	'info',    	'', 	  {},  	0,	'No other data in this packet' },
	[21] = { { 'break' },          									},

	[22] = { { 'case', 0x0B },	     									},
	[23] = { {}, {-1},	'byte',   	'info',    	'MODE B', {},  	0,	'After sale confirmation' },
	[24] = { {}, {8},   'rdword',	'raw',		'Selling Price'		},
	[25] = { {}, {12},  'rword',	'raw',		'Inv Location'		},
	[26] = { {}, {16},  'rdword',	'raw',		'Stack Flag'		},
	[27] = { { 'break' },          									},

	[28] = { { 'case', 0x0C },	     									},
	[29] = { {}, {-1},	'byte',   	'info',    	'MODE C', {},  	0,	'Cancelling an item sale' },
	[30] = { {}, {-1},	'byte',   	'info',    	'', 	  {},  	0,	'No other data in this packet' },
	[31] = { { 'break' },          									},

	[32] = { { 'case', 0x0D },	     									},
	[33] = { {}, {-1},	'byte',   	'info',    	'MODE D', {},  	0,	'Item sale status request' },
	[34] = { {}, {-1},	'byte',   	'info',    	'', 	  {},  	0,	'No other data in this packet' },
	[35] = { { 'break' },          									},

	[36] = { { 'case', 0x0E },	     									},
	[37] = { {}, {-1},	'byte',   	'info',    	'MODE E', {},  	0,	'Bidding on an item' },
	[38] = { {}, {8},   'rdword',	'raw',		'Bid Price'			},
	[39] = { {}, {12},  'rword',	'item',		'Item ID'			},
	[40] = { {}, {16},  'rdword',	'raw',		'Stack Flag'		},
	[41] = { { 'break' },          									},

	[42] = { { 'end' },          										},

	},	--	[[ COMPLETE ]]
	
--	Speach --------------------------------------------------------------------

[0x0B5] = {

	[1]  =  {  { 'call', 0xFFF }, 									},
	[2]  =	{  {}, {6},       'byte',     'string',  'Command'  	},

	},	--	[[ COMPLETE ]]

}

return NewRules
