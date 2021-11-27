# I hate shell script

autoload -U colors && colors

zl_make_default() {
    if [[ -z $(eval echo \$$(echo $1)) ]]; then
        eval $1=$2
    fi
}

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

zl_reset() {
    echo -n "%{$reset_color%}"
}

zl_color_text() {
    # 1: fg
    # 2: bg
    # 3: text
    
    echo -n "$(zl_make_color $1 $2)$3$(zl_reset)"
}

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

zl_add_left_segment() {
    # 1: segment_fg
    # 2: segment_bg
    # 3: info_fg
    # 4: info_bg
    # 5: info
    
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_CONNECTOR
    zl_make_segment $1 $2 $3 $4 $5
}

zl_add_right_segment() {
    # 1: segment_fg
    # 2: segment_bg
    # 3: info_fg
    # 4: info_bg
    # 5: info
    
    zl_make_segment $1 $2 $3 $4 $5
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_CONNECTOR
}

zl_segment_user() {
    zl_add_left_segment $ZL_USERNAME_SFG $ZL_USERNAME_SBG $ZL_USERNAME_FG $ZL_USERNAME_BG "$ZL_USERNAME_ICON %n"
}

zl_segment_hostname() {
    zl_add_left_segment $ZL_HOSTNAME_SFG $ZL_HOSTNAME_SBG $ZL_HOSTNAME_FG $ZL_HOSTNAME_BG "$ZL_HOSTNAME_ICON %M"
}

zl_segment_path() {
    zl_add_left_segment $ZL_PATH_SFG $ZL_PATH_SBG $ZL_PATH_FG $ZL_PATH_BG "$ZL_PATH_ICON %~"
}

zl_gen_leftup_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_LEFTUPBEGIN
    zl_segment_user
    zl_segment_hostname
    zl_segment_path
}

zl_prompttoken_usercheck() {
    [[ $(whoami) == "root" ]] && echo -n $ZL_ROOT_PROMPTTOKEN || echo -n $ZL_USER_PROMPTTOKEN
}

zl_segment_prompttoken() {
    zl_add_left_segment $ZL_PROMPTTOKEN_SFG $ZL_PROMPTTOKEN_SBG $ZL_PROMPTTOKEN_FG $ZL_PROMPTTOKEN_BG $(zl_prompttoken_usercheck)
}

zl_gen_leftdown_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_LEFTDOWNBEGIN
    zl_segment_prompttoken
}

zl_segment_vcsbranch() {
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*' actionformats "%b"
    vcs_info
    if [[ ! -z ${vcs_info_msg_0_} ]]; then
        zl_add_left_segment $ZL_VCSBRANCH_SFG $ZL_VCSBRANCH_SBG $ZL_VCSBRANCH_FG $ZL_VCSBRANCH_BG "$ZL_VCSBRANCH_ICON ${vcs_info_msg_0_}"
    fi
}

zl_gen_leftvcs_prompt() {
    autoload -Uz vcs_info
    local vcs_output
    vcs_output="${vcs_output}$(zl_segment_vcsbranch)"
    if [[ ! -z $vcs_output ]]; then
        zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_LEFTMIDDLEBEGIN
        echo -n $vcs_output
    fi
}

zl_gen_rightup_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_RIGHTUPBEGIN
}

zl_gen_rightdown_prompt() {
    zl_color_text $ZL_BASE_FG $ZL_BASE_BG $ZL_RIGHTDOWNBEGIN
}

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

# Does not work properly at the moment
zl_gen_rprompt() {
    zl_gen_rightup_prompt
    echo
    zl_gen_rightdown_prompt
}

zl_make_configs() {
    zl_make_default ZL_LEFTUPBEGIN ╭
    zl_make_default ZL_LEFTMIDDLEBEGIN ├
    zl_make_default ZL_LEFTDOWNBEGIN ╰
    zl_make_default ZL_RIGHTUPBEGIN ╮
    zl_make_default ZL_RIGHTMIDDLEBEGIN ┤
    zl_make_default ZL_RIGHTDOWNBEGIN ╯
    zl_make_default ZL_CONNECTOR ─
    zl_make_default ZL_SEGMENTLEFT ┤
    zl_make_default ZL_SEGMENTRIGHT ├
    zl_make_default ZL_PROMPTPOINTER ➤
    
    zl_make_default ZL_BASE_FG magenta
    zl_make_default ZL_BASE_BG !
    zl_make_default ZL_POINTER_FG green
    zl_make_default ZL_POINTER_BG !
    
    zl_make_default ZL_USER_PROMPTTOKEN \$
    zl_make_default ZL_ROOT_PROMPTTOKEN \#

    zl_make_default ZL_USERNAME_ICON ⚉
    zl_make_default ZL_USERNAME_FG cyan
    zl_make_default ZL_USERNAME_BG !
    zl_make_default ZL_USERNAME_SFG magenta
    zl_make_default ZL_USERNAME_SBG !
    
    zl_make_default ZL_HOSTNAME_ICON 🖵
    zl_make_default ZL_HOSTNAME_FG red
    zl_make_default ZL_HOSTNAME_BG !
    zl_make_default ZL_HOSTNAME_SFG magenta
    zl_make_default ZL_HOSTNAME_SBG !
    
    zl_make_default ZL_PATH_ICON ⤇
    zl_make_default ZL_PATH_FG yellow
    zl_make_default ZL_PATH_BG !
    zl_make_default ZL_PATH_SFG magenta
    zl_make_default ZL_PATH_SBG !
    
    zl_make_default ZL_PROMPTTOKEN_FG white
    zl_make_default ZL_PROMPTTOKEN_BG !
    zl_make_default ZL_PROMPTTOKEN_SFG magenta
    zl_make_default ZL_PROMPTTOKEN_SBG !
    
    zl_make_default ZL_VCSBRANCH_ICON 
    zl_make_default ZL_VCSBRANCH_FG black
    zl_make_default ZL_VCSBRANCH_BG green
    zl_make_default ZL_VCSBRANCH_SFG magenta
    zl_make_default ZL_VCSBRANCH_SBG !
}

zl_make_configs

get_ssh_url() {
}

PROMPT="$(zl_gen_prompt)"
#RPROMPT="$(zl_gen_rprompt)"