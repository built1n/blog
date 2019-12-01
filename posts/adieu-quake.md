% Adieu, Quake!
%
% 27 Aug 2019

<center>
<figure>
[![Quake on Rockbox](https://img.youtube.com/vi/74i8aBOmyos/0.jpg){height=300}](https://www.youtube.com/watch?v=74i8aBOmyos)\ ![Quake on the iPod Classic.](quake.jpg){height=300}
<figcaption>Quake running on an iPod Classic.</figcaption>
</figure>
</center>

**TL;DR** I made Quake run on MP3 players. Read how it happened.

I spent part of this summer playing with two of my favorite things:
[Rockbox](https://www.rockbox.org) and id Software's
[Quake](https://en.wikipedia.org/wiki/Quake_(video_game)). I even got
the chance to combine the two by porting Quake to run *on* Rockbox!
What more could I ask?

This post is my story of how it went down. It is a protracted one,
dragging on for nearly two years. It is also my first attempt at
documenting the development proess in long form and "in the raw," as
opposed to the finished technical documentation I've written way too
much of -- do bear with me. There will be technical details, but I
will try to focus on the thought process behind the code.

Alas, the time has come to bid Rockbox and Quake goodbye, at least for
the near term. My free time will be preciously scarce in the coming
months, so I'm trying to get this brain dump in before the deluge.

## Rockbox

[Rockbox](https://www.rockbox.org) is a fun open-source project I spend
far too much time hacking on. The web page explains it best: "Rockbox
is a free replacement firmware for digital music players." That's
right, we provide a complete replacement for the manufacturer's
software that came on your Sandisk Sansa, Apple iPod, or any of a wide
array of other supported targets.

Not only do we aim to replicate the original firmware's functionality,
we support loadable extensions called *plugins* -- small programs to
run on your MP3 player. Rockbox already has a bunch of nifty games and
demos, the most impressive of which were probably the first-person
shooters [Doom](https://www.rockbox.org/wiki/PluginDoom) and [Duke
Nukem 3D](https://www.rockbox.org/wiki/PluginDuke3D).[^1] But I still
felt there was something missing.

## Enter Quake

Quake is a fully 3D first-person shooter. Let's break that down. They
key words there are *fully 3D*, as opposed to Doom and Duke Nukem 3D,
both of which are usually considered *2.5D* -- imagine a 2D map with
an additional height component. Quake, on the other hand, is fully
3D. Every vertex and polygon exists in 3-space. What this means is
that the old pseudo-3D tricks no longer work -- everything is now
full-blown 3D. Anyhow, I digress. In short, Quake is the Real Deal™.

Quake is no joke, either. Some research showed that Quake "requires" a
~100 MHz x86 with a FPU and ~32 MB of RAM. Before you chuckle, keep in
mind that Rockbox's targets are probably nothing close to what John
Carmack had in mind when writing the game -- Rockbox runs on devices
with CPUs as slow as 11MHz and as little as 2 MB of RAM (of course,
Quake wasn't going to be running on *those* devices). With this in
mind, I looked at my ever-shrinking DAP collection and picked out the
most powerful surviving member: an Apple iPod Classic/6G, with a 216
MHz ARMv5E and 64 MB of DRAM (the *E* indicates the presence of ARM
DSP extensions -- this will be important later). Nothing to sneeze at,
but certainly marginal when it comes to running Quake.

## The Port

There exists a wonderful version of Quake which runs on
[SDL](https://libsdl.org). It is called, unsurprisingly,
[SDLQuake](https://www.libsdl.org/projects/quake/). Thankfully, I
already ported the SDL library to Rockbox (that's for another
article), so getting Quake to compile was rather straightforward, if
not the most glorious work: copy over the source tree; `make`; fix
errors; rinse; repeat. I'm probably glossing over a lot of minutiae
here -- but just imagine my excitement when I eventually got a
successfully compiling and linking Quake executable. I was ecstatic.

*Let's load her up!* I thought.

And it booted! The beautiful Quake console background greeted me, as
did the menu. *All good*. But not so fast! When I started a game,
something wasn't right. The "Introduction" level seemed to load fine,
but the spawn position was completely outside the map. *Strange*, I
thought. I poked and prodded, debugged and `splashf`'d, but to no
avail -- the bug was too hard for me, or so it felt.

And so it remained, for years. I should probably give a little timing
information at this point. This first attempt at Quake took place in
September 2017, after which I gave up, and my Quake-Rockbox
abomination sat on a shelf, collecting dust, until July 2019. By just
the right combination of boredom and motivation, I resolved to finish
what I had started.

I got to debugging. Now, my flow state is such that I remember
virtually no details of what exactly I did, but I'll try my best here
to reconstruct.

As I discovered, the structure of Quake is divided into two main
parts: the engine code, in C; and the high-level game logic, in
QuakeC, a bytecode-compiled language. Now, I had always stayed away
from the QuakeC VM due to some weird fear of debugging other people's
code. But now it forced me to delve in. Here again I vaguely recall a
mad flow session in which I sought out the root of the bug. After what
must've been a whirlwind of `grep`s, I found my culprit:
`pr_cmds.c:PF_setorigin`. This function takes a 3-vector specifying
the player's new coordinates when starting a map, which, for some
reason, was always `(0, 0, 0)`. *Hmm...*

I traced the data flow back and found where it originated -- a call to
`Q_atof()` -- the classic string to float converter. And then it
dawned on me: I had provided a set of wrapper functions, which
overrode Quake's `Q_atof()` -- and my `atof()` function must've been
broken. Fixing it was straightforward. I
[replaced](https://git.rockbox.org/?p=rockbox.git;a=blobdiff;f=apps/plugins/sdl/wrappers.c;h=efa29ea7b852becf850e27f7e9d361e1862bf398;hp=ee512dd5737c0b0dfaac271396281d6ba2320dc5;hb=HEAD;hpb=3f59fc8b771625aca9c3aefe03cf1038d8461963)
my flawed `atof` with a correct one -- the one that shipped with
Quake. Et voilà! The glorious three-passage introduction level loaded
flawlessly, and "E1M1: The Slipgate Complex" loaded fine too. The
sound output still sounded like a 2-cycle lawnmower, but hey -- I'd
gotten Quake to boot on an MP3 player!

## Down the Rabbit Hole

This project finally gave me an excuse to do something I'd been
putting off for a while: learn ARM assembly language.[^2]

The application was in a performance-sensitive sound mixing loop in
`snd_mix.c` (remember the lawnmower-like sound?).

The `SND_PaintChannelFrom8` function takes an array of 8-bit mono
sound samples and mixes it into an existing 16-bit stereo stream, with
left and right channels scaled independently based on two integer
parameters. GCC was doing a terrible job at optimizing the saturation
arithmetic, so I took a shot at it myself. I rather like how it turned
out.

Here's the assembly version I came up with (C version follows):

~~~ {#asm-listing .gnuassembler .numberLines}
SND_PaintChannelFrom8:
        ;; r0: int true_lvol
        ;; r1: int true_rvol
        ;; r2: char *sfx
        ;; r3: int count

        stmfd sp!, {r4, r5, r6, r7, r8, sl}

        ldr ip, =paintbuffer
        ldr ip, [ip]

        mov r0, r0, asl #16					; prescale by 2^16
        mov r1, r1, asl #16

        sub r3, r3, #1						; count backwards

        ldrh sl, =0xffff 					; halfword mask

1:
        ldrsb r4, [r2, r3]					; load input sample
        ldr r8, [ip, r3, lsl #2]				; load output sample pair from paintbuffer
								; (left:right in memory -> right:left in register)
        ;; right channel (high half)
        mul r5, r4, r1						; scaledright = sfx[i] * (true_rvol << 16) -- bottom half is zero
        qadd r7, r5, r8						; right = scaledright + right (in high half of word)
        bic r7, r7, sl						; zero bottom half of r7

        ;; left channel (low half)
        mul r5, r4, r0						; scaledleft = sfx[i] * (true_rvol << 16)
        mov r8, r8, lsl #16					; extract original left channel from paintbuffer
        qadd r8, r5, r8						; left = scaledleft + left

        orr r7, r7, r8, lsr #16					; combine right:left in r7
        str r7, [ip, r3, lsl #2]				; write right:left to output buffer
        subs r3, r3, #1	     					; decrement and loop

        bgt 1b							; must use bgt instead of bne in case count=1

        ldmfd sp!, {r4, r5, r6, r7, r8, sl}

        bx lr
~~~

There's some hackery going on here that could use some explaining. I'm
using the ARM `qadd` DSP instruction to get saturation addition [for
cheap](#asm-listing-25), but `qadd` only works with 32-bit words, and
the sound samples are 16 bits. The hack, then, is to first shift the
samples left by 16 bits; `qadd` the samples together; and then shift
them back. This accomplishes in one instruction what GCC took seven to
do. (Sure, I could've avoided this hack altogether if I were working
with ARMv6, which has MMX-esque packed saturation arithmetic with
`qadd16`, but alas -- life isn't so easy. And besides, it was a cool
hack!)

Notice also that I'm reading and writing two stereo samples at a time
(with a word-sized `ldr` and `str`) to save a couple more cycles.

The C version is below for reference:

~~~ {.c .numberLines}
void SND_PaintChannelFrom8 (int true_lvol, int true_rvol, signed char *sfx, int count)
{
        int     data;
        int             i;

        // we have 8-bit sound in sfx[], which we want to scale to
        // 16bit and take the volume into account
        for (i=0 ; i<count ; i++)
        {
            // We could use the QADD16 instruction on ARMv6+
            // or just 32-bit QADD with pre-shifted arguments
            data = sfx[i];
            paintbuffer[2*i+0] = CLAMPADD(paintbuffer[2*i+0], data * true_lvol); // need saturation
            paintbuffer[2*i+1] = CLAMPADD(paintbuffer[2*i+1], data * true_rvol);
        }
}
~~~

I calculated about a 60% improvement in instructions/sample over the
optimized C version. Most of the saved cycles come from using `qadd`
for saturation arithmetic and packing of memory operations.

### A "Prime" Conspiracy

Here's another interesting bug I ran into along the way. You'll notice
the assembly listing has a comment by the `bgt` instruction (branch if
greater than) noting that `bne` (branch if not equal) cannot be used
because of a corner case that freezes if the sample count is 1. This
will lead to an integer wraparound to `0xFFFFFFFF` and an extremely
long delay (which will eventually resolve itself).

This corner case was triggered by one sound in particular, of 7325
samples in length.[^3] What's so special about 7325, you ask? Try taking it
modulo any power of two:

$$
\begin{align*}
7325 &\equiv 1 &\pmod{2} \\
7325 &\equiv 1 &\pmod{4} \\
7325 &\equiv 5 &\pmod{8} \\
7325 &\equiv 13 &\pmod{16} \\
7325 &\equiv 29 &\pmod{32} \\
7325 &\equiv 29 &\pmod{64} \\
7325 &\equiv 29 &\pmod{128} \\
7325 &\equiv 157 &\pmod{256} \\
7325 &\equiv 157 &\pmod{512} \\
7325 &\equiv 157 &\pmod{1024} \\
7325 &\equiv 1181 &\pmod{2048} \\
7325 &\equiv 3229 &\pmod{4096}
\end{align*}
$$

*5, 13, 29, 157*...

Notice anything? That's right -- by some coincidence, 7325 is prime
whenever taken modulo a power of two. This *somehow* (I'm actually not
sure exactly how) leads to the sound mixing code being passed a
one-sample array, triggering the corner case and freeze.

I spent at least a day rooting out this bug, only to find that it all
came down to *one* wrong instruction. Life is like that sometimes,
isn't it?

## Adieu

In the end I ended up packaging this port up as a
[patch](http://gerrit.rockbox.org/r/1832/) and merging it into the
Rockbox mainline, where it resides today. It ships with builds for
most of the ARM targets with color displays in Rockbox 3.15 and
later.[^4] If you don't have a supported target, you can
[watch](https://www.youtube.com/watch?v=74i8aBOmyos) user890104's demo.

I've omitted a couple interesting things here for the sake of
space. There is, for example, the race condition that occured only
when gibbing a zombie but only when the audio sample rate was 44.1
kHz. (This was a result of the sound thread trying to load a sound --
a explosion -- while the model loader tried to load the gib
model. These two sections relied on a common function that relied on
the same global variable.) And then there's the assorted alignment
issues (love 'ya, ARM!) and the rendering micro-optimizations I made
to squeeze out a few more frames. But those are for another time. For
now, it is time to say goodbye to Quake -- it's been good to me.

So long, and thanks for all the fish!

[^1]: The latter game was the first to use the Rockbox SDL runtime and
deserves a post of its own. Watch user890104's demo of it
[here](https://www.youtube.com/watch?v=aEkBJ-fHxhA).

[^2]: If you're interested in learning ARM assembly, Jasper Vijn's
[*Tonc: Whirlwind Tour of ARM
Assembly*](https://www.coranac.com/tonc/text/asm.htm) is a good
(albeit slightly outdated and GBA-oriented) place to start. And while
you're at it, go ahead and get a printout of the [ARM Quick Reference
Card](https://infocenter.arm.com/help/topic/com.arm.doc.qrc0001l/QRC0001_UAL.pdf).

[^3]: It was the sound triggered by a [100 health
pickup](r_item2.wav), incidentally.

[^4]: I honestly don't remember exactly which targets do and don't
support Quake. If you're curious, head over to the [Rockbox
site](https://rockbox.org) and try installing a build for whatever
target(s) you might have. And do [let me know](mailto:me@fwei.tk) how
it runs!  New versions of [Rockbox
Utility](https://www.rockbox.org/wiki/RockboxUtility) (1.4.1 and
later) also support automatic installation of the Quake shareware.
