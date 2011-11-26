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
out$ = ""
Line:
    Input line$
    If line$ = "done" Then GoTo file_done

    GoSub split

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
    Let s_start=1
    If line$ = "" Then split_n = 0 \ Return
    Let Line_Len = Len(line$)
nextword:
    Let space=pos(line$," ",s_start)
    If space = 0 Then space = Line_len+1
    Let out = Val(seg$(line$,s_start,space-1))
    checksum = checksum + out
    out$ = out$ & chr$(out)
    s_start = Space+1
    If s_start > Line_len Then return
    split_n = split_n + 1
    GoTo nextword
