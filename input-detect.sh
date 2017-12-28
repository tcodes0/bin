#! /bin/bash
#see man jot or try inputting "debug" to see what jot does.
#the \\ are literal \ to escape the chars generated.
jot1=[\\$(jot -c -s ,\\ - 33 47)]
jot2=[\\$(jot -c -s ,\\ - 58 64)]
jot3=[\\$(jot -c -s ,\\ - 91 96)]
jot4=[\\$(jot -c -s ,\\ - 123 126)]
message="my guess is one of: "
echo -n "type any letter or character really but just one > "
read char
case $char in
    [a-z]  ) echo "$message a lowercase letter" ;;
    [A-Z]  ) echo "$message an uppercase letter" ;;
    [0-9]  ) echo "$message a number" ;;
                                  #td "delete" literal \ to be pretier when output.
    $jot1 ) echo "$message $jot1" | tr -d \\  ;;
    $jot2 ) echo "$message $jot2" | tr -d \\  ;;
    $jot3 ) echo "$message $jot3" | tr -d \\  ;;
    $jot4 ) echo "$message $jot4" | tr -d \\  ;;
    debug ) echo "
	           $jot1
		   $jot2
		   $jot3
		   $jot4"
		   ;;
    *) echo "you typed something invisble probably. congrats." ;;
esac
echo
echo "actually just a "$char
