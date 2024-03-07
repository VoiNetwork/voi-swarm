#!/bin/bash

account_addr=""
docker_swarm_started=0
voi_home="${HOME}/voi"
headless_install=0
is_root=0
skip_account_setup=0
migrate_host_based_setup=0

bold=$(tput bold)
normal=$(tput sgr0)

execute_sudo() {
  if [[ ${is_root} -eq 1 ]]; then
    bash -c "$1"
  else
    sudo bash -c "$1"
  fi
}

abort() {
  if [[ ${docker_swarm_started} -eq 1 ]]; then
    echo "Shutting down docker swarm"
    echo ""
    execute_sudo 'docker swarm leave --force'
  fi
  echo "$1"
  exit 1
}

execute_docker_command_internal() {
  local interactive=$1
  local command=$2
  local options=""

  if [[ $interactive = "yes" ]]; then
    options="-it"
  fi

  execute_sudo "docker exec -e account_addr=${account_addr} ${options} \"${container_id}\" bash -c \"${command}\""
}

execute_interactive_docker_command() {
  local retries=0
  while [[ $retries -lt 10 ]]; do
    execute_docker_command_internal "yes" "$1"
    local exit_code=$?
    if [[ ${exit_code} -eq 130 ]]; then
      exit ${exit_code} >&2
    fi
    if [[ ${exit_code} -ne 0 ]]; then
      echo "Error executing command. Please try again or press CTRL-C to exit."
      ((retries++))
    else
      break
    fi
  done

  if [[ $retries -eq 10 ]]; then
    abort "Command failed after 10 attempts. Exiting the program."
  fi
}

execute_docker_command() {
  execute_docker_command_internal "no" "$1"
}

cleanup_deprecated_files_and_folders() {
  if [[ -d ${voi_home}/docker-swarm ]]; then
    rm -rf "${voi_home}/docker-swarm" 2>/dev/null || echo "Failed to delete deprecated folder: ${voi_home}/docker-swarm"
  fi
}

start_docker_swarm() {
  local docker_swarm
  docker_swarm=$(execute_sudo 'docker info | grep Swarm | cut -d\  -f3')
  if [[ ${docker_swarm} != "active" ]]; then
    command="docker swarm init"

    if [[ -n ${VOINETWORK_DOCKER_SWARM_INIT_SETTINGS} ]]; then
      command+=" ${VOINETWORK_DOCKER_SWARM_INIT_SETTINGS}"
    else
      command+=" --listen-addr lo --advertise-addr 127.0.0.1"
    fi

    execute_sudo "$command"

    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      docker_swarm_instructions
    fi

    docker_swarm_started=1
  fi
}

start_stack() {
  command="env VOINETWORK_TELEMETRY_NAME=$VOINETWORK_TELEMETRY_NAME docker stack deploy -c ${voi_home}/docker/compose.yml"

  if [[ -f "${voi_home}/docker/notification.yml" ]]; then
      command+=" -c ${voi_home}/docker/notification.yml"
  fi

  command+=" voinetwork"
  execute_sudo "$command"

  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]]; then
    abort "Error starting stack. Exiting the program."
  fi
}

# shellcheck disable=SC2120
wait_for_stack_to_be_ready() {
  while true; do
    service_info=$(execute_sudo 'docker stack ps voinetwork --format json')
    stack_ready=true

    while read -r line; do
      current_state=$(echo "${line}" | jq -r '.CurrentState')
      desired_state=$(echo "${line}" | jq -r '.DesiredState')

      service_error=$(echo "${line}" | jq -r '.Error')

      if [[ (${desired_state} == "Ready" || ${desired_state} == "Running") && ${current_state} != Running* ]]; then
        stack_ready=false
        break
      fi
    done < <(echo "${service_info}")

    if [[ ${stack_ready} == false && -n ${service_error} ]]; then
      local number_of_interfaces
      number_of_interfaces=$(execute_sudo "ip -d link show | grep vx | wc -l")
      if [[ number_of_interfaces -le 2 ]]; then
        echo "Docker has a network interface that is lingering and preventing startup. We'll attempt to auto-delete it."
        execute_sudo "ip -d link show | grep vx | grep DOWN | awk '{print $2}' | tr -d ':' | xargs -rn1 ip link delete"
        # shellcheck disable=SC2181
        if [[ $? -ne 0 ]]; then
          echo "Docker swarm is unable to start services. https://github.com/moby/libnetwork/issues/1765"
          abort "Exiting the program."
        fi
      elif [[ number_of_interfaces -ge 3 ]]; then
        echo "Docker swarm is unable to start services. https://github.com/moby/libnetwork/issues/1765"
        abort "Multiple vx interfaces found. Please delete all vx interfaces or reboot the server"
      fi
    fi

    echo "Waiting for stack to be ready..."
    sleep 2

    if [[ ${stack_ready} == true ]]; then
      break
    fi
  done

  display_banner "Stack is ready!"
}

