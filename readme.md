# Apple II : Font Editor, using Mouse Graphics Toolkit in Merlin 32 syntax

Based on the Mouse Graphics Toolkit demo program, here's a program that lets you modify the system font.

The Tool Kit demo program was first converted to Merlin format (Merlin 32) and then adapted for font editing.

I've commented heavily on the source code (tkdemo.s and equates.s), integrating parts of the documentation in addition to my own comments. This makes the program easy to read and understand. 

The Mouse Graphics Toolkit is the Apple IIe / IIc ancestor of the Apple IIGS and Macintosh Toolbox. It's an excellent way to familiarize yourself with event-driven programming and Apple's "guidelines".

## Use
This archive contains a ProDOS disk image (tkdemo.po) to be used it your favourite Apple II emulator or your Apple II.
* Start your Apple II with the "tkdemo.po" disk.
* The startup basic program will launch the demo program.


## Requirements to compile and run

Here is my configuration:

* Visual Studio Code with 2 extensions :

-> [Merlin32 : 6502 code hightliting](marketplace.visualstudio.com/items?itemName=olivier-guinart.merlin32)

-> [Code-runner :  running batch file with right-clic.](marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

* [Merlin32 cross compiler](brutaldeluxe.fr/products/crossdevtools/merlin)

* [Applewin : Apple IIe emulator](github.com/AppleWin/AppleWin)

* [Applecommander ; disk image utility](applecommander.sourceforge.net)

* [Ciderpress ; disk image utility](a2ciderpress.com)

Compilation notes :

DoMerlin.bat puts it all together. If you want to compile yourself, you will have to adapt the path to the Merlin32 directory, to Applewin and to Applecommander in DoMerlin.bat file.

DoMerlin.bat is to be placed in project directory.
It compiles source (*.s) with Merlin32, copy 6502 binary to a disk image (containg ProDOS), and launch Applewin with this disk in S6,D1.

