#include maps\mp\_utility;
#include common_scripts\utility;

// custom script includes
#include scripts\mp\functions;
#include scripts\mp\utility;
#include scripts\mp\menu\_menuutils;

setup_bind(pers, value, func, monitor, crouch) 
{
    self setpersifuni(pers, value);

    if (self get_pers(pers) != "^1off^7") 
    {
        if(isDefined(crouch))
        {
            self thread crouch_bind_monitor(self get_pers(pers), pers, func);
            return;
        }

        if(!isDefined(monitor))
        {
            self thread [[func]](self get_pers(pers), pers);
        } else {
            self thread bind_monitor(self get_pers(pers), pers, func);
        }
    }
}

bind_monitor(bind, endonstring, func) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu())
        {
            self thread [[func]]();
            waitframe();
        }
    }
}

crouch_bind_monitor(bind, endonstring, func) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu() && self StanceButtonPressed())
        {
            self thread [[func]]();
            waitframe();
        }
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