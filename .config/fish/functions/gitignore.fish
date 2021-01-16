function gitignore --description 'Generate gitignore from gitignore.io'
    set --local BASE_URL https://gitignore.io/api
    set --local ARGS (string join ',' $argv)

    echo "$BASE_URL/$ARGS"

    curl "$BASE_URL/$ARGS" >> .gitignore
end