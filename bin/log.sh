git log --all --graph --color=always \
	--pretty=format:"GPGSIG%G?%C(red)%h%C(green)%h%C(yellow)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)" \
	| sed -e 's/GPGSIGN\(.\{12\}\)\(.\{12\}\)\(.\{12\}\)/\1/; s/GPGSIGG\(.\{12\}\)\(.\{12\}\)\(.\{12\}\)/\2/; s/GPGSIG.\(.\{12\}\)\(.\{12\}\)\(.\{12\}\)/\3/;' \
	| less -RX
