ProcessingRoguelikeDemo
=======================

A simple proof of concept demo of a roguelike game made with Processing.

What?
=====

This is a simple (pre-alpha tech demo of some parts of a) game in which you run around in a room and kill guys who are trying to kill you. Rooms are randomly generated and various aspects of both the player and enemies' mechanics change randomly as well. Upon either dying or touching the red square (door?) you will spawn into a new room with new enemies and a new set of stats.

Why?
====

I have been a gamer for most of my life and have always enjoyed making games as a hobby. To date however, I have finished exactly zero games that I have started making. This is an ongoing project that I intend to do a massive overhaul on BUT I decided that this version is playable enough to be fun (for some I guess maybe). Hopefully this may also inspire others who, like me, have never "finished" a game they stated working on to do so.

How?
====

Magic! This was all programmed in Processing (as I've said). This is really a merging of a few different things I worked on at various points. So if you look at the code and think "hey, this looks really slapped together" then you're right and deserve a cookie! I'm open sourcing this not because it is an example of good code (it's not: don't write code like this ever (unless you are just screwing around like I was)), but to show that even the most hacky attempts at something can still be fun and a learning experience.

When?
=====

Right now!

Who?
====

Me (www.coleingraham.com)

Installation and Running
========================

This demo requires Processing (www.processing.org) v.2 or later. Once you have Processing installed, open the file called RoguelikeDemo.pde and press the run button. NOTE: this looks better in presentation mode (from the menu).

Controls
========

- W A S D: move up, left, down, right (if you've played games before this should make sense)
- 7 8 9 0: use your skills (they are listed in the top left of the screen)
- space: generate a new room (for if you really don't like the one you are in)
- 1: re-randomize your stats (because we all wish we had a button to change everything about ourselves)
- minus and equals : cycle through possible targets on the screen

Goal
====

There is no goal! Well... there is but there's no way to "win." Walk around and explore the room (they're all different!). The red square is the exit for when you feel like going to a new room (if you don't die first, mwahaha). Fight dudes  by spamming your skills (like any good realtime combat system).

FAQ
===

- Q: What's with the graphics?
- A: I was busy making the game, when would I have time for graphics?

- Q: I found a bug!
- A: That's not a question... If you find a bug, you have the source code: fix it! But seriously, for me this particular project is pretty much frozen so I'm not planning on fixing anything in it. Take it as it is: a really rough but kinda fun (hopefully) proof of concept. In the future I plan on making a more serious attempt at this but as of right now I don't have a time table in mind for that.

- Q: What are all of these .action and .combatActor files in the data folder?
- A: For the combat system, I was playing around with the idea of separating all the parts out into JSON files to allow easy modding. If you feel like adjusting the skills you can use in the game, or parts of the enemies, you can open those files in any text editor and tweak them (they should be pretty easy to figure out). This was partially inspired by how Starbound is put together but I haven't decided if I will keep that in the future.

- Q: Why is movement kinda wonky?
- A: I didn't feel like doing it "the right way." This is a cross between a tile based game and using pixel based movement and I was trying something funky to see if it worked and if I like it. In the end it's just kinda strange and I never got around to changing it. So it's not a bug, it's a feature of me not having the time to deal with it.
