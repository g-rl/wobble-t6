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
    self AddOption("apathy", "player settings", ::LoadMenu, undefined, "settings");
    self AddOption("apathy", "binds", ::LoadMenu, undefined, "binds");

    self CreateMenu("settings", "apathy");
    self AddOption("settings", "mw3 grenades", ::special_nades);
    self AddOption("settings", "drop weapon", ::drop_weapon);

    self CreateMenu("binds", "apathy");
    self AddOption("binds", "void", ::void);
}