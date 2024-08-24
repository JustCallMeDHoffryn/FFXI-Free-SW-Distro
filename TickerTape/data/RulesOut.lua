local AllRulesIn = {

--	NPC Update
	
	[0x015] = T	{			--		Offset	bit		Name		format		logic		flag		decode		Info
					[1]		=	{	0,		0,	 	'ID',		'byte',		'none',		0,			'raw',		''},
					[2]		=	{	2,		0,	 	'Sync',		'rword',	'none',		0,			'raw',		''},
					[3]		=	{	4,		0,	 	'Position',	'special',	'none',		0,			'xyz',		''},
				},
	}

return AllRulesIn
