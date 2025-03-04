#include maps\mp\_utility;
#include common_scripts\utility;

// custom script includes
#include scripts\mp\functions;
#include scripts\mp\utility;
#include scripts\mp\menu\_menuutils;

setup_bind(pers, value, func) 
{
    self setpersifuni(pers, value);

    if (self get_pers(pers) != "^1off^7") 
    {
        self thread [[func]](self get_pers(pers), pers);
    }
}

random_class_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread random_class();
            waitframe();
        }
    }
}

flash_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread maps\mp\_flashgrenades::applyflash(1,1);
            waitframe();
        }
    }
}

change_class_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread change_class();
            waitframe();
        }
    }
}

change_class_5_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread change_class_5();
            waitframe();
        }
    }
}

refill_ammo_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if (!self in_menu() && self StanceButtonPressed()) 
        {
            self thread refill_ammo();
        }
    }
}

refill_eq_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);
            
        if (!self in_menu() && self StanceButtonPressed()) 
        {
            self thread refill_equipment();
        }
    }
}