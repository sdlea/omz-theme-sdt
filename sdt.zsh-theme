PROMPT="%(?:%{$fg_bold[green]%}%n%1{ >>%}:%{$fg_bold[red]%}%n%1{ x>%}) %{$fg[cyan]%}%2~ %{$reset_color%}"

# git(<BRANCH> ^n_m +x ,y !)
# ^ :: ahead	_ :: behind	* :: untrakced
# , :: staged	+ :: modified	? :: conflicts
# @ stash	! :: dirty 	. :: clean
ZSH_THEME_GIT_SHOW_UPSTREAM=1
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} !%{$fg[blue]%}%3{)%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}%5{ .)%}"

ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX=" ^"
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX="_"

function __git_prompt_git() {
	GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function __concat() {
	if [[ -n "$2" && "$2" != 0 && ! "$2" =~ "^[[:space:]]*$" ]]; then
		printf "%s" "$@"
	fi
	return 0
}

function git_prompt_info () {
	# If we are on a folder not tracked by git, get out.
	# Otherwise, check for hide-info at global and local repository level
	if ! __git_prompt_git rev-parse --git-dir &> /dev/null \
	|| [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
		return 0;
	fi

	# Get either:
	# - the current branch name
	# - the tag name if we are on a tag
	# - the short SHA of the current commit
	local ref
	ref=$(__git_prompt_git symbolic-ref --short HEAD 2> /dev/null) \
	|| ref=$(__git_prompt_git describe --tags --exact-match HEAD 2> /dev/null) \
	|| ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) \
	|| return 0

	# Use global ZSH_THEME_GIT_SHOW_UPSTREAM=1 for including upstream remote info
	local upstream
	if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} )); then
		upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null) \
		&& upstream=" -> ${upstream%/*}"
	fi

	local dtls
	dtls=$(__concat " " \
		$(git_commits_ahead) \
		$(git_commits_behind) \
		$(__concat "+" $(printf "%s" "$(__git_prompt_git status --porcelain=v1)" | grep "^ M" | wc -l)) \
		$(__concat "?" $(printf "%s" "$(__git_prompt_git status --porcelain=v1)" | grep "^U" | wc -l)) \
		$(__concat "*" $(printf "%s" "$(__git_prompt_git status --porcelain=v1)" | grep "^??" | wc -l)) \
		$(__concat "@" $(printf "%s" "$(__git_prompt_git stash list)" | wc -l)) \
	)

	echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref:gs/%/%%}${upstream:gs/%/%%}${dtls}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

PROMPT+=' $(git_prompt_info)'
# LS colors, made with https://geoff.greer.fm/lscolors/
export LSCOLORS="gxfxcxdxcxdhehbhbhahdh"
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=32:bd=33;47:cd=34;47:su=31;47:sg=31;47:tw=30;47:ow=33;47:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32'
