# Celeste NES

This is the source code to iProgramInCpp's attempt to recreate  *[Celeste](https://www.celestegame.com)*
for the Nintendo Entertainment System / Family Computer.

Currently this is a massive work in progress. This means that the game may be
either:
- buggy,
- unstable,
- or downright broken.

As of January 25th, 2025, only the first two chapters have been completed.

Development will happen in the `development` branch, and all pull requests will be pulled
into it. The `demo-1` branch will contain the source code for the demo as released on
January 25th, 2025.

## Discord Server

If you would like to chat about this game, you can do so in our Discord server: https://discord.gg/JWSUpfCubz

## Development Builds

TBA

## Credits

- iProgramInCpp - Lead developer

- [livvy94](https://youtube.com/@livvy94) - "Resurrections" rendition

- [zeta0134](https://github.com/zeta0134) - "First Steps" rendition

- [Persune](https://gumball2415.github.io) - Chapter Complete rendition

- [Buttersoap](https://www.youtube.com/@iputsoapondabutter) - Sound effects, and first "First Steps" rendition

- The members of the [NESdev discord server](https://discord.gg/VFnWZV8GWk) for miscellaneous help

- [TFDSoft](https://twitter.com/TFDSoft) for support, and also the nightly build workflow

- [Extremely OK Games](https://exok.com) for creating the wonderful game of [Celeste](https://www.celestegame.com)

- And you, for playing!

## Building

To build you will need the `cc65` toolchain installed (`ca65` and `ld65` are used), as well as a posix-compliant
`make` implementation.

Run the `make` command to build the ROM for the game.

### Warning

Certain package managers (Ubuntu, for example) will feature outdated builds of ca65 (`ca65 V2.18 - Ubuntu 2.19-1`
for example)  Unfortunately, it doesn't support all the features that this code base uses.

You will need to get a more up to date version. Compiling from source will work.

## Code Quality Warning

Because this is my first project written in 6502 assembly, code quality will vary. If you spot
anything unusual, let me know and I will fix it right up!

## Physics

I have tried my best to make the physics as accurate to the original game as I could, even referencing
the officially released [https://github.com/NoelFB/Celeste/blob/master/Source/Player/Player.cs](Player class code)
from Celeste. However, some features may not be accurately implemented.

If you know how to write 6502 assembly and also happen to be a keen-eyed player who can notice such
things, **please let me know** with a pull request.

It is important to also acknowledge the NES' limitations. I think I've struck a good balance between
accuracy and speed.

## License

This project has been neither created nor endorsed by the Celeste team.

The *Celeste* IP is owned by [Maddy Makes Games, Inc.](https://maddymakesgames.com).

The *graphics* (all \*.chr files, except d_font.chr) and *music* (`src/level0/music`,
`src/level1/music`, and `src/level2/music`) are under a **strictly non-commercial license**,
meaning you **may not** use these assets for **any** commercial purpose.

The game code (`src/`) is licensed under [the MIT license](license.txt)
