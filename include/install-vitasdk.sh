#!/bin/bash

get_download_link () {
  curl -sL https://github.com/vitasdk/vita-headers/raw/master/.travis.d/last_built_toolchain.py | python - $@
}

need_root_perm () {
  curr=$1
  while true; do
    if [ -d "$curr" ]; then
      DIR_INFO=($(stat -Lc "%a %U %G" $curr))
      PERM="0${DIR_INFO[0]}"
      OWNER=${DIR_INFO[1]}
      GROUP=${DIR_INFO[2]}
      if [[ $(($PERM & 0200)) != 0 && $USER == $OWNER ]]; then
        return
      elif [ $(($PERM & 0002)) != 0 ]; then
        return
      elif [[ $(($PERM & 0020)) != 0 ]]; then
        groups=($(groups $USER))
        for grp in "${groups[@]}"; do
          if [[ $GROUP == $grp ]]; then
            return
          fi
        done
      fi
      echo 1
      return
    fi
    curr=$(dirname $curr)
  done
}

install_vitasdk () {
  INSTALLDIR=$1

  # TODO: actually check if sudo is required for install dir
  SUDO=
  if [ -x "$(command -v sudo)" ]; then
    SUDO=sudo
  fi

  case "$(uname -s)" in
     Darwin*)
      if [ -d "$INSTALLDIR" ]; then
        rm -rf "$INSTALLDIR"
      fi
      mkdir -p $INSTALLDIR
      curl -o "vitasdk-nightly.tar.bz2" -L "$(get_download_link master osx)"
      tar xf "vitasdk-nightly.tar.bz2" -C $INSTALLDIR --strip-components=1
      rm -f "vitasdk-nightly.tar.bz2"
     ;;

     Linux*)
      if [ -n "${TRAVIS}" ]; then
          $SUDO apt-get install libc6-i386 lib32stdc++6 lib32gcc1 patch
      fi
      if [ -d "$INSTALLDIR" ]; then
        $SUDO rm -rf $INSTALLDIR
      fi
      $SUDO mkdir -p $INSTALLDIR
      $SUDO chown $USER:$(id -gn $USER) $INSTALLDIR
      curl -o "vitasdk-nightly.tar.bz2" -L "$(get_download_link master linux)"
      tar xf "vitasdk-nightly.tar.bz2" -C $INSTALLDIR --strip-components=1
      rm -f "vitasdk-nightly.tar.bz2"
     ;;

     MSYS*|MINGW64*)
      UNIX=false
      if [ -d "$INSTALLDIR" ]; then
        rm -rf $INSTALLDIR
      fi
      mkdir -p $INSTALLDIR
      curl -o "vitasdk-nightly.tar.bz2" -L "$(get_download_link master win)"
      tar xf "vitasdk-nightly.tar.bz2" -C $INSTALLDIR --strip-components=1
      rm -f "vitasdk-nightly.tar.bz2"
     ;;

     CYGWIN*|MINGW32*)
      echo "Please use msys2. Exiting..."
      exit 1
     ;;

     *)
       echo "Unknown OS"
       exit 1
      ;;
  esac

}