verify_node_is_running() {
  local retries=0
  local max_retries=5

  while [[ $retries -lt $max_retries ]]; do
    container_id=$(execute_sudo "docker ps -q -f name=voinetwork_algod")
    if [[ -n "$container_id" ]]; then
      execute_sudo "docker exec ${container_id} bash -c \"curl -sS http://localhost:8080/health > /dev/null\""
      local exit_code=$?
      if [[ $exit_code -eq 0 ]]; then
        break
      fi
    fi

    echo "Error connecting to node. Retrying in 10 seconds..."
    sleep 10
    ((retries++))
  done

  if [[ $retries -eq $max_retries ]]; then
    abort "Error connecting to node after $max_retries attempts. Exiting the program."
  fi
}

get_current_net_round() {
  local retries=0
  local max_retries=5

  while [[ $retries -lt $max_retries ]]; do
    current_net_round=$(curl -s https://testnet-api.voi.nodly.io/v2/status | jq -r '.["last-round"]' )
    exit_code=$?

    if [[ $exit_code -eq 0 ]] && [[ -n $current_net_round ]]; then
      break
    fi

    echo "Error fetching network status. Retrying in 5 seconds..."
    sleep 5
    ((retries++))
  done

  if [[ $retries -eq $max_retries ]]; then
    abort "Error fetching network status after $max_retries attempts. Please check your internet connection and try again."
  fi
}

get_node_status() {
    current_node_round=$(execute_docker_command 'goal node lastround | head -n 1')
    get_current_net_round
    current_node_round=${current_node_round//[!0-9]/}
}

catchup_node() {
  display_banner "Catching up with the network... This might take some time, and numbers might briefly increase"
  get_node_status
  while [[ ${current_node_round} -lt ${current_net_round} ]]; do
    rounds_to_go=$((current_net_round - current_node_round))
    if [[ ${rounds_to_go} -gt 1 ]]; then
      printf "\rWaiting for catchup: %d blocks to go                     " "${rounds_to_go}"
    else
      printf "\rWaiting for catchup: One more block to go!                                           "
    fi
    get_node_status
    sleep 5
  done
  display_banner "Caught up with the network!"
}

create_wallet() {
  if [[ $(execute_docker_command "goal wallet list | wc -l") -eq 1 ]]; then
    echo "Let's create a new wallet for you. Please provide a password for security."
    echo "Seeing the wallet's mnemonic is optional. Any Voi will be linked with the account we'll create or import after wallet creation."

    execute_interactive_docker_command "goal wallet new voi"
  else
    echo "Wallet already exists. Skipping wallet creation."
  fi
}

get_address_balance() {
    balance=$(execute_docker_command "goal account balance -a ${account_addr}")
    balance=${balance//[!0-9]/}
}

busy_wait_until_balance_is_1_voi() {
  display_banner "Waiting for balance (account: ${account_addr}) to be 1 Voi"
  get_address_balance
  while [[ ${balance} -lt "1000000" ]]; do
    echo "Waiting for balance to be 1 Voi at minimum"
    get_address_balance
    sleep 10
  done
  display_banner "Account has balance of 1 Voi or greater!"
}

get_account_info() {
  allow_one_account=$1

  if execute_sudo 'test ! -f "/var/lib/voi/algod/data/voitest-v1/accountList.json"'; then
    abort "Account list not found. Exiting the program."
  fi

  accounts_json=$(execute_sudo 'cat /var/lib/voi/algod/data/voitest-v1/accountList.json')
  number_of_accounts=$(echo "${accounts_json}" | jq '.Accounts | length')

  if [[ $number_of_accounts -gt 1 ]]; then
    echo "More than one account found in wallet. Skipping account creation."
    skip_account_setup=1
    return 1
  elif [[ $number_of_accounts -eq 1 ]] && [[ $allow_one_account != "true" ]]; then
    echo "One account found in wallet. Skipping account creation."
    get_account_address
    skip_account_setup=1
    return 1
  fi

  account_address=$(echo "$accounts_json" | jq '.Accounts | keys[0]')
  echo "${account_address}"
}

check_if_account_exists() {
  allow_one_account_override="$1"

  get_account_info "$allow_one_account_override" > /dev/null
}

get_account_address() {
  account_address=$(get_account_info true)
  account_address=${account_address//\"/}

  if [[ ! "${account_address}" =~ ^[A-Za-z0-9]{58}$ ]]; then
    abort "Invalid account address: \"${account_address}\""
  fi

  account_addr=$account_address
}

get_participation_expiration_eta() {
  local active_key_last_valid_round=$1
  local last_committed_block=$2
  local current_key_blocks_remaining=$((active_key_last_valid_round - last_committed_block))
  local remaining_seconds
  local current_timestamp
  local expiration_timestamp
  local expiration_date

  remaining_seconds=$(echo "${current_key_blocks_remaining}*2.9" | bc)
  current_timestamp=$(date +%s)
  expiration_timestamp=$(echo "${current_timestamp}+${remaining_seconds}" | bc)

  # Convert the new timestamp to a date and time
  expiration_date=$(date -d "@${expiration_timestamp}" '+%Y-%m-%d %H:%M')

  echo "${expiration_date}"
}

get_current_keys_info() {
  execute_docker_command "goal account listpartkeys" | tail -n +2
}

get_last_committed_block() {
  execute_docker_command "goal node status" | grep 'Last committed block' | cut -d\  -f4 | tr -d '\r'
}

generate_new_key() {
  local start_block
  local end_block
  local expiration_date

  start_block=$(get_last_committed_block)
  end_block=$((start_block + 2000000))
  expiration_date=$(get_participation_expiration_eta "${end_block}" "${start_block}")
  echo "Generating participation key for account ${account_addr} with start block ${start_block} and end block ${end_block}"
  echo "New key is expected to be valid until: ${expiration_date}"
  execute_interactive_docker_command "goal account addpartkey -a ${account_addr} --roundFirstValid ${start_block} --roundLastValid ${end_block}"
}

generate_participation_key() {
  local current_keys_info
  local active_key_last_valid_round
  local last_committed_block

  display_banner "Generating/Updating participation key"

  current_keys_info=$(get_current_keys_info)
  active_key_last_valid_round=$(echo "$current_keys_info" | awk '/yes/ {print $NF}')
  last_committed_block=$(get_last_committed_block)

  if [[ -z ${active_key_last_valid_round} ]]; then
    generate_new_key
  elif [[ $((active_key_last_valid_round-last_committed_block)) -le 417104 ]]; then
    local existing_expiration_date
    local new_expiration_date
    local current_key_prefix
    local current_key_id
    local end_block

    end_block=$((last_committed_block + 2000000))
    existing_expiration_date=$(get_participation_expiration_eta "${active_key_last_valid_round}" "${last_committed_block}")
    new_expiration_date=$(get_participation_expiration_eta "${end_block}" "${last_committed_block}")

    current_key_prefix=$(echo "$current_keys_info" | awk '/yes/ {print $3}' | tr -d .)
    current_key_id=$(execute_docker_command "goal account partkeyinfo" | grep "${current_key_prefix}" | awk '{print $3}')

    echo "Current participation key is expected to expire at: ${existing_expiration_date}"
    echo "Currently the network is at block: ${last_committed_block}"
    echo "Current participation key expires at block: ${active_key_last_valid_round}"
    echo ""
    echo "This is below the required threshold of 417,104 blocks / ~14 days."
    echo "Generating participation key for account ${account_addr} with end block ${end_block}."

    echo "New key is expected to be valid until: ${new_expiration_date}"
    echo ""
    echo "You will be asked to enter your password to activate the new key."

    execute_interactive_docker_command "goal account renewpartkey -a ${account_addr} --roundLastValid ${end_block}"
    execute_interactive_docker_command "goal account deletepartkey --partkeyid ${current_key_id}"
  else
    local existing_expiration_date
    existing_expiration_date=$(get_participation_expiration_eta "${active_key_last_valid_round}" "${last_committed_block}")

    echo "Current participation key is expected to expire at: ${existing_expiration_date}"
    echo "This is above the required threshold of 417,104 blocks / ~14 days."
    echo "No new participation key will be generated."
  fi
}

display_banner() {
  echo
  echo "********************************************************************************"
  echo "* $1"
  echo "********************************************************************************"
  echo
}

docker_swarm_instructions() {
  echo ""
  echo "Error initializing Docker Swarm."
  echo ""
  echo "To fix this, set VOINETWORK_DOCKER_SWARM_INIT_SETTINGS to the settings you want to use to initialize Docker Swarm and try again."
  echo "Parameters that can be passed to the swarm can be found at: https://docs.docker.com/engine/reference/commandline/swarm_init/"
  echo ""
  echo "Join #node-resources on Discord (https://discord.com/invite/vnFbrJrHeW) to engage with the community and get help."
  abort "Exiting the program."
}

joined_network_instructions() {
  echo "You can find utility commands for managing your setup in ${voi_home}/bin"

  if [[ ${is_root} -eq 0 ]]; then
    echo ""
    echo "Ensure you restart your shell to use them, or type 'newgrp docker' in your existing shell before using."
  fi

  echo ""
  echo "For a list of useful commands, check out:"
  echo " - Install README.md: https://github.com/VoiNetwork/voi-swarm/blob/main/README.md"
  echo " - Docker Swarm documentation: https://docs.docker.com/engine/swarm/"
  echo ""
  if [[ ${skip_account_setup} -eq 1 ]]; then
    if [[ -z ${account_addr} ]]; then
      echo "No new account was created because your wallet already has multiple accounts."
    else
      echo "No new account was made because you already have an account with the address: ${account_addr}"
    fi

    echo ""
    echo "To see network participation status use ${HOME}/voi/bin/get-participation-status ${account_addr}"
    echo "To go online use ${HOME}/voi/bin/go-online ${account_addr}"
  fi

  # Display information informing the user that the network will catch up in the background if used in non-interactive mode
  if [[ $1 == "true" ]]; then
    echo ""
    echo "The network is now catching up and will continue to do so in the background."
  fi

  echo ""
  echo "To easily access commands from ${HOME}/voi/bin, add the following to ${HOME}/.bashrc or ${HOME}/.profile:"
  echo "export PATH=\"\$PATH:${HOME}/voi/bin\""
  echo ""
}

join_as_new_user() {
  display_banner "Joining network"

  generate_participation_key

  busy_wait_until_balance_is_1_voi

  echo "Enter your password to join the network."
  execute_interactive_docker_command "goal account changeonlinestatus -a ${account_addr}"

  account_status=$(execute_docker_command "goal account dump -a ${account_addr}" | jq -r .onl)

  ## This step is late in the process and does require a restart of the service to take effect.
  ## Container ID from verify_node_running will have to be re-fetched if any use of the node is to be done after this point.
  ## Intentionally not doing this here to avoid confusion.
  migrate_host_based_voi_setup

  if [[ ${account_status} -eq 1 ]]; then
    display_banner "Welcome to Voi! You are now online!"
  else
    display_banner "Your account ${account_addr} is currently offline."
    echo "There seems to be an issue with going online. Please seek assistance in the #node-runner channel on the Voi Network Discord."
    echo "Join us at: https://discord.com/invite/vnFbrJrHeW"
    abort "Exiting the program."
  fi

  echo "PLEASE SAVE THIS INFORMATION SAFELY"
  echo "***********************************"
  echo "Your Voi address: ${account_addr}"
  echo "Enter password to get your Voi account recovery mnemonic. Store your mnemonic safely:"

  execute_interactive_docker_command "goal account export -a ${account_addr}"
}

add_docker_groups() {
  if [[ is_root -eq 0 ]]; then
    if [[ ! $(getent group docker)  ]]; then
      execute_sudo "groupadd docker"
    fi
    execute_sudo "usermod -aG docker ${USER}"
  fi
}

get_telemetry_name() {
  if [[ -f "/var/lib/voi/algod/data/logging.config" ]]; then
    VOINETWORK_TELEMETRY_NAME=$(execute_sudo "cat /var/lib/voi/algod/data/logging.config" | jq -r '.Name')
  fi
}

set_telemetry_name() {
  if [[ ${headless_install} -eq 1 ]]; then
    ## Allow headless install to skip telemetry name setup in case people bring their own wallets / use CI
    return
  fi

  detect_existing_host_based_setup

  if [[ ${migrate_host_based_setup} -eq 1 ]]; then
    return
  fi

  display_banner "Telemetry"

  if [[ -z ${VOINETWORK_TELEMETRY_NAME} && ! -f "/var/lib/voi/algod/data/logging.config" ]]; then
    echo "Voi uses telemetry to make the network better and reward users with Voi if participating."
    echo ""
    echo "If you wish to opt-in to telemetry sharing, you can provide a telemetry name below."
    echo "We'll add 'VOI:' at the start to show you're using this package."
    echo ""
    echo "To skip telemetry sharing, type 'opt-out' below."
    echo ""
    echo "Visit https://voinetwork.github.io/voi-swarm/getting-started/telemetry/ to learn how to set your own custom name."
    echo ""
    echo "Enter your telemetry name below to get started."
    # shellcheck disable=SC2162
    read -p "Telemetry name: " VOINETWORK_TELEMETRY_NAME
    if [[ ${VOINETWORK_TELEMETRY_NAME} == "opt-out" ]]; then
      unset VOINETWORK_TELEMETRY_NAME
      return
    else
      VOINETWORK_TELEMETRY_NAME="VOI:$VOINETWORK_TELEMETRY_NAME"
    fi
  elif [[ -n ${VOINETWORK_TELEMETRY_NAME} ]]; then
    echo "Your telemetry name is already set to '${VOINETWORK_TELEMETRY_NAME}'. To change your telemetry settings, execute the command ${HOME}/voi/bin/set-telemetry-name"
  else
    echo "Telemetry is disabled. To enable telemetry, execute the command ${HOME}/voi/bin/set-telemetry-name"
  fi
}

detect_existing_host_based_setup() {
  if [[ -f /var/lib/algorand/logging.config && ! -f /var/lib/voi/algod/data/logging.config ]]; then
    echo "An existing Voi or Algorand installation has been detected on your system."
    echo "We can migrate your existing telemetry configuration to Voi Swarm."
    echo "As part of this process, we will also stop and uninstall the existing service."
    echo "This is necessary to prevent conflicts and ensure that your node can join Voi Swarm as a healthy node."
    echo ""
    echo "Do you want to migrate your existing setup to Voi Swarm? (yes/no)"
    # shellcheck disable=SC2162
    read -p "Migrate existing setup: " prompt
    while [[ ${prompt} != "yes" && ${prompt} != "no" ]]
      do
      # shellcheck disable=SC2162
        read -p "Type either yes or no: " prompt
    done
    if [[ ${prompt} == "yes" ]]; then
      migrate_host_based_setup=1
    fi
  fi
}

migrate_host_based_voi_setup() {
    if [[ ${migrate_host_based_setup} -eq 1 ]]; then
      display_banner "Migrating from host-based setup"
      VOINETWORK_TELEMETRY_NAME=$(execute_sudo "cat /var/lib/algorand/logging.config" | jq -r '.Name')
      bash -c "env VOINETWORK_TELEMETRY_NAME=\"${VOINETWORK_TELEMETRY_NAME}\" ${voi_home}/bin/migrate-from-host-setup"
    fi
}

check_minimum_requirements() {
  if [[ ${headless_install} -eq 1 ]]; then
    ## Allow headless install to skip telemetry name setup in case people bring their own wallets / use CI
    return
  fi

  echo "Checking system requirements.."
  echo ""

  num_cores=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

  total_memory=$(grep MemTotal /proc/meminfo | awk '{print $2}')

  # Check if the number of cores is less than 4 and less (8 GB * 0.8) memory. Reported memory from
  # /proc/meminfo prints out accessible memory, not total memory. We use 80% of the total memory as an approximation,
  # intentionally going too low to allow variability from various cloud providers.
  if [[ ${num_cores} -lt 4 || ${total_memory} -lt 6710886 ]]; then
    echo "*************************************************************************************"
    echo "* ${bold}WARNING: Your system does not meet the minimum requirements to run Voi Swarm effectively.${normal}"
    echo "*************************************************************************************"
    echo "*"
    echo "* Voi Swarm requires at least 4 CPU cores and 8 GB of memory to run effectively."
    echo "*"
    echo "* Your system has:"
    echo "* - CPU cores: ${bold}${num_cores}${normal} CPU cores. ${bold}4${normal} is required."
    echo "* - Memory: ${bold}$((total_memory / 1024 / 1024))${normal} GB of accessible memory. ${bold}8${normal} GB is required."
    echo "*"
    echo "* You can still proceed, however, it may not be as beneficial to the network or to you,"
    echo "* as your node won't be able to contribute or earn rewards effectively."
    echo "* You should ${bold}expect poor performance${normal}, and the community may ${bold}not be able to help${normal} you with issues."
    echo "* "
    echo "* If you are running this on a cloud provider, you should consider upgrading your instance to"
    echo "* meet the requirements."
    echo "* "
    echo "* Read more about other options for running a node on:"
    echo "* - https://voinetwork.github.io/voi-swarm/getting-started/introduction/"
    echo "*"
    echo "* Find other ways to contribute to the network by joining the Voi Network Discord:"
    echo "* - https://discord.com/invite/vnFbrJrHeW"
    echo "*"
    # shellcheck disable=SC2162
    read -p "Type '${bold}acknowledged${normal}' when you're ready to continue: " prompt
    while [[ ${prompt} != "acknowledged" ]]
    do
      # shellcheck disable=SC2162
      read -p "Type 'acknowledged' to continue: " prompt
    done
  else
    echo "Your system meets the minimum requirements to run Voi Swarm effectively."
    echo ""
  fi
}

if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

if [[ $(id -u) -eq 0 ]]; then
  is_root=1
fi

# Get Linux OS distribution
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  operating_system_distribution="${ID}"
else
  abort "This script is only meant to be run on Debian or Ubuntu."
fi

if uname -r | grep -q "Microsoft"; then
  abort "WSL 1 is not supported. Please run this script on a native Linux installation or WSL 2."
fi

if [[ ! (${operating_system_distribution} == "ubuntu" || ${operating_system_distribution} == "debian") ]]; then
  echo "Detected operating system: ${operating_system_distribution}"
  abort "This script is only meant to be run on Debian or Ubuntu."
fi

if [[ -n ${VOINETWORK_SKIP_WALLET_SETUP} && -n ${VOINETWORK_IMPORT_ACCOUNT} ]]; then
  echo "VOINETWORK_IMPORT_ACCOUNT and VOINETWORK_SKIP_WALLET_SETUP are both set. This is not supported at the same time."
  echo ""
  echo "To import an existing account, set VOINETWORK_IMPORT_ACCOUNT=1 and unset VOINETWORK_SKIP_WALLET_SETUP."
  echo ""
  echo "Your Voi and Via are linked to your account. Wallets are created automatically if needed."
  echo "Voi Swarm doesn't support wallet import."
  abort "Exiting the program."
fi

if [[ -n ${VOINETWORK_SKIP_WALLET_SETUP} && ${VOINETWORK_SKIP_WALLET_SETUP} -eq 1 ]] || [[ -n $VOINETWORK_HEADLESS_INSTALL ]]; then
  headless_install=1
fi

display_banner "${bold}Welcome to Voi Swarm${normal}. Let's get started!"

check_minimum_requirements

get_telemetry_name

set_telemetry_name

display_banner "Installing Docker"

execute_sudo "apt-get update"
execute_sudo "apt-get install -y ca-certificates curl gnupg"
execute_sudo "install -m 0755 -d /etc/apt/keyrings"

case ${operating_system_distribution} in
  "ubuntu")
    execute_sudo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg"
    execute_sudo "chmod a+r /etc/apt/keyrings/docker.gpg"
    execute_sudo "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \""$VERSION_CODENAME\"") stable\" > /etc/apt/sources.list.d/docker.list"
    ;;
  "debian")
    execute_sudo "curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg"
    execute_sudo "chmod a+r /etc/apt/keyrings/docker.gpg"
    execute_sudo "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo \""$VERSION_CODENAME\"") stable\" > /etc/apt/sources.list.d/docker.list"
    ;;
