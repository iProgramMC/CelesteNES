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

## Development Builds

TBA

## Credits

- iProgramInCpp - Lead developer

- Zeta0134 - "First Steps" cover

- Livvy94 - "Resurrections" cover

- Buttersoap - Sound effects, initial "First Steps" cover

- The members of the [NESdev discord server](https://discord.gg/VFnWZV8GWk) for miscellaneous help

- [TFDSoft](https://twitter.com/TFDSoft) for support

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

This project is neither created nor endorsed by the Celeste team.

The *Celeste* IP is owned by [Maddy Makes Games, Inc.](https://maddymakesgames.com).

The *graphics* (all \*.chr files, except d_font.chr) and *music* (`src/level0/testmusic.asm`,
`src/level1/testmusic.asm`, and `src/level2/testmusic.asm`) are under a **strictly**
**non-commercial license**, meaning you **may not** use these assets for **any**
commercial purpose.

The game code (`src/`) is licensed under [the MIT license](src/license.txt)
