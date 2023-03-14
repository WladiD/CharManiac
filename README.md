# CharManiac
Windows console application for file text encoding conversion

## History
I thought it would be a simple task to change the encoding of a text file via a batch file in the Windows console and at the same time remove or add the BOM. But I found that even after extensive searching, I couldn't find a reasonable solution.

So I fired up my trusty Delphi and wrote a little console application myself that does exactly what I want.

I'm sure it will be a useful tool for someone else too and so I'm releasing it here as an open source project.

## Installation
Download the binary from the [releases section](https://github.com/WladiD/CharManiac/releases) and extract it to any folder. The application has no dependencies so you can run it out of the box (that is the beauty of Delphi :-)).

## Usage dump

If you call the `CharManiac.exe` from the console you get the following instructions:
```
CharManiac SourceEncoding TargetEncoding SourceFile TargetFile
Possible text encodings:
 ASCII
 ANSI
 UTF-8(-BOM)
 Unicode(-BOM)

Optional newline config, append to TargetEncoding:
 -UnixNewLine
 -WindowsNewLine

Examples for valid encodings:
 UTF-8-UnixNewLine
 Unicode-BOM-WindowsNewLine

Warning: TargetFile will be overwritten.
```

## Examples

### Add BOM to a UTF-8 file:
```
CharManiac.exe UTF-8 UTF-8-BOM SourceFileWithoutBOM.txt TargetFileWithBOM.txt
```

### Remove BOM from a UTF-8 file:
```
CharManiac.exe UTF-8-BOM UTF-8 SourceFileWithBOM.txt TargetFileWithoutBOM.txt
```
