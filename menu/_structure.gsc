#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\mp\menu\_menuutils;
#include scripts\mp\utility;
#include scripts\mp\functions;

structure() 
{
    // AddSlider(menu, text, func, pers, min, max, amount)
    // AddDvarSlider(menu, text, func, dvar, min, max, amount)

    self CreateMenu("wobble", "exit");
    self AddOption("wobble", "settings", ::LoadMenu, undefined, "settings");
    self AddOption("wobble", "position", ::LoadMenu, undefined, "position");
    // self AddOption("wobble", "binds", ::LoadMenu, undefined, "binds");

    self CreateMenu("settings", "wobble");
    self AddArraySlider("settings", "drop canswap", ::drop_canswap, list("smg,ar,lmg,shotgun,sniper,pistol,misc"), "canswap_slider");
    self AddSlider("settings", "always canswap", ::toggle_canswap, "always_canswap");
    self AddSlider("settings", "lb semtex", ::toggle_semtex, "lb_semtex");
    self AddSlider("settings", "auto prone", ::toggle_auto_prone, "auto_prone");
    self AddOption("settings", "mw3 grenades", ::special_nades);
    self AddOption("settings", "drop weapon", ::drop_weapon);
    self AddOption("settings", "give streaks", ::give_streaks);
    self AddOption("settings", "reset rounds", ::reset_rounds);

    self CreateMenu("position", "wobble");
    self AddOption("position", "set spawnpoint", ::set_spawnpoint);
    self AddOption("position", "teleport enemies", ::teleport_enemy);

    // self CreateMenu("binds", "wobble");
    // self AddOption("binds", "void", ::void);
}