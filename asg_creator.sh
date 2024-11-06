NAME=""
SUBNETS=""
MIN_SIZE=1
MAX_SIZE=3
TEMPLATE_FILE="asg_creator.yml"
AmiId="ami-0866a3c8686eaeeba"

log_message() {
  local message=$1
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $message"
}

usage() {
  echo "Usage: $0 -ami <amiId> -n <name> -u <subnets> -s <desired_size> -m <min_size> -x <max_size>"
  echo "  -t <template_file>   : CF template file"
  echo "  -n <name>            : Name for the resources(required)"
  echo "  -u <subnets>         : Comma-separated list of subnet IDs"
  echo "  -s <desired_size>    : Desired number of instances in the ASG(required)"
  echo "  -m <min_size>        : Minimum size of the ASG"
  echo "  -x <max_size>        : Maximum size of the ASG"
  echo "  -a <AmiId>         : Let's you customize ASG's default ami(give in quotes)"
  exit 1
}

# Parse command-line arguments
while getopts "t:n:u:s:m:x:a:" opt; do
  case "$opt" in
    t) TEMPLATE_FILE=$OPTARG ;;
    n) NAME=$OPTARG ;;
    u) SUBNETS=$OPTARG ;;
    s) DESIRED_CAPACITY=$OPTARG ;;
    m) MIN_SIZE=$OPTARG ;;
    x) MAX_SIZE=$OPTARG ;;
    a) AmiId=$OPTARG ;;
    *) usage ;;
  esac
done

if [ -z "$NAME" ]; then
  echo "Error: Name parameter (-n) is required."
  usage
fi

if [ -z "$SUBNETS" ]; then
  echo "Error: Subnets parameter (-u) is required."
  usage
fi

if [ -z "$DESIRED_CAPACITY" ]; then
  echo "Error: Desired capacity parameter (-u) is required."
  usage
fi


# Check if Subnet IDs are valid (comma-separated list of non-empty strings)
IFS=',' read -r -a SUBNET_LIST <<< "$SUBNETS"
for subnet in "${SUBNET_LIST[@]}"; do
  if [[ -z "$subnet" ]]; then
    echo "Error: Each subnet ID in the list must be a non-empty string."
    exit 1
  fi
done

# Check if DesiredCapacity, MinSize, and MaxSize are valid numbers
if ! [[ "$DESIRED_CAPACITY" =~ ^[0-9]+$ ]]; then
  echo "Error: DesiredCapacity (-s) must be a positive integer."
  exit 1
fi

if ! [[ "$MIN_SIZE" =~ ^[0-9]+$ ]]; then
  echo "Error: MinSize (-m) must be a positive integer."
  exit 1
fi

if ! [[ "$MAX_SIZE" =~ ^[0-9]+$ ]]; then
  echo "Error: MaxSize (-x) must be a positive integer."
  exit 1
fi



STACK_NAME="${NAME}-stack"

log_message "Deploying CloudFormation stack ${STACK_NAME}..."

aws cloudformation deploy \
  --stack-name "${STACK_NAME}" \
  --template-file "$TEMPLATE_FILE" \
  --parameter-overrides \
    Name="$NAME" \
    SubnetIds="$SUBNETS" \
    DesiredCapacity="$DESIRED_CAPACITY" \
    MinSize="$MIN_SIZE" \
    MaxSize="$MAX_SIZE" \
    AmiId="$AmiId" \

if [ $? -eq 0 ]; then
  log_message "CloudFormation stack '$STACK_NAME' has been successfully deployed."
else
  log_message "Error deploying CloudFormation stack '$STACK_NAME'."
  exit 1
fi

#sh asg_creator.sh -n awesome2 -s 1 -u subnet-eb242ec5,subnet-8a8d52c7 -ami ami-0aabd8090d75cbe76 -m 0 -x 2