esac

execute_sudo "apt-get update"

execute_sudo "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

add_docker_groups

if ! docker --version | grep -q 'Docker version'; then
  echo "Docker installation failed."
  abort "Exiting the program."
fi

## Install script dependencies
execute_sudo "apt-get install -y jq bc"

display_banner "Starting stack"

start_docker_swarm

if [[ ! -e /var/lib/voi/algod/data ]]; then
  execute_sudo "mkdir -p /var/lib/voi/algod/data"
fi
mkdir -p "${voi_home}"

display_banner "Fetching the latest Voi Network updates and scripts."
curl -L https://api.github.com/repos/VoiNetwork/voi-swarm/tarball/main --output "${voi_home}"/voi-swarm.tar.gz
tar -xzf "${voi_home}"/voi-swarm.tar.gz -C "${voi_home}" --strip-components=1
rm "${voi_home}"/voi-swarm.tar.gz

cleanup_deprecated_files_and_folders

start_stack

wait_for_stack_to_be_ready

verify_node_is_running

if [[ -n ${VOINETWORK_SKIP_WALLET_SETUP} && ${VOINETWORK_SKIP_WALLET_SETUP} -eq 1  ]]; then
  display_banner "Wallet setup will be skipped."

  joined_network_instructions true

  exit 0
