[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export PATH=/usr/local/bin:$PATH

alias c=charon
alias ch="charon -a helios"
alias chf="charon -a helios fab"
alias cfb="charon -a helios fab build"
alias helios="cd ~/src/helios"
alias hegemon="cd ~/src/hegemon"

export VAGRANT_DEFAULT_PROVIDER=vmware_fusion
export HEGEMON_DEFAULT_APP=helios
export HEGEMON_ENVIRONMENT=vagrant
export PATH=$PATH:~/src/hegemon/scripts

# run corresponding test file for all commits
HELIOS_PRECOMMIT_TESTS=true

# get current branch in git repo
function parse_git_branch() {
        BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
        if [ ! "${BRANCH}" == "" ]
        then
                STAT=`parse_git_dirty`
                echo "[${BRANCH}${STAT}]"
        else
                echo ""
        fi
}

# get current status of git repo
function parse_git_dirty {
        status=`git status 2>&1 | tee`
        dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
        deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
        bits=''
        if [ "${renamed}" == "0" ]; then
                bits=">${bits}"
        fi
        if [ "${ahead}" == "0" ]; then
                bits="*${bits}"
        fi
        if [ "${newfile}" == "0" ]; then
                bits="+${bits}"
        fi
        if [ "${untracked}" == "0" ]; then
                bits="?${bits}"
        fi
        if [ "${deleted}" == "0" ]; then
                bits="x${bits}"
        fi
        if [ "${dirty}" == "0" ]; then
                bits="!${bits}"
        fi
        if [ ! "${bits}" == "" ]; then
                echo " ${bits}"
        else
                echo ""
        fi
}

rr() {
   # random recent committer
   git status >/dev/null 2>&1
   if [[ $? -ne 0 ]]; then
       echo "Not a git repo"
       return 128
   fi
   if [[ ! -s .consume-committers ]]; then
          # ignore: self, non-canonical versions of Brett, Mary, Maxwell
   local BLACKLIST="Richard Howard\|Brett W\|^Mary$\|^Maxwell"
   git log --since="-1 month" \
     | sed -n -e "/^Author: /s/^Author: \([^<]\+\).*$/\1/p;" \
     | sed 's/ *$//' \
     | grep -v "$BLACKLIST" \
     | sort -u \
     | shuf \
     > .consume-committers
   fi
   committers="$(< .consume-committers)"
   echo "$committers" | ghead -n -1 > .consume-committers
   echo "$committers" | tail -n 1
}

export PS1="\u@\[\e[40m\]\h\[\e[m\] \W \`parse_git_branch\` "
