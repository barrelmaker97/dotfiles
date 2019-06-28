git log --all --graph --color=always \
	--pretty=format:"GPGSIG%G?%C(red)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)" \
	| sed -e 's/GPGSIGN\(...\)./\11/; s/GPGSIGG\(...\)./\12/; s/GPGSIG.\(...\)./\13/;' \
	| less -RX
