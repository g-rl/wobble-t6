#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\mp\utility;
#include scripts\mp\menu\_menuutils;
#include scripts\mp\menu\_structure;
#include scripts\mp\menu\_overflow;

menu_buttons()
{
    self endon("disconnect");

    for(;;)
    {
        if (!self.menu.isopen)
        {
            if (self sprintbuttonpressed() && self meleeButtonPressed())
            {
                self.menu.isopen = true;
                self load_menu("wobble");
                self.watermark destroy();
                wait 0.25;
            }
        }
        else
        {
            if (self ActionSlotOneButtonPressed())
            {
                self.menu.scroll--;
                self UpdateScroll();
            }

            if (self ActionSlotTwoButtonPressed())
            {
                self.menu.scroll++;
                self UpdateScroll();
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "slider")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                value = Float(self get_pers(pers));

                value -= self.menu.amount[self.menu.current][self.menu.scroll];
                if (value < self.menu.min[self.menu.current][self.menu.scroll])
                    value = self.menu.max[self.menu.current][self.menu.scroll];

                self set_pers(pers, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "slider")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                value = Float(self get_pers(pers));

                value += self.menu.amount[self.menu.current][self.menu.scroll];
                if (value > self.menu.max[self.menu.current][self.menu.scroll])
                    value = self.menu.min[self.menu.current][self.menu.scroll];

                self set_pers(pers, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "dvar")
            {
                dvar = self.menu.dvar[self.menu.current][self.menu.scroll];
                value = GetDvarFloat(dvar);

                value -= self.menu.amount[self.menu.current][self.menu.scroll];
                if (value < self.menu.min[self.menu.current][self.menu.scroll])
                    value = self.menu.max[self.menu.current][self.menu.scroll];

                SetDvar(dvar, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], GetDvarFloat(dvar));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "dvar")
            {
                dvar = self.menu.dvar[self.menu.current][self.menu.scroll];
                value = GetDvarFloat(dvar);

                value += self.menu.amount[self.menu.current][self.menu.scroll];
                if (value > self.menu.max[self.menu.current][self.menu.scroll])
                    value = self.menu.min[self.menu.current][self.menu.scroll];

                SetDvar(dvar, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], GetDvarFloat(dvar));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "array")
            {
                array = self.menu.array[self.menu.current][self.menu.scroll];
                arrayname = self.menu.arrayname[self.menu.current][self.menu.scroll];
                index = Int(self get_pers("arrayindex_" + arrayname));

                index--;
                if (index < 0)
                    index = array.size - 1;

                self set_pers("arrayindex_" + arrayname, index);

                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "array")
            {
                array = self.menu.array[self.menu.current][self.menu.scroll];
                arrayname = self.menu.arrayname[self.menu.current][self.menu.scroll];
                index = Int(self get_pers("arrayindex_" + arrayname));

                index++;
                if (index >= array.size)
                    index = 0;

                self set_pers("arrayindex_" + arrayname, index);

                self load_menu(self.menu.current);
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "bind")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                self notify("stop" + pers);

                switch(self get_pers(pers))
                {
                case "^1OFF^7":
                    self set_pers(pers,"+actionslot 1");
                    break;
                case "+actionslot 1":
                    self set_pers(pers,"+actionslot 2");
                    break;
                case "+actionslot 2":
                    self set_pers(pers,"+actionslot 3");
                    break;
                case "+actionslot 3":
                    self set_pers(pers,"+actionslot 4");
                    break;
                case "+actionslot 4":
                    self set_pers(pers,"+smoke");
                    break;
                case "+smoke":
                    self set_pers(pers,"+frag");
                    break;
                case "+frag":
                    self set_pers(pers,"+melee");
                    break;
                case "+melee":
                    self set_pers(pers,"+stance");
                    break;
                case "+stance":
                    self set_pers(pers,"+switchseat");
                    break;
                case "+switchseat":
                    self set_pers(pers,"+gostand");
                    break;
                case "+gostand":
                    self set_pers(pers,"+usereload");
                    break;
                case "+usereload":
                    self set_pers(pers,"^1OFF^7");
                    break;
                }


                if (self get_pers(pers) != "^1OFF^7")
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers), pers);
                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "bind")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                self notify("stop" + pers);

                switch(self get_pers(pers))
                {
                case "^1OFF^7":
                    self set_pers(pers,"+actionslot 1");
                    break;
                case "+actionslot 1":
                    self set_pers(pers,"+actionslot 2");
                    break;
                case "+actionslot 2":
                    self set_pers(pers,"+actionslot 3");
                    break;
                case "+actionslot 3":
                    self set_pers(pers,"+actionslot 4");
                    break;
                case "+actionslot 4":
                    self set_pers(pers,"+smoke");
                    break;
                case "+smoke":
                    self set_pers(pers,"+frag");
                    break;
                case "+frag":
                    self set_pers(pers,"+melee");
                    break;
                case "+melee":
                    self set_pers(pers,"+stance");
                    break;
                case "+stance":
                    self set_pers(pers,"+switchseat");
                    break;
                case "+switchseat":
                    self set_pers(pers,"+gostand");
                    break;
                case "+gostand":
                    self set_pers(pers,"+usereload");
                    break;
                case "+usereload":
                    self set_pers(pers,"^1OFF^7");
                    break;
                }


                if (self get_pers(pers) != "^1OFF^7")
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers), pers);
                self load_menu(self.menu.current);
            }

            if (self UseButtonPressed())
            {
                if (self.menu.slidertype[self.menu.current][self.menu.scroll] == "none")
                {
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll],self.menu.input[self.menu.current][self.menu.scroll],self.menu.input2[self.menu.current][self.menu.scroll]);
                    self load_menu(self.menu.current);
                }
                else if (self.menu.slidertype[self.menu.current][self.menu.scroll] == "array")
                {
                    arrayname = self.menu.arrayname[self.menu.current][self.menu.scroll];
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll],level.arrayscrolls[arrayname][Int(self get_pers("arrayindex_" + arrayname))]);
                    self load_menu(self.menu.current);
                }
                wait 0.3;
            }

            if (self MeleeButtonPressed())
            {
                if (self.menu.parent[self.menu.current] == "exit")
                {
                    self DestroyMenuHud();
                    self.menu.isopen = false;
                    self thread wobble_watermark();
                }
                else
                {
                    self load_menu(self.menu.parent[self.menu.current]);
                }
                wait 0.2;
            }
        }
        wait 0.05;
    }
}

