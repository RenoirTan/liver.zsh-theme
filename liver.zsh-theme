# I hate shell script

autoload -U colors && colors
autoload -Uz vcs_info

# Set the value of a variable (with its name as $1) to the value of $2 if the variable is empty.
zl_make_default() {
    if [[ -z $(eval echo \$$(echo $1)) ]]; then
        eval $1=$2
    fi
}

# Create a ZSH color.
zl_make_color() {
    # 1: fg
    # 2: bg
    
    if [[ ! ( -z $1 || $1 == "!" ) ]]; then
        echo -n "%{$fg[$1]%}"
    fi
    if [[ ! ( -z $2 || $2 == "!" ) ]]; then
        echo -n "%{$bg[$2]%}"
    fi
}

# Reset color.
zl_reset() {
    echo -n "%{$reset_color%}"
}

# Color a piece of text.
zl_color_text() {
    # 1: fg
    # 2: bg
    # 3: text
    
    echo -n "$(zl_make_color $1 $2)$3$(zl_reset)"
}

# Create a prompt segment.
zl_make_segment() {
    # 1: segment_fg
    # 2: segment_bg
    # 3: info_fg
    # 4: info_bg
    # 5: info

    zl_color_text $1 $2 $ZL_SEGMENTLEFT
    zl_color_text $3 $4 $5
    zl_color_text $1 $2 $ZL_SEGMENTRIGHT
}

# Create a segment on the left prompt.
zl_add_left_segment() {
    # 1: segment_fg
    # 2: segment_bg
    # 3: info_fg
    # 4: info_bg
    # 5: info
    
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_CONNECTOR
    zl_make_segment $1 $2 $3 $4 $5
}

# Create a segment on the right prompt.
zl_add_right_segment() {
    # 1: segment_fg
    # 2: segment_bg
    # 3: info_fg
    # 4: info_bg
    # 5: info
    
    zl_make_segment $1 $2 $3 $4 $5
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_CONNECTOR
}

# Create a segment displaying your username.
zl_segment_user() {
    zl_add_left_segment $ZL_USERNAME_SFG $ZL_USERNAME_SBG $ZL_USERNAME_FG $ZL_USERNAME_BG "$ZL_USERNAME_ICON %n"
}

# Create a segment displaying your hostname.
zl_segment_hostname() {
    zl_add_left_segment $ZL_HOSTNAME_SFG $ZL_HOSTNAME_SBG $ZL_HOSTNAME_FG $ZL_HOSTNAME_BG "$ZL_HOSTNAME_ICON %M"
}

# Create a segment displaying your current working directory.
zl_segment_path() {
    zl_add_left_segment $ZL_PATH_SFG $ZL_PATH_SBG $ZL_PATH_FG $ZL_PATH_BG "$ZL_PATH_ICON %~"
}

# Generate the top-left prompt.
zl_gen_leftup_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_LEFTUPBEGIN
    zl_segment_user
    zl_segment_hostname
    zl_segment_path
}

# Check if the user is root or a normal user.
# If the user is root, output $ZL_ROOT_PROMPTTOKEN.
# Otherwise $ZL_USER_PROMPTTOKEN.
zl_prompttoken_usercheck() {
    [[ $(whoami) == "root" ]] && echo -n $ZL_ROOT_PROMPTTOKEN || echo -n $ZL_USER_PROMPTTOKEN
}

# Create a segment displaying the prompt token.
zl_segment_prompttoken() {
    zl_add_left_segment $ZL_PROMPTTOKEN_SFG $ZL_PROMPTTOKEN_SBG $ZL_PROMPTTOKEN_FG $ZL_PROMPTTOKEN_BG $(zl_prompttoken_usercheck)
}

# Generate the bottom-left prompt.
zl_gen_leftdown_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_LEFTDOWNBEGIN
    zl_segment_prompttoken
}

# # Create a segment displaying the VCS system being used in the current directory.
zl_segment_vcssystem() {
    zstyle ':vcs_info:*' enable git svn hg
    zstyle ':vcs_info:git*' formats "%s"
    vcs_info
    if [[ ! -z $vcs_info_msg_0_ ]]; then
        zl_add_left_segment $ZL_VCSSYSTEM_SFG $ZL_VCSSYSTEM_SBG $ZL_VCSSYSTEM_FG $ZL_VCSSYSTEM_BG "$ZL_VCSSYSTEM_ICON $vcs_info_msg_0_"
    fi
}

# Create a segment displaying the branch name in the current directory.
zl_segment_vcsbranch() {
    zstyle ':vcs_info:*' enable git svn hg
    zstyle ':vcs_info:git*' formats "%b"
    vcs_info
    if [[ ! -z $vcs_info_msg_0_ ]]; then
        zl_add_left_segment $ZL_VCSBRANCH_SFG $ZL_VCSBRANCH_SBG $ZL_VCSBRANCH_FG $ZL_VCSBRANCH_BG "$ZL_VCSBRANCH_ICON $vcs_info_msg_0_"
    fi
}

