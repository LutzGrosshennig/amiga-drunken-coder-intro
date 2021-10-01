# amiga-drunken-coder-intro

My contribution to the "40K Amiga Intro" competition at the "Party 3" back in December 1993.

![Screenshot](https://github.com/LutzGrosshennig/amiga-drunken-coder-intro/blob/main/images/Screenshot.jpg)

## Background

Since the music and the graphic took the largest chunk of the 40kb there was not much room left for the actual
code. However the intro showed (AFAIK for the first time ever on an stock A500) a realtime softshadow of the scroll text.

The shadow itself was generated using the extra halfbrite mode (EHB) so basicly I draw a LOT of lines in the 6th bitplane :D

## The code

When I look at the code today, I am like: "WTF? Who wrote this crap?" 

Well of course I did but it was 28 years ago and back then I did not know better. Now I know better but that is another story.
The code itself is written using the "Profimat" assembler which was my favorite IDE (yes it was an actual IDE) back then but it should not be very hard to port it to other assemblers.
Just make sure the data section goes into chip ram.

The files build_char.asm and build2_char.asm are only used to pack multiple raw files into a bigger file. This reduced the build time (floppy seek times where terrible).

## Demo scene reference

https://www.pouet.net/prod.php?which=72798
https://demozoo.org/productions/5920/

You may notice that the scroll text of this version and the released version are different. 
Thats because I had to change the text while I was at the party (using a hex editor...) but I cant recall why.

A big shoutout to all who attended.