// this function is messy but idc for now -mikey
UpdateScroll()
{
    if (isdefined(self.menu.smoothscroll) && self.menu.smoothscroll)
        self.hud["scroll"] MoveOverTime(0.1);

    if (self.menu.scroll < 0)
        self.menu.scroll = self.menu.text[self.menu.current].size - 1;

    if (self.menu.scroll > self.menu.text[self.menu.current].size - 1)
        self.menu.scroll = 0;

    if (!isdefined(self.menu.text[self.menu.current][self.menu.scroll - 4]) || self.menu.text[self.menu.current].size <= 8)
    {
        for (i = 0; i < 8; i++)
        {
            if (isdefined(self.menu.text[self.menu.current][i] ))
                self.hud["text"][i] set_safe_text(self, self.menu.text[self.menu.current][i]);
            else
                self.hud["text"][i] set_safe_text(self, "");

            if (isdefined(self.menu.bool[self.menu.current][i]))
                self.hud["bool_text"][i] set_safe_text(self, self.menu.bool[self.menu.current][i]);
            else
                self.hud["bool_text"][i] set_safe_text(self, "");
        }

        self.hud["scroll"].y = -63 + (16 * self.menu.scroll);
    }
    else if (isdefined(self.menu.text[self.menu.current][self.menu.scroll + 4]))
    {
        index = 0;

        for (i = self.menu.scroll - 4; i < self.menu.scroll + 4; i++)
        {
            if (isdefined(self.menu.text[self.menu.current][i]))
                self.hud["text"][index] set_safe_text(self, self.menu.text[self.menu.current][i]);
            else
                self.hud["text"][index] set_safe_text(self, "");

            if (isdefined(self.menu.bool[self.menu.current][i]))
                self.hud["bool_text"][index] set_safe_text(self, self.menu.bool[self.menu.current][i]);
            else
                self.hud["bool_text"][i] set_safe_text(self, "");

            index++;
        }


        self.hud["scroll"].y = -63 + (16 * 4);
    }
    else
    {
        for (i = 0; i < 8; i++)
        {
            self.hud["text"][i] set_safe_text(self, self.menu.text[self.menu.current][self.menu.text[self.menu.current].size + i - 8]);
            self.hud["bool_text"][i] set_safe_text(self, self.menu.bool[self.menu.current][self.menu.bool[self.menu.current].size + i - 8]);
        }

        self.hud["scroll"].y = -63 + (16 * (self.menu.scroll - self.menu.text[self.menu.current].size + 8));
    }

    self.hud["title"] set_safe_text(self, self.menu.current + " - " + (self.menu.scroll + 1) + "/" + self.menu.text[self.menu.current].size + "");
}
