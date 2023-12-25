
function gitcheck {
    # Check if Git email is set
    if [ -z "$(git config user.email)" ]; then
        # If not set, prompt the user to enter it
        echo "Git email is not set."
        read -p "Enter your Git email: " git_email

        # Set the Git email
        git config --global user.email "$git_email"
        echo "Git email set to '$git_email'."
    else
        # Git email is already set
        echo "Git email is set to: $(git config user.email)"
    fi
}


function github_keyscan {
    mkdir -p ~/.ssh
    if ! grep github.com ~/.ssh/known_hosts > /dev/null
    then
        ssh-keyscan github.com >> ~/.ssh/known_hosts
    fi
    git config --global pull.rebase false

}

# function mycommit {
#     gitcheck
#     # Check if we are inside a Git repository
#     if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
#         git_root=$(git rev-parse --show-toplevel)
#         echo "You are inside a Git repository $git_root."
#         pushd "$git_root"        
#     else
#         echo commit crystallib
#         pushd "$DIR_CODE/github/freeflowuniverse/crystallib"  2>&1 > /dev/null
#     fi
#     if [[ -z "$sshkeys" ]]; then
#         echo
#     else
#         git remote set-url origin git@github.com:freeflowuniverse/crystallib.git
#     fi          
#     if [[ $(git status -s) ]]; then
#         echo There are uncommitted changes.
#         git add . -A
#         echo "Please enter a commit message:"
#         read commit_message
#         git commit -m "$commit_message"
#         git pull
#         git push
#     else
#         echo "no changes"
#     fi
#     popd   2>&1 >/dev/null
# }