# Create a segment displaying the current relative path to the repository's root.
zl_segment_vcspath() {
    zstyle ':vcs_info:*' enable git svn hg
    zstyle ':vcs_info:git*' formats "%S"
    vcs_info
    if [[ ! -z $vcs_info_msg_0_ ]]; then
        zl_add_left_segment $ZL_VCSPATH_SFG $ZL_VCSPATH_SBG $ZL_VCSPATH_FG $ZL_VCSPATH_BG "$ZL_VCSPATH_ICON $vcs_info_msg_0_"
    fi
}

# Create a segment displaying the meta info for the current repository.
zl_segment_vcsmeta() {
    zstyle ':vcs_info:*' enable git svn hg
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:git*' formats "%u%c"
    zstyle ':vcs_info:*' stagedstr $ZL_VCSMETA_STAGED_ICON
    zstyle ':vcs_info:*' unstagedstr $ZL_VCSMETA_UNSTAGED_ICON
    vcs_info
    if [[ ! -z $vcs_info_msg_0_ ]]; then
        zl_add_left_segment $ZL_VCSMETA_SFG $ZL_VCSMETA_SBG $ZL_VCSMETA_FG $ZL_VCSMETA_BG "$ZL_VCSMETA_ICON $vcs_info_msg_0_"
    fi
}

# Generate the VCS prompt.
zl_gen_leftvcs_prompt() {
    local vcs_output
    vcs_output="$vcs_output$(zl_segment_vcssystem)"
    vcs_output="$vcs_output$(zl_segment_vcsbranch)"
    vcs_output="$vcs_output$(zl_segment_vcspath)"
    vcs_output="$vcs_output$(zl_segment_vcsmeta)"
    if [[ ! -z $vcs_output ]]; then
        zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_LEFTMIDDLEBEGIN
        echo -n $vcs_output
    fi
}

# Generate the top-right prompt.
zl_gen_rightup_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_RIGHTUPBEGIN
}

# Generate the bottom-right prompt.
zl_gen_rightdown_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_RIGHTDOWNBEGIN
}

# Generate the left prompt.
zl_gen_prompt() {
    zl_gen_leftup_prompt
    echo
    
    local leftvcs_prompt=$(zl_gen_leftvcs_prompt)
    if [[ ! -z $leftvcs_prompt ]]; then
        echo $leftvcs_prompt
    fi
    
    zl_gen_leftdown_prompt
    echo -n " "
    zl_color_text $ZL_POINTER_FG $ZL_POINTER_BG $ZL_PROMPTPOINTER
    echo -n " "
}

# Generate the right prompt.
# Does not work properly at the moment
zl_gen_rprompt() {
    zl_gen_rightup_prompt
    echo
    zl_gen_rightdown_prompt
}

