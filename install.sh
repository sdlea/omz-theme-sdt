#!/usr/bin/zsh

usage="USAGE :: ./install /path/to/target-theme"
usage+="\n\t>> copy theme file to themes folder in ZSH_CUSTOM"
usage+="\n\t>> if no file provided, use \"./sdt.zsh-theme\""
echo $usage

if [[ "$#" = 0 ]]; then
	tfile="./sdt.zsh-theme"
else
	tfile=$1
fi

rcfile="$HOME/.zshrc"
eval $(grep "^[[:blank:]]*export[[:blank:]]\{1,\}ZSH=" "$rcfile") >> /dev/null
cstm=$(grep "^[[:blank:]]*ZSH_CUSTOM" "$rcfile" >>/dev/null)

if [[ -z "$cstm" ]]; then
	ZSH_CUSTOM="$ZSH/custom";
	echo "No custom directory found, using default($ZSH_CUSTOM), please confirm[y/n]?";
else
	eval "$cstm";
	echo "Custom directory detected($ZSH_CUSTOM), use it[y/n]?"
fi

while true; do
	read -r cnfm
	if [[ "$cnfm" == "y" || "$cnfm" == "Y" ]]; then
		break
	elif [[ "$cnfm" == "n" || "$cnfm" == "N" ]]; then
		return 0
	else
		echo "please choose[y/n]."
	fi
done

target="${ZSH_CUSTOM}"/themes
[[ -d $target ]] || mkdir -p "$target"

cp "$tfile" "$target/"
echo "theme file is copied"

echo "Would you like to use this theme?"
read -r cnfm
if [[ "$cnfm" = "y" ]]; then
	sed -i 's/\(^[[:space:]]*ZSH_THEME="\)\([^"]\{1,\}\)\(".*\)/\1sdt\3/' ${rcfile}
	echo "replaced,\nNow would you like to \`source' zshrc?"
	read -r cnfm
	if [[ "$cnfm" == "y" ]]; then
		source $rcfile
		echo "DONE"
	else
		echo "Not [y] key, abort"
		return 0
	fi
else
	echo "Not [y] key, abort"
	return 0
fi
