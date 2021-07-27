#!/usr/bin/env bash
# Clones repos into directories.
# ALternative https://github.com/presslabs/gitfs

if [ -z ${SETOPTS} ]; then
  SETOPTS="-e"
fi
set ${SETOPTS}

if [ -z "${REPO_URI_SRCS}" ] || [ -z "${REPO_DIR_DSTS}" ]; then
  echo "E: Requires .env variables REPO_URI_SRCS and REPO_DIR_DSTS."
  exit 1
fi

if [ -z ${INTERVAL} ]; then
  INTERVAL=600
fi

if [ -z ${MAIN} ]; then
 BRANCH=main
fi

authURL(){
  REPO=$1
  if [ "${REPO_USER}" ] && [ "${REPO_PASS}" ]; then
    sedcmd="s^//^//${REPO_USER}:${REPO_PASS}@^"
    REPO=$(echo -n ${REPO} | sed -e "$sedcmd")
  fi
  echo ${REPO}
}


loopRepos(){
  IFS=', ' read -r -a repo_uri_srcs <<< "$REPO_URI_SRCS"
  IFS=', ' read -r -a repo_dir_dsts <<< "$REPO_DIR_DSTS"
  for index in "${!repo_uri_srcs[@]}"; do
    src="${repo_uri_srcs[index]}"
    src=$(authURL $src)
    dst="${repo_dir_dsts[index]}"
    cloneOrPull $src $dst
  done
}


cloneOrPull(){
  REPO=$1
  DIR=$2
  mkdir -p $DIR
  cd $DIR
  set +e
  git -C .  rev-parse 2>/dev/null
  ec=$?
  set -e
  ts=$(date +"%Y-%m-%d %H:%M:%S")
  if [[ $ec -eq 0 ]]; then
    echo "$ts Pulling $REPO to $DIR"
    git pull $QUIET
  else
    echo "$ts Cloning $REPO to $DIR"
    git clone $QUIET --single-branch $REPO .
  fi
  cd
}


chmodDir(){
  if [ -n "${CHMOD}" ]; then
    git stash
    # echo ${CHMOD}
    find . -type f | grep -v $CHMOD_EXCLUDE | xargs ${CHMOD}
  fi
}


while true; do
  loopRepos
  sleep $INTERVAL
done
