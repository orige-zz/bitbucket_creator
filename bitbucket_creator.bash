USER=$1;
PASSWORD=$2;
PROJECT=$3;

ROOT=`pwd`;
BITBUCKET_API_URL="https://api.bitbucket.org/2.0/repositories" # /{user}/{repo_name};
BITBUCKET_REPO="git@bitbucket.org"; # :{user}/{repo_name}.git";

back_to_root() {
    cd $ROOT;
}

# $1: exit code
my_exit() {
    back_to_root;
    exit $1;
}

# $1: repository directory
push_repository() {
    cd $1;
    git push origin master &> /dev/null
}

# $1: user/team
# $2: password
# $3: repository name
create_repository() {
    url="$BITBUCKET_API_URL/$1/$3";

    curl -X POST -v -u $1:$2 -H "Content-Type: application/json" \
    "$url" -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }' &> /dev/null
}

# $1: repository directory
repository_is_valid() {
    cd $1;
    git status &> /dev/null
}

# $1: bitbucket user
# $2: repository directory
update_repository_remote() {
    cd $2;
    git remote rm origin
    git remote add origin "$BITBUCKET_REPO:$1/$2.git";
}

# $1: repository directory
push_repository() {
    cd $1;

    # Push all branches quietly
    git push origin --all -q

    # Push all tags quietly
    git push origin --tags -q
}

# $1: message
log() {
    logfile=$ROOT/bitbucket_creator.log;
    if [[ -f $logfile ]]; then
        touch $logfile;
    fi

    echo $1 > $logfile;
}

directory=$PROJECT;

if [[ ! -d $directory ]]; then
    continue;
fi

repository_is_valid $directory;
if [[ $? > 0 ]]; then
    log "$directory Error: This is not a valid git repository";
    my_exit 1;
fi
back_to_root

# Backuping remote origin
cd $directory
git remote -v > bitbucket_remote.log
back_to_root

create_repository $USER $PASSWORD $directory;
if [[ $? > 0 ]]; then
    log "$directory Error: to create the new repository.. skipping";
    my_exit 1;
fi
back_to_root

update_repository_remote $USER $directory;
if [[ $? > 0 ]]; then
    log "$directory Error: on update the new repository origin.. skipping";
    my_exit 1;
fi
back_to_root

echo "Pushing $directory to the new repository ... ";
push_repository $directory;
if [[ $? > 0 ]]; then
    log "$diretory Error: on push the repository .. skipping";
    my_exit 1;
fi
back_to_root

my_exit 0;
