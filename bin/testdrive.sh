#!/bin/sh

term_cols="$(tput cols)"
term_lines="$(tput lines)"
cols=$((term_cols / 3))
rows=$(( term_lines / 3 ))
awk -v cols="$cols" -v rows="$rows" 'BEGIN{
    s="  ";
    m=cols+rows;
    for (row = 0; row<rows; row++) {
      for (col = 0; col<cols; col++) {
          i = row+col;
          r = 255-(i*255/m);
          g = (i*510/m);
          b = (i*255/m);
          if (g>255) g = 510-g;
          printf "\033[48;2;%d;%d;%dm", r,g,b;
          printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
          printf "%s\033[0m", substr(s,(col+row)%2+1,1);
      }
      printf "\n";
    }
    printf "\n";
}'

echo "# text decorations"
printf '\e[1mbold\e[22m\n'
printf '\e[2mdim\e[22m\n'
printf '\e[3mitalic\e[23m\n'
printf '\e[4munderline\e[24m\n'
printf '\e[4:1mthis is also underline\e[24m\n'
printf '\e[21mdouble underline\e[24m\n'
printf '\e[4:2mthis is also double underline\e[24m\n'
printf '\e[4:3mcurly underline\e[24m\n'
printf '\e[58;5;10;4mcolored underline\e[59;24m\n'
printf '\e[5mblink\e[25m\n'
printf '\e[7mreverse\e[27m\n'
printf '\e[8minvisible\e[28m <- invisible (but copy-pasteable)\n'
printf '\e[9mstrikethrough\e[29m\n'
printf '\e[53moverline\e[55m\n'
printf '\e[31mred\e[39m\n'
printf '\e[91mbright red\e[39m\n'
printf '\e[38;5;42m256-color, de facto standard (commonly used)\e[39m\n'
printf '\e[38;2;240;143;104mtruecolor, de facto standard (commonly used)\e[39m\n'
printf '\e[46mcyan background\e[49m\n'
printf '\e[106mbright cyan background\e[49m\n'
printf '\e[48;5;42m256-color background, de facto standard (commonly used)\e[49m\n'
printf '\e[48;2;240;143;104mtruecolor background, de facto standard (commonly used)\e[49m\n'
echo

echo "# Unicode string"
echo "é Δ Й ק م ๗ あ 叶 葉 말"
echo

echo "# emojis"
echo "😃😱😵"
echo
