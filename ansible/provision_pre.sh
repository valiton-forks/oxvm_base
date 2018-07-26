#!/usr/bin/env bash

SRCDIR="/mnt/asf/szshop_vagrant/ansible/roles"
DESTDIR="/vagrant/base_vm/ansible/roles"
COMMONMETA="common/meta/main.yml"

echo "start of provision_pre.sh"

exit 0

for SRCFULL in "$SRCDIR/"*; do

  if [ -d "$SRCFULL" ]; then

    echo "checking symlink for: $SRCFULL"
    THEFILE=$(basename "$SRCFULL")
    DESTFULL="$DESTDIR/$THEFILE"

    if [ -L "$DESTFULL" ]; then
      echo "ok: already done"

    elif [ -d "$DESTFULL" ]; then
      echo "error: already exists"

    elif [ ! -e "$DESTFULL" ]; then
      echo "ok: creating symlink"

      ln -s "$SRCFULL" "$DESTFULL"
    fi

    if [ -L "$DESTFULL" ]; then

      if [[ "$THEFILE" =~ '__bds_pre$' ]]; then
        THEROLE=${THEFILE%__bds_pre}
        sed -i 's@ '$THEROLE'$@ '$THEFILE"\n  - "$THEROLE'@' ../vm_oxvm_eshop/base_vm/ansible/roles/common/meta/main.yml
      elif [[ "$THEFILE" =~ '__bds_post$' ]]; then
        THEROLE=${THEFILE%__bds_post}
        sed -i 's@ '$THEROLE'$@ '$THEROLE"\n  - "$THEFILE'@' ../vm_oxvm_eshop/base_vm/ansible/roles/common/meta/main.yml
      elif [[ "$THEFILE" =~ '__bds_end$' ]]; then
        ADDLINE="  - $THEFILE"
        OUTPUT=$(grep --silent "$ADDLINE" "$DESTFULL/$COMMONMETA" 2>&1)
        if [ "$?" = "1" ] && [ "$OUTPUT" = "" ]; then
          echo "$ADDLINE" >> "$DESTFULL/$COMMONMETA"
        fi
      fi

  fi
done
