'  Copyright (c) 2011 David Caldwell,  All Rights Reserved.
recv_file:
    print "<filename>"
    input line$
    if line$ = "end" then end
    if seg$(line$,1,5) <> "file:" then goto recv_file
    filename$ = seg$(line$,6, Len(line$))

open "dx1:"&filename$ for output as file #1

Let byte=0
Let checksum=0
dim split$(32)
out$ = ""
Line:
    Input line$
    If line$ = "done" Then GoTo file_done
'    If Line$ = "" Then GoTo Line
    GoSub split
    For x=1 to split_n
        o = Val(split$(x))
        checksum = checksum + o
        out$ = out$ & chr$(o)
    next x
    If Len(out$) > 200 Then GoSub Print_it
    byte = byte + split_n
    Print "<";byte;",";checksum;">"
    GoTo Line

Print_it:
    print #1: out$
    out$=""
    return

file_done:
    GoSub Print_it
    close #1
    goto recv_file

split:
    Let split_n=1
nextword:
    Let space=pos(line$," ",1)
    If space = 0 Then space = Len(line$)+1
    split$(split_n)=seg$(line$,1,space-1)
    If Len(split$(split_n)) = 0 Then split_n = split_n - 1 \ return
    line$ = seg$(line$,Space+1,Len(line$))
    If Len(line$) = 0 Then return
    split_n = split_n + 1
    GoTo nextword