fi

display_banner "Initiating setup for Voi wallets and accounts."

create_wallet

if [[ -n ${VOINETWORK_IMPORT_ACCOUNT} && ${VOINETWORK_IMPORT_ACCOUNT} -eq 1 ]]; then

  if ! (check_if_account_exists true); then
    echo "An account already exists. No need to import, skipping this step."
  else
    echo ""
    echo "Let's proceed to import an account using your existing account mnemonic."
    execute_interactive_docker_command "goal account import"
    get_account_address
  fi

else
  if check_if_account_exists; then
    execute_interactive_docker_command "goal account new"
    get_account_address

    # Get Voi from faucet
    echo "****************************************************************************************************************"
    echo "*    To join the Voi network, do one of these:"
    echo "*"
    echo "*    a) Send at least 1 Voi to your account ${account_addr} from another account"
    echo "*"
    echo "*    OR"
    echo "*"
    echo "*    b) Get 1 Voi for free:"
    echo "*       - Go to the Voi Network Discord - https://discord.com/invite/vnFbrJrHeW"
    echo "*       - Open the #voiager-chat channel"
    echo "*       - Type /voi-testnet-faucet ${account_addr}"
    echo "*"
    echo "* After you've done this, type 'completed' to go on"
    echo "****************************************************************************************************************"

    # shellcheck disable=SC2162
    read -p "Type 'completed' when you're ready to continue: " prompt
    while [[ ${prompt} != "completed" ]]
    do
      # shellcheck disable=SC2162
      read -p "Type 'completed' to continue: " prompt
    done
  fi
fi

# Catchup node before creating participation key and going online
catchup_node

if [[ ${skip_account_setup} -eq 0 ]]; then
  join_as_new_user
else
  generate_participation_key

  migrate_host_based_voi_setup

  display_banner "Welcome to Voi!"

  joined_network_instructions
fi
