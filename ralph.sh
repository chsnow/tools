#!/bin/bash
# My Ralph wrapper for Claude.

if [ $# -lt 2 ]; then
  echo "Usage: $0 spec.md implementation_plan.md [max_iterations]"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Error: $1 does not exist"
  exit 1
fi

if [ ! -f "$2" ]; then
  echo "Error: $2 does not exist"
  exit 1
fi

RALPH_PROMPT="
1. Study $1 thoroughly.
2. Study $2.
3. Consult the implementation plan: if the plan appears to include a sequential task list, then always choose the first unchecked task; otherwise, pick the highest-leverage unchecked task.
4. If there is no remaining task for you to do by yourself, output '#RALPH_I_AM_DONE' and exit immediately. Otherwise, continue.
5. If it's useful for your task, you can read the git history of commits on this branch to see the implementation of the prior items on this checklist.
6. Complete the task you selected.
7. If relevant to the task, write an unbiased unit test to verify.
8. Once you have verified the task has been completed successfully, mark it complete in the plan.
9. Commit the changes you have made with a concise, descriptive commit message referencing the task you completed.
"

if [ $# -eq 3 ]; then
  MAX_ITERATIONS=$3
else
  MAX_ITERATIONS=20
fi

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "----- RALPH Iteration $i -----"
  echo "$RALPH_PROMPT" | claude -p --dangerously-skip-permissions 2>&1 | tee /dev/tty | grep -q '#RALPH_I_AM_DONE'
  if [ $? -eq 0 ]; then
    echo "Encountered termination token, exiting"
    exit 0
  fi
done
echo "Completed $MAX_ITERATIONS iterations, exiting"