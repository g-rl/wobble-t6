#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\mp\utility;

setup_menu() 
{
    self.menu = SpawnStruct();
    self.menu.isopen = false;
    self.menu.smoothscroll = false;
    self.menu.color = [];
    self.menu.color["background"] = (0.05, 0.05, 0.05);
    self.menu.color["black"] = (0, 0, 0);
    self.menu.color["accent"] = (0, 0, 0);
    self.menu.color["scroll"] = (0.549, 0.58, 0.671);
    self.menu.color["white"] = (0.945, 0.945, 0.945);

    self thread scripts\mp\menu\_menulogic::menu_buttons();
    self thread apathy_watermark();
}

// fuck you plutonium
notifyonplayercmd( cmd, button )
{
    if(button == "+usereload"){if(self UseButtonPressed()){self notify(cmd);}}
    if(button == "+switchseat"){if(self ChangeSeatButtonPressed()){self notify(cmd);}}
    if(button == "+smoke"){if(self SecondaryOffHandButtonPressed()){self notify(cmd);}}
    if(button == "+frag"){if(self FragButtonPressed()){self notify(cmd);}}
    if(button == "+melee"){if(self MeleeButtonPressed()){self notify(cmd);}}
    if(button == "+stance"){if(self StanceButtonPressed()){self notify(cmd);}}
    if(button == "+gostand"){if(self JumpButtonPressed()){self notify(cmd);}}
    if(button == "+actionslot 1"){if(self ActionSlotOneButtonPressed()){self notify(cmd);}}
    if(button == "+actionslot 2"){if(self ActionSlotTwoButtonPressed()){self notify(cmd);}}
    if(button == "+actionslot 3"){if(self ActionSlotThreeButtonPressed()){self notify(cmd);}}
    if(button == "+actionslot 4"){if(self ActionSlotFourButtonPressed()){self notify(cmd);}}
}

create_notify()
{
    while(true)
    {
        self notifyonplayercmd("+actionslot 1","+actionslot 1");
        self notifyonplayercmd("+actionslot 2","+actionslot 2");
        self notifyonplayercmd("+actionslot 3","+actionslot 3");
        self notifyonplayercmd("+actionslot 4","+actionslot 4");
        self notifyonplayercmd("+frag","+frag");
        self notifyonplayercmd("+smoke","+smoke");
        self notifyonplayercmd("+usereload","+usereload");
        self notifyonplayercmd("+melee","+melee");
        self notifyonplayercmd("+gostand","+gostand");
        self notifyonplayercmd("+switchseat","+switchseat");
        self notifyonplayercmd("+stance","+stance");
        wait 0.05;
    }
}