#!/bin/bash

account_addr=""
docker_swarm_started=0

abort() {
  if [ $docker_swarm_started -eq 1 ]; then
    echo "Shutting down docker swarm"
    echo ""
    docker swarm leave --force
  fi
  echo "$1"
  exit 1 >&2
}

execute_sudo() {
  sudo bash -c "$1"
}

execute_interactive_docker_command() {
  docker exec -e account_addr=$account_addr -it "${container_id}" bash -c "$1; (exit \$?)"
  exit_code=$?
  if [ $exit_code -eq 130 ]; then
    exit $exit_code >&2
  fi
  if [ $exit_code -ne 0 ]; then
    echo "Error executing command. Please try again or press CTRL-C to exit."
    execute_interactive_docker_command "$1"
  fi
}

execute_docker_command() {
  docker exec -e account_addr=$account_addr "${container_id}" bash -c "$1"
}

get_node_status() {
    current_node_round=$(execute_docker_command 'goal node lastround | head -n 1')
    current_net_round=$(curl -s https://testnet-api.voi.nodly.io/v2/status | jq -r '.["last-round"]' )
    current_node_round=${current_node_round//[!0-9]/}
}

catchup_node() {
  display_banner "Catching up with network... This may take a while ..."
  get_node_status
  while [ "$current_node_round" -lt "$current_net_round" ]; do
    rounds_to_go=$(($current_net_round-$current_node_round))
    if [ $rounds_to_go -gt 1 ]; then
      echo "Waiting for catchup: $rounds_to_go blocks to go"
    else
      echo "One more to go!"
    fi
    get_node_status
    sleep 10
  done
  display_banner "Caught up with the network!"
}

get_addr_balanace() {
    balance=$(execute_docker_command 'goal account balance -a "${account_addr}"')
    balance=${balance//[!0-9]/}
}

busy_wait_until_balance_is_1_voi() {
  display_banner "Waiting for balance (account: $account_addr) to be 1 Voi"
  get_addr_balanace
  while [ "$balance" -lt "1000000" ]; do
    echo "Waiting for balance to be 1 Voi"
    get_addr_balanace
    sleep 10
  done
  display_banner "Balance is 1 Voi!"
}

get_account_addr() {
  account_addr=$(execute_docker_command 'goal account list | head -n 1 | awk '\''{print $3}'\''')
  account_addr=${account_addr//[!0-9a-zA-Z]/}
}

display_banner() {
  echo
  echo "******************************************"
  echo "* $1"
  echo "******************************************"
  echo
}

docker_swarm_instructions() {
  echo "Error initializing Docker Swarm."
  echo "Set VOINETWORK_DOCKER_SWARM_INIT_SETTINGS to the settings you want to use to initialize Docker Swarm and try again."
  echo "Example: export VOINETWORK_DOCKER_SWARM_INIT_SETTINGS='--advertise-addr 10.0.0.1'"
  exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

if [ "$(uname)" != "Linux" ]; then
  abort "This script is only meant to run on Linux."
fi

display_banner "Installing Docker"

execute_sudo "apt-get update"
execute_sudo "apt-get install -y ca-certificates curl gnupg"
execute_sudo "install -m 0755 -d /etc/apt/keyrings"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | execute_sudo "gpg -n --dearmor -o /etc/apt/keyrings/docker.gpg"
execute_sudo "chmod a+r /etc/apt/keyrings/docker.gpg"

execute_sudo "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

if [ -z "$(docker --version | grep 'Docker version')" ]; then
  abort "Docker installation failed."
fi

## Install script dependencies
execute_sudo "apt-get install -y jq"

display_banner "Starting stack"

if [[ -n ${VOINETWORK_DOCKER_SWARM_INIT_SETTINGS} ]]; then
  docker swarm init ${VOINETWORK_DOCKER_SWARM_INIT_SETTINGS}
  if [ $? -ne 0 ]; then
    docker_swarm_instructions
  fi
else
  docker swarm init
  if [ $? -ne 0 ]; then
    docker_swarm_instructions
  fi
fi
docker_swarm_started=1

if [ ! -e ~/voi/algod ]; then
  mkdir -p ~/voi/algod/data
else
  abort "$HOME/voi/algod directory already exists. Possibly from a previous installation. Aborting to avoid conflict."
fi

display_banner "Downloading latest Voi Network swarm and utility scripts to $HOME/voi"
curl -L https://api.github.com/repos/VoiNetwork/docker-swarm/tarball/main --output ~/voi/docker-swarm.tar.gz
tar -xzf ~/voi/docker-swarm.tar.gz -C ~/voi --strip-components=1
rm ~/voi/docker-swarm.tar.gz

docker stack deploy -c ~/voi/compose.yml voinetwork

# Waiting for stack to be ready
while [ "$(docker service ls | grep voinetwork_algod | awk '{print $4}')" != "1/1" ]
do
  echo "Waiting for stack to be ready..."
  sleep 2
done
display_banner "Stack is ready!"

container_id=$(docker ps -q -f name=voinetwork_algod)

if [[ -n $VOINETWORK_SKIP_WALLET_SETUP && $VOINETWORK_SKIP_WALLET_SETUP -eq 1  ]]; then
  display_banner "Skipping wallet setup"
  echo "Your Docker container ID is: ${container_id}"
  echo "You can run the following command to enter the container:"
  echo "docker exec -it ${container_id} bash"
  echo ""
  echo "To see a list of useful commands reference:"
  echo " - Install README.md: https://github.com/VoiNetwork/docker-swarm/blob/main/README.md"
  echo " - Docker Swarm documentation: https://docs.docker.com/engine/swarm/"
  echo ""
  echo "Network catchup has been initiated and will continue in the background."
  exit 0
fi

display_banner "Setting up Voi wallets and accounts"

execute_interactive_docker_command "goal wallet new voi"

if [[ -n $VOINETWORK_IMPORT_ACCOUNT && $VOINETWORK_IMPORT_ACCOUNT -eq 1 ]]; then
  execute_interactive_docker_command "goal account import"
  get_account_addr
else
  execute_interactive_docker_command 'goal account new'
  get_account_addr

  # Get Voi from faucet
  echo "************************************************************************************"
  echo "*    To participate in the Voi network you must complete the following steps:"
  echo "*       1) Open the Voi Network Discord - https://discord.com/invite/vnFbrJrHeW"
  echo "*       2) Go to the #node-runners channel"
  echo "*       3) Type /voi-testnet-faucet ${account_addr}"
  echo "*    Once completed type 'completed' to continue"
  echo "************************************************************************************"

  read -p "After step 3 above type 'completed' to continue: " prompt
  while [ "$prompt" != "completed" ]
  do
    read -p "Type 'completed' to continue once you have completed step 3 above: " prompt
  done
fi

# Catchup node before creating participation key and going online
catchup_node

display_banner "Joining network"

execute_docker_command 'start=$(goal node status | grep "Last committed block:" | cut -d\  -f4) && duration=${duration:-2000000} && end=$((start + duration)) && goal account addpartkey -a ${account_addr} --roundFirstValid $start --roundLastValid $end'

busy_wait_until_balance_is_1_voi

execute_interactive_docker_command 'goal account changeonlinestatus -a "${account_addr}"'

account_status=$(execute_docker_command 'goal account dump -a "${account_addr}" | jq -r .onl')

if [ "$account_status" -eq 1 ]; then
  display_banner "Welcome to Voi! You are now online!"
  echo "IMPORTANT: Utility scripts for managing your setup are available in $HOME/voi/scripts"
  echo ""
else
  display_banner "ERROR: Your account $account_addr is offline."
  echo "Something went wrong going online. Reach out on #node-help on the Voi Network Discord for help."
  echo "https://discord.com/invite/vnFbrJrHeW"
  abort "Exiting."
fi

echo "SAVE THE FOLLOWING INFORMATION IN A SECURE PLACE"
echo "******************************************"
echo "Your Voi address is: ${account_addr}"
echo "Enter password to unlock your wallet and retrieve your account recovery mnemonic. Make sure to store your mnemonic in a secure location:"
execute_interactive_docker_command "goal account export -a $account_addr"