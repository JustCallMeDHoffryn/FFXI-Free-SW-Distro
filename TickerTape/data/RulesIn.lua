local AllRulesIn = {

--	NPC Update
	
	[0x00E] = T	{			--		Offset	bit		Name		format		decode		Info
					[1]		=	{	0,		0,	 	'ID',		'byte',		'raw',		''},
					[2]		=	{	1,		0,	 	'Size',		'byte',		'raw',		''},
					[3]		=	{	2,		0,	 	'Sync',		'rword',	'raw',		''},
					[4]		=	{	4,		0,	 	'NPC',		'rdword',	'entity',	''},
					[5]		=	{	8,		0,	 	'Index',	'rword',	'raw',		''},
					[6]		=	{	10,		1,	 	'Flag',		'special',	'bool',		'[Position, Rotation, Walk]'	},
					[7]		=	{	12,		0,	 	'Position',	'special',	'xyz',		''},
					[8]		=	{	10,		2,	 	'Flag',		'special',	'bool',		'[Claimer ID]'	},
					[9]		=	{	10,		4,	 	'Flag',		'special',	'bool',		'[HP, Status]'	},
					[10]	=	{	10,		8,	 	'Flag',		'special',	'bool',		'[Name]'	},
				},
	}

return AllRulesIn
