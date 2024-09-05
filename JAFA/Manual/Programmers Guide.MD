## JAFA

### Programmers' Guide
**Ver 1.0**

JAFA is an addon for Ashita v4. The purpose of this addon is to show how to build a basic addon and make use of imgui to display game information.
##
### A Brief Introduction to IMGUI

![JAFA-001](JAFA-001.png)

With Ashita v4, just about everything you might want to draw with your addon can be done using the **imgui** library. The library can be called from a variety of languages and Ashita v4 has hooks to allow it to be called from lua. It is important to note that not all features are available, imgui has moved on and the lua hooks have not kept up. You may find a useful feature in the imgui library, but when you try to call it the function pointer is nil, tripping the addon to a stop. Buyer beware.

### It's All About Cycles

The main hook used by an addon for display purposes is the **'d3d_present'** callback. The game will render a frame, and, when it is finished, all of the addons will be called in turn so that they can draw over the top.

The key fact here is that there is no video memory. At the start of each cycle you will start with what is essentially a blank canvas. To make matters worse you can only paint with d3d primitives, fortunately imgui provides functions that act as an interface between your lua code and the low level d3d library.

You can have as many windows as you want, or none at all. Displaying lists of information, however, does lend itself to the window type display structure, just ask Microsoft. You just need to remember, you are NOT creating a window, you are painting something that looks and acts like a window, every single frame. If you want a child panel, draw one, but remember to paint your windows starting at the lowest level and building child objects upwards (on top) of what you have already drawn. Fortunately the imgui commands make that the natural way to work.

Speaking of Microsoft, the windows you can paint have a lot in common with some of the standard Windows types, and where there is a similarity or a significant difference that you should be aware of I have identified it 📌 for your attention.
##
### A Brief Introduction to JAFA

JAFA doesn't really do anything, but hopefully it will help clarify how to build an addon and how to make use of imgui. To make this easier to follow you will find a folder called **Versions**. The version of JAFA in the base folder is the absolute basic addon that was used to make the **"Hello Vana'diel"** picture above, and I will explain the key parts of it in Chapter 1, but each subsequent chapter will add new features to the code that will be explained in detail. The code for that chapter will be found in a sub folder with the chapter name.
##
### Chapter One - The Basics

To paint an empty window with imgui you only need the following commands ...

```	
if (imgui.Begin('JAFA')) then
    imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('Hello Vana\'diel') )
    imgui.End()
end
```

Technically, you don't need the second line, but I've left that in so that I can explain a few things about it.

The Begin command creates a window. **EVERYTHING** about a window object in imgui has a default setting, and all of them can be changed. Settings are changed before the act, you push the new default for a setting, create your object, and, when you've finished with it, you pop the default, restoring the previous default. 

If you have, for example, three windows and you want them all to look the same, you pop the styles and colours **AFTER** the last window has been rendered.

This expands our code to the following ...

```
  imgui.PushStyleColor(ImGuiCol_WindowBg,         {0, 0.25, 0.50, .75})
  imgui.PushStyleColor(ImGuiCol_TitleBg,          {0, 0.05, 0.10, .7})
  imgui.PushStyleColor(ImGuiCol_TitleBgActive,    {0, 0.15, 0.25, .9})
  imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
  imgui.PushStyleColor(ImGuiCol_Text,             {0, 0.90, 0.90, 0.90})

  if (imgui.Begin('JAFA')) then
      imgui.Text('Hello Vana\'diel')
      imgui.End()
  end

  imgui.PopStyleColor(5)
```

Each of the 5 lines at the top sets the default colour for an aspect of the window. There are dozens of them and I don't intend to list them all, they can be found in the **imgui.lua** file in the **addons/libs** folder. The purpose of the ones I've included should be obvious.

You will see that I have used ...
```
  imgui.PopStyleColor(5)
```
You can pop a single item with ...
```
  imgui.PopStyleColor()
```
The design concept is to leave everything as you found it, i.e. empty the stacks (there are several) before you leave. I would hope, though I cannot prove, that imgui would manage any items you leave on the stack when you exit your function.

I have discovered that if you push 5 items and pop 6 items it will go bang, killing both your addon and **ALL** other addons currently running. **DON'T DO THIS**.
##
#### RGBA

You will have noticed that, by adding a default colour for text I was able to swap out the **TextColored** for a simpler **Text** that made use of the previously defined colour.

Colour in imgui consists of 4 values from 0 ~ 1 in a table ...

```
  {
    0.00,   0 red
    0.25,   25% green
    0.50,   50% blue
    0.75    75% alpha (transparency)
  }
```
A window or object with 0 alpha is invisible and an of alpha of 1 makes it fully opaque. This allows you to easily set the transparency of your addon such that the information can be seen without obscuring too much of the actual game.
##
#### Basic Window Functions

📌 The window created above has some basic functions that differ from a MS Windows window. 

- The window can be moved by clicking anywhere inside the window that is not an active widget (such as a button).
###
- The window can be collapsed (see the triangle icon at the top left)
###
- When a window is closed (see the X in the to right) it is not destroyed, it doesn't exist as such, this just hides the window (I will explain how below).


When a window is collapsed it is good practice to use a reduced level alpha, this allows the player to "store" the addon at the edge of the screen without having to unload it.
###
&nbsp;&nbsp;&nbsp;&nbsp;![JAFA-002](JAFA-002.png)
##
#### Begin Parameters

In its simplest form the Begin function takes a single parameter, a string to identify the window. You can add up to two more, first is the shown state flag ...
```
if (imgui.Begin('JAFA', UIF.is_open)) then
```
the **is_open** variable is defined as a table near the top of the uif.lua file ...
```
local UIF = {
    is_open  = { true, },
    settings = settings.load(defaults),
}
```
If the user closes the window (using the X in the top right of the window) imgui sets the variable to the new state of the window, i.e. closed.

The first line in the render function ...
```
  if (not UIF.is_open[1]) then return end
```
prevents the window from being drawn when the variable is set to false. The window hasn't been destroyed, it never existed (this cycle), but we remember it fondly.

Luckily we have a way out ...
```
  if (args[1] == '/jafa') then
      UIF.is_open[1] = not UIF.is_open[1]
      UIF.SaveState(UIF.is_open[1])
  end
```
These lines are called when the /jafa command is typed on the chat line. This will toggle the variable back on, and, the next render cycle will draw it once more. The show state is put into the settings and saved for next run, but that will be covered in a later chapter.

If you have been looking at the definition for **Begin** you will have notice that there are additional parameters that can be used. Don't worry, these are covered in a later chapter.


