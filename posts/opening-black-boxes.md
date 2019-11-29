# On Opening Black Boxes or: How I Learned to Stop Worrying and Love G-Code

![Baby Yoda, engraved.](baby-yoda.png)

**TL;DR** PhotoVCarve should not cost $149. I made [my own](https://github.com/built1n/rastercarve).

Recently I've gotten my hands on a 3-axis [ShopBot milling
machine](https://www.shopbottools.com/products/max). For the
uninitiated, a CNC mill is essentially a robotic carving machine --
think "*robot drill*": you put in a piece of wood/foam/aluminum,
program the machine, and out comes a finished piece with the right
patterns cut into it. I had the idea of
[engraving](https://en.wikipedia.org/wiki/Engraving) a raster image
using the machine, and there happens to be a nice piece of software
out there that claims to do just that: Vectric's
[PhotoVCarve](https://www.vectric.com/products/photovcarve).

There's just one problem: PhotoVCarve costs $149. Now, I have no
qualms paying for software when it makes sense to do so, but in this
case, $149 is simply excessive -- especially for a hobbyist. And
besides, just see for yourself in the video below: all PhotoVCarve
does is take an image and draw a bunch of grooves over it -- *nothing
that couldn't be done in a couple lines of Python,* I thought.

[![PhotoVCarve - Engraving Photographs](http://img.youtube.com/vi/krFyBxYwWW8/0.jpg)](https://www.youtube.com/watch?v=krFyBxYwWW8)

## G-Code

The first step in the process was figuring out *how* to control a CNC
machine. Some Googling told me that virtually all machines read
"G-code", a sequence of alphanumeric instructions that command the
movement of the tool in 3 dimensions. It looks something like this:

```
G00 X0 Y0 Z0.2
G01 Z-0.2 F10
G01 X1.0 Y0
```

These three commands tell the machine to:

1. Go to (0, 0, 0.2), rapidly (`G00` is "rapid traverse").
2. Go to (0, 0, -0.2), slowly (`G01` commands a slower move than `G00`).
3. Go to (1, 0, 0), slowly.

My program just had to output the right sequence of G-code commands,
which I could then feed into the ShopBot control software. (This was
far simpler than I had originally imagined.)

At this point, one of my flow states kicked in. I sat down, and got to
coding.

## The Program

The development process was surprisingly straightforward -- I put in
perhaps a total of 4 hours from my initial proof-of-concept to the
current viable prototype. There were no major hiccups this time
around, and even though I'm still in the process of learning it,
Python made things *so* much easier than C (or God forbid -- [ARM
assembly](adieu-quake.html)).

The heart of my program is a function,
[`engraveLine`](http://fwei.tk/git/rastercarve/tree/src/rastercarve.py?id=c2de4a3258c3e37d4b49a41d786eef936262f137#n118),
which outputs the G-code to engrave one "groove" across the image. It
takes in a initial position vector on the border of the image, and a
direction vector telling it which way to cut.

After this was written, it was a simple exercise to write a driver
function to call `engraveLine` with the right vectors in the right
sequence -- and that was all it took! (I really wonder how Vectric
manages to charge $149 for this...)

I fired up the program on a test image and fed its output into
ShopBot's excellent G-code previewer. Success (see above)! I added a
couple of tweaks (getting the lines to cut at an angle was fun) and I
christened the program
[*RasterCarve*](https://github.com/built1n/rastercarve).

## Conclusion

This was a fun little project that falls into the theme of "gradually
opening up black boxes." G-code, I learned, isn't nearly as hard as it
might seem. It's all too easy to abstract away the details of a
technical process, but sometimes the best way to really understand
something is by opening up the hood and tinkering with it.