# Function to fill in default configurations if they have not been overridden somewhere else.
zl_make_configs() {

    # Prompt Symbols:
    # These symbols act as a visual framework for prompt elements and gives the prompt its shape.
    # You can override these variables in ~/.zshrc to change the "shape" of your prompt.

    # The symbol used at the start of the top-left portion of the prompt.
    zl_make_default ZL_LEFTUPBEGIN ╭
    # The symbol used for parts of the prompt that appear on the left between the top-left prompt and the bottom-left prompt.
    zl_make_default ZL_LEFTMIDDLEBEGIN ├
    # The symbol used at the start of the bottom-left portion of the prompt.
    zl_make_default ZL_LEFTDOWNBEGIN ╰
    # The symbol used at the start (on the extreme right) of the top-right portion of the prompt.
    zl_make_default ZL_RIGHTUPBEGIN ╮
    # The symbol used for parts of the prompt that appear on the right between the top-right and the bottom-right prompt. 
    zl_make_default ZL_RIGHTMIDDLEBEGIN ┤
    # The symbol used at the start (on the extreme right) of the bottom-right portion of the prompt.
    zl_make_default ZL_RIGHTDOWNBEGIN ╯
    # The symbol used to connect segments.
    zl_make_default ZL_CONNECTOR ─
    # The symbol used at the start of a segment. (Think of it as an open bracket)
    zl_make_default ZL_SEGMENTLEFT ┤
    # The symbol used at the end of a segment.
    zl_make_default ZL_SEGMENTRIGHT ├
    # Token used after the prompt and before the text input field where the user types commands.
    zl_make_default ZL_PROMPTPOINTER ➤
    
    # Foreground colour for the prompt.
    zl_make_default ZL_BASE_FG magenta
    # Background colour for the prompt.
    zl_make_default ZL_BASE_BG !
    # Foreground colour of the prompt pointer.
    zl_make_default ZL_POINTER_FG green
    # Background colour of the prompt pointer.
    zl_make_default ZL_POINTER_BG !

    # Icon at the start of the segment that displays your username.
    zl_make_default ZL_USERNAME_ICON ⚉
    # Foreground colour for your username.
    zl_make_default ZL_USERNAME_FG cyan
    # Background colour for your username.
    zl_make_default ZL_USERNAME_BG !
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for your username.
    zl_make_default ZL_USERNAME_SFG magenta
    # Background colour for ZL_SEGMEPstname.
    zl_make_default ZL_HOSTNAME_FG red
    # Background colour for your hostname.
    zl_make_default ZL_HOSTNAME_BG !
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for your hostname.
    zl_make_default ZL_HOSTNAME_SFG magenta
    # Background colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for your hostname.
    zl_make_default ZL_HOSTNAME_SBG !
    
    # Icon at the start of the segment that displays your current working directory.
    zl_make_default ZL_PATH_ICON ⤇
    # Foreground colour for your current working directory.
    zl_make_default ZL_PATH_FG yellow
    # Background colour for your current working directory.
    zl_make_default ZL_PATH_BG !
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for your current working directory.
    zl_make_default ZL_PATH_SFG magenta
    # Background colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for your current working directory.
    zl_make_default ZL_PATH_SBG !
    
    # Symbol used to indicate that you are logged into the terminal as a normal user.
    zl_make_default ZL_USER_PROMPTTOKEN \$
    # Symbol used to indicate that you are logged into the terminal as root.
    zl_make_default ZL_ROOT_PROMPTTOKEN \#
    # Foreground colour for your prompt token.
    zl_make_default ZL_PROMPTTOKEN_FG white
    # Background colour for your prompt token.
    zl_make_default ZL_PROMPTTOKEN_BG !
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for your prompt token.
    zl_make_default ZL_PROMPTTOKEN_SFG magenta
    # Background colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for your prompt token.
    zl_make_default ZL_PROMPTTOKEN_SBG !
    
    # Icon at the start of the segment that displays the VCS system used in this directory.
    zl_make_default ZL_VCSSYSTEM_ICON 
    # Foreground colour for the VCS system used in this directory.
    zl_make_default ZL_VCSSYSTEM_FG black
    # Background colour for the VCS system used in this directory.
    zl_make_default ZL_VCSSYSTEM_BG yellow
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the VCS system used in this directory.
    zl_make_default ZL_VCSSYSTEM_SFG magenta
    # Background colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the VCS system used in this directory.
    zl_make_default ZL_VCSSYSTEM_SBG !
    
    # Icon at the start of the segment that displays the current branch.
    zl_make_default ZL_VCSBRANCH_ICON 
    # Foreground colour for the current branch.
    zl_make_default ZL_VCSBRANCH_FG black
    # Background colour for the current branch.
    zl_make_default ZL_VCSBRANCH_BG green
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the current branch.
    zl_make_default ZL_VCSBRANCH_SFG magenta
    # Background colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the current branch.
    zl_make_default ZL_VCSBRANCH_SBG !

    # Icon at the start of the segment that displays the current working directory relative to the root of the repository.
    zl_make_default ZL_VCSPATH_ICON ⤇
    # Foreground colour for the current working directory relative to the root of the repository.
    zl_make_default ZL_VCSPATH_FG white
    # Background colour for the current working directory relative to the root of the repository.
    zl_make_default ZL_VCSPATH_BG blue
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the current working directory relative to the root of the repository.
    zl_make_default ZL_VCSPATH_SFG magenta
    # Background colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the current working directory relative to the root of the repository.
    zl_make_default ZL_VCSPATH_SBG !
    
    # Icon at the start of the segment that displays the repository's meta info.
    zl_make_default ZL_VCSMETA_ICON 🛈
    # Foreground colour for the repository's meta info.
    zl_make_default ZL_VCSMETA_FG white
    # Background colour for the repository's meta info.
    zl_make_default ZL_VCSMETA_BG magenta
    # Foreground colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the repository's meta info.
    zl_make_default ZL_VCSMETA_SFG magenta
    # Background colour for ZL_SEGMENTLEFT and ZL_SEGMENTRIGHT when used in the segment for the repository's meta info.
    zl_make_default ZL_VCSMETA_SBG !
    
    # Icon used to indicate the presence of an unstaged action.
    zl_make_default ZL_VCSMETA_UNSTAGED_ICON +
    # Icon used to indicate the presence of a staged but uncommitted action.
    zl_make_default ZL_VCSMETA_STAGED_ICON ✓
}

zl_make_configs

PROMPT='$(zl_gen_prompt)'
#RPROMPT="$(zl_gen_rprompt)"