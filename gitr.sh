# gitr sync             : fetch --all pull
# gitr start release    : branch from develop
# gitr start feature
# gitr start tooling
# gitr start bugfix     : branch from master
# gitr publish          : push to origin
# gitr list
gitr-init () {
    if [[ $#@ == 0 ]]; then
        echo Need to specify a remote
        return
    fi

    \git init
    \git add .
    \git commit -am 'initial commit'
    \git remote add origin "$1"
    \git checkout -b develop
    \git push --all
}

gitr-start () {
    local cmd=$1
    local -a commands=(release feature tooling bugfix)
    -gitr-start-help () {
        echo Commands: $commands 
    }
    if [[ $#@ -le 1 ]]; then
        -gitr-start-help
        return 1
    fi

    shift 1
    local branch=$(echo $@ | sed -e 's/\ /-/g' -e 's/.*/\L&/')

    -gitr-start-branch () {
        \git checkout -b $1 develop
    } 

    if [[ ${commands[(r)$cmd]} == $cmd ]]; then
        -gitr-start-branch "$cmd/$branch"
    else
        -gitr-start-help
        return 1
    fi
}

gitr-sync () {
    \git fetch --all
    \git pull
}

gitr-publish () {
    #\git rebase -i HEAD..develop
    \git push -u origin $(git rev-parse --abbrev-ref HEAD)
    # TODO add event/callback/function to hook
    # in order to have a custom command
}

gitr-list () {
    \git branch -la
}

gitr-help () {
        echo "gitr sync             : fetch --all pull
gitr start release    : branch from develop
gitr start feature
gitr start tooling
gitr start bugfix     : branch from master
gitr publish          : push to origin
gitr list"

}

gitr () {
    local cmd=$1
    if [[ ! "$cmd" == "init" && ! -d $PWD/.git ]]; then
        echo Run this command inside a git repository
        return 1
    fi

    if functions "gitr-$cmd" &> /dev/null; then
        shift 1
        gitr-$cmd $@
    else
        \git "$@"
    fi
}

# Overwrite git command
# if no gitr command is found it fallback to git
#git () {
#    gitr "$@"
#}
