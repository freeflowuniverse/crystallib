<h1> Hero Webserver Container Docs </h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Deploy Webserver](#deploy-webserver)
- [Update Webserver](#update-webserver)

---

## Introduction

We provide the steps to deploy the Hero webserver locally and test changes.

## Prerequisites

- Make sure that you've read the [Crystallib and Hero Basics Docs](./crystallib_hero_basic_docs.md)

## Deploy Webserver

To deploy the hero Webserver, run the following script and enter the required input when asked.

```
mkdir -p ~/code/git.ourworld.tf

cd ~/code/git.ourworld.tf
git clone https://git.ourworld.tf/hero/hero_web

cd hero_web

dir=$(pwd)
mkdir -p $dir/example/heroscripts

# Define the name of the .env file
ENV_FILE=".env"

# Check if the .env file exists
if [[ -f "$ENV_FILE" ]]; then
    echo "$ENV_FILE already exists. No changes made. Make sure that it contains the authentication.hero content."
else
    echo "$ENV_FILE does not exist. Please enter the content to save in the file (press Enter on an empty line to finish):"

    # Initialize an array to hold user input
    lines=()

    # Read user input until an empty line is entered
    while true; do
        read -r line
        # Break the loop if the input line is empty
        if [[ -z "$line" ]]; then
            break
        fi
        # Append the line to the array
        lines+=("$line")
    done

    # Save the input to the .env file
    {
        for entry in "${lines[@]}"; do
            echo "$entry"
        done
    } > "$ENV_FILE"

    echo "Input has been saved to $ENV_FILE."
fi

cat .env > $(pwd)/example/heroscript

v -w -n -enable-globals run . example/heroscripts


```

## Update Webserver

You can update the content of the webserver in the crystallib subdirectory `/freeflowuniverse/crystallib/crystallib/webserver`.