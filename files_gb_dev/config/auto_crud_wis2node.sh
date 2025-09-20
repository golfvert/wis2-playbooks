#!/bin/bash

cd {{ docker_user_home}}/config

ACTION_DIR="automation/action"
ENV_SOURCE_DIR="automation/env"
REPORT_DIR="automation/report"
ENV_TARGET_DIR="data/env"
ADD_NODE_SCRIPT="./add_wis2node.sh"
DEL_NODE_SCRIPT="./del_wis2node.sh"

# Loop through all files in automation/action
for file in "$ACTION_DIR"/*; do
  # Extract values
  action=$(grep "^ACTION=" "$file" | cut -d"'" -f2)
  centre=$(grep "^CENTRE_ID=" "$file" | cut -d"'" -f2)
  duration=$(grep "^DURATION=" "$file" | cut -d"'" -f2)

  if [ -n "$action" ] && [ -n "$centre" ]; then
    case "$action" in
      create)
        # Move env file
        src_env="$ENV_SOURCE_DIR/$centre.env"
        dest_env="$ENV_TARGET_DIR/$centre.env"
        echo "Configuring $centre" > "$REPORT_DIR/${centre}"
        if [ -f "$src_env" ]; then
          mv "$src_env" "$dest_env"
          echo "Moved $src_env to $dest_env"
        else
          echo "Warning: $src_env not found"
        fi

        # Run add_node.sh
        if [ -x "$ADD_NODE_SCRIPT" ]; then
          "$ADD_NODE_SCRIPT" "$centre"
            if [ $? -eq 0 ]; then
                echo "Successfully added $centre" >> "$REPORT_DIR/${centre}"
            else
                echo "Error adding $centre" >> "$REPORT_DIR/${centre}"
            fi
        else
          echo "Error: $ADD_NODE_SCRIPT not executable" >> "$REPORT_DIR/${centre}"
        fi

        # Schedule deletion if DURATION is set
        if [[ "$duration" =~ ^[0-9]+$ ]]; then
          echo "$DEL_NODE_SCRIPT $centre" | at now + "$duration" days
          echo "Scheduled deletion of $centre in $duration days" >> "$REPORT_DIR/${centre}"
        fi
        ;;
      delete)
        if [ -x "$DEL_NODE_SCRIPT" ]; then
          "$DEL_NODE_SCRIPT" "$centre"
        else
          echo "Error: $DEL_NODE_SCRIPT not executable"
        fi
        ;;
      *)
        echo "Unknown action '$action' in $file"
        ;;
    esac
  else
    echo "Missing ACTION or CENTRE_ID in $file"
  fi

  # Delete the processed file
  rm -f "$file"
  echo "Deleted $file"
done
