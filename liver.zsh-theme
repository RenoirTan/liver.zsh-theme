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

# Make decoration.
zl_make_decoration() {
    # 1: fg
    # 2: bg
    # 3: bold

    if [[ ! ( -z $1 || $1 == "!" ) ]]; then
        echo -n "%F{$1}"
    fi
    if [[ ! ( -z $2 || $2 == "!" ) ]]; then
        echo -n "%K{$2}"
    fi
    if [[ ! ( -z $3 || $3 == "!" ) ]]; then
        echo -n "%B"
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

# Decorate a portion of text.
zl_decorate_text() {
    # 1: decoration
    # 2: text

    echo -n "$1$2$(zl_reset)"
}

# Create a prompt segment.
zl_make_segment() {
    # 1: text decoration
    # 2: segment decoration
    # 3: text

    zl_decorate_text $2 $ZL_SEGMENTLEFT
    zl_decorate_text $1 $3
    zl_decorate_text $2 $ZL_SEGMENTRIGHT
}

# Create a segment on the left prompt.
zl_add_left_segment() {
    # 1: text decoration
    # 2: segment decoration
    # 3: text
    
    zl_decorate_text $ZL_BASE_DEC $ZL_CONNECTOR
    zl_make_segment $1 $2 $3
}

# Create a segment on the right prompt.
zl_add_right_segment() {
    # 1: text decoration
    # 2: segment decoration
    # 3: text
    
    zl_make_segment $1 $2 $3
    zl_decorate_text $ZL_BASE_DEC $ZL_CONNECTOR
}

# Create a segment displaying your username.
zl_segment_user() {
    zl_add_left_segment $ZL_USERNAME_DEC $ZL_USERNAME_SDEC "$ZL_USERNAME_ICON %n"
}

# Create a segment displaying your hostname.
zl_segment_hostname() {
    zl_add_left_segment $ZL_HOSTNAME_DEC $ZL_HOSTNAME_SDEC "$ZL_HOSTNAME_ICON %M"
}

# Create a segment displaying your current working directory.
zl_segment_path() {
    zl_add_left_segment $ZL_PATH_DEC $ZL_PATH_SDEC "$ZL_PATH_ICON %~"
}

# Generate the top-left prompt.
zl_gen_leftup_prompt() {
    zl_decorate_text $ZL_BASE_DEC $ZL_LEFTUPBEGIN
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
    zl_add_left_segment $ZL_PROMPTTOKEN_DEC $ZL_PROMPTTOKEN_SDEC $(zl_prompttoken_usercheck)
}

# Generate the bottom-left prompt.
zl_gen_leftdown_prompt() {
    zl_decorate_text $ZL_BASE_DEC $ZL_LEFTDOWNBEGIN
    zl_segment_prompttoken
}

# # Create a segment displaying the VCS system being used in the current directory.
zl_segment_vcssystem() {
    zstyle ':vcs_info:*' enable git svn hg
    zstyle ':vcs_info:git*' formats "%s"
    vcs_info
    if [[ ! -z $vcs_info_msg_0_ ]]; then
        zl_add_left_segment $ZL_VCSSYSTEM_DEC $ZL_VCSSYSTEM_SDEC "$ZL_VCSSYSTEM_ICON $vcs_info_msg_0_"
    fi
}

# Create a segment displaying the branch name in the current directory.
zl_segment_vcsbranch() {
    zstyle ':vcs_info:*' enable git svn hg
    zstyle ':vcs_info:git*' formats "%b"
    vcs_info
    if [[ ! -z $vcs_info_msg_0_ ]]; then
        zl_add_left_segment $ZL_VCSBRANCH_DEC $ZL_VCSBRANCH_SDEC "$ZL_VCSBRANCH_ICON $vcs_info_msg_0_"
    fi
}

# Create a segment displaying the current relative path to the repository's root.
zl_segment_vcspath() {
    zstyle ':vcs_info:*' enable git svn hg
    zstyle ':vcs_info:git*' formats "%S"
    vcs_info
    if [[ ! -z $vcs_info_msg_0_ ]]; then
        zl_add_left_segment $ZL_VCSPATH_DEC $ZL_VCSPATH_SDEC "$ZL_VCSPATH_ICON $vcs_info_msg_0_"
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
        zl_add_left_segment $ZL_VCSMETA_DEC $ZL_VCSMETA_SDEC "$ZL_VCSMETA_ICON $vcs_info_msg_0_"
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
        zl_decorate_text $ZL_BASE_DEC $ZL_LEFTMIDDLEBEGIN
        echo -n $vcs_output
    fi
}

# Generate the top-right prompt.
zl_gen_rightup_prompt() {
    zl_decorate_text $ZL_BASE_DEC $ZL_RIGHTUPBEGIN
}

# Generate the bottom-right prompt.
zl_gen_rightdown_prompt() {
    zl_decorate_text $ZL_BASE_DEC $ZL_RIGHTDOWNBEGIN
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
    zl_decorate_text $ZL_POINTER_DEC $ZL_PROMPTPOINTER
    echo -n " "
}

# Generate the right prompt.
# Does not work properly at the moment
zl_gen_rprompt() {
    zl_gen_rightup_prompt
    echo
    zl_gen_rightdown_prompt
}

# Generate the full prompt (final result).
zl_gen_full_prompt() {
    zl_make_configs
    PROMPT='$(zl_gen_prompt)'
    #RPROMPT='$(zl_gen_rprompt)'
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
    
    # Colour of the prompt.
    zl_make_default ZL_BASE_DEC "$(zl_make_decoration 147 ! ! )"
    # Colour of the prompt pointer.
    zl_make_default ZL_POINTER_DEC "$(zl_make_decoration 46 ! ! )"

    # Icon at the start of the segment that displays your username.
    zl_make_default ZL_USERNAME_ICON ⚉
    # Colour of your username.
    zl_make_default ZL_USERNAME_DEC "$(zl_make_decoration 177 ! ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_USERNAME_SDEC "$(zl_make_decoration 147 ! ! )"

    # Icon at the start of the segment that displays your hostname.
    zl_make_default ZL_HOSTNAME_ICON 🖵
    # Colour of your hostname.
    zl_make_default ZL_HOSTNAME_DEC "$(zl_make_decoration 197 ! ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_HOSTNAME_SDEC "$(zl_make_decoration 147 ! ! )"
    
    # Icon at the start of the segment that displays your current working directory.
    zl_make_default ZL_PATH_ICON ⤇
    # Colour of your current working directory.
    zl_make_default ZL_PATH_DEC "$(zl_make_decoration 214 ! ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_PATH_SDEC "$(zl_make_decoration 147 ! ! )"
    
    # Symbol used to indicate that you are logged into the terminal as a normal user.
    zl_make_default ZL_USER_PROMPTTOKEN \$
    # Symbol used to indicate that you are logged into the terminal as root.
    zl_make_default ZL_ROOT_PROMPTTOKEN \#
    # Colour of the prompt token.
    zl_make_default ZL_PROMPTTOKEN_DEC "$(zl_make_decoration 255 ! ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_PROMPTTOKEN_SDEC "$(zl_make_decoration 147 ! ! )"
    
    # Icon at the start of the segment that displays the VCS system used in this directory.
    zl_make_default ZL_VCSSYSTEM_ICON 
    # Colour for the name of the VCS system used in the current working directory.
    zl_make_default ZL_VCSSYSTEM_DEC "$(zl_make_decoration 235 197 ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_VCSSYSTEM_SDEC "$(zl_make_decoration 147 ! ! )"
    
    # Icon at the start of the segment that displays the current branch.
    zl_make_default ZL_VCSBRANCH_ICON 
    # Colour for the name of the current branch in the current repo.
    zl_make_default ZL_VCSBRANCH_DEC "$(zl_make_decoration 235 214 ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_VCSBRANCH_SDEC "$(zl_make_decoration 147 ! ! )"

    # Icon at the start of the segment that displays the current working directory relative to the root of the repository.
    zl_make_default ZL_VCSPATH_ICON ⤇
    # Colour for the current path relative to the root of the repo.
    zl_make_default ZL_VCSPATH_DEC "$(zl_make_decoration 235 46 ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_VCSPATH_SDEC "$(zl_make_decoration 147 ! ! )"
    
    # Icon at the start of the segment that displays the repository's meta info.
    zl_make_default ZL_VCSMETA_ICON 🛈
    # Colour for meta data about the current repo.
    zl_make_default ZL_VCSMETA_DEC "$(zl_make_decoration 255 62 ! )"
    # Colour of the segment delimiters.
    zl_make_default ZL_VCSMETA_SDEC "$(zl_make_decoration 147 ! ! )"
    
    # Icon used to indicate the presence of an unstaged action.
    zl_make_default ZL_VCSMETA_UNSTAGED_ICON +
    # Icon used to indicate the presence of a staged but uncommitted action.
    zl_make_default ZL_VCSMETA_STAGED_ICON ✓
}

zl_gen_full_prompt