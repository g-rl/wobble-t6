#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_weapons;
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_hud;

AddString(string)
{
    level.strings = string;
    level notify("string_added");
}

FixString() 
{
    self notify("new_string");
    self endon("new_string");
    while(isDefined(self)) 
    {
        level waittill("overflow_fixed");
        self set_safe_text(self.string);
    }
}


overflow_fix_init() 
{
    level.strings = [];
    level.overflowElem = createServerFontString("default", 1.5);
    level.overflowElem set_safe_text("overflow");
    level.overflowElem.alpha = 0;
    level thread overflowFixMonitor();
}

OverflowFixMonitor() 
{
    for(;;) 
    {
        level waittill("string_added");
        if(level.strings >= 45) 
        {
            level.overflowElem clearAllTextAfterHudElem();
            level.strings = [];
            level notify("overflow_fixed");
        }
        wait 0.05;
    }
}

set_safe_text(text)
{
    self.string = text;
    self setText(text);
    self thread fixString();
    self addString(text);
}

OverflowFix()
{
	level.test = createServerFontString("default",1.5);
	level.test setText("xTUL");
	level.test.alpha = 0;

	for(;;)
	{
		level waittill("textset");
		if(level.result >= 50)
		{
			level.test ClearAllTextAfterHudElem();
			level.result = 0;
		}
		wait .1;
	}
}

Clear(player)
{
        if(self.type == "text")
                player deleteTextTableEntry(self.textTableIndex);
               
        self destroy();
}

DeleteTextTableEntry(id)
{
        foreach(entry in self.textTable)
        {
                if(entry.id == id)
                {
                        entry.id = -1;
                        entry.stringId = -1;
                }
        }
}