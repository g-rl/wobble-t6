#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\mp\menu\_menuutils;
#include scripts\mp\utility;
#include scripts\mp\functions;

structure() 
{
    // AddSlider(menu, text, func, pers, min, max, amount)
    // AddDvarSlider(menu, text, func, dvar, min, max, amount)

    self CreateMenu("apathy", "exit");
    self AddOption("apathy", "settings", ::LoadMenu, undefined, "settings");
    self AddOption("apathy", "binds", ::LoadMenu, undefined, "binds");

    self CreateMenu("settings", "apathy");
    self AddArraySlider("settings", "drop canswap", ::drop_canswap, list("smg,ar,lmg,shotgun,sniper,pistol,misc"), "canswap_slider");
    self AddSlider("settings", "always canswap", ::toggle_canswap, "always_canswap");
    self AddSlider("settings", "lb semtex", ::toggle_semtex, "lb_semtex");
    self AddOption("settings", "mw3 grenades", ::special_nades);
    self AddOption("settings", "drop weapon", ::drop_weapon);
    self AddOption("settings", "reset rounds", ::reset_rounds);
    self AddOption("settings", "teleport enemies", ::teleport_enemy);

    self CreateMenu("binds", "apathy");
    self AddOption("binds", "void", ::void);
}