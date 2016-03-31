#!/bin/bash
 #####################################
#                                     #
#@By mr bomb @ 2016.3.21 hospital     #
#                                     #
# A cryptal tool x-ecrypting files    #
# iteratively from current dir        #
#                                     #
 #####################################
#                                     #
# TODO: add the ignore function       #
#                                     #
 #####################################

#########-the secrets-#################
PASSWD=123456
#SALT=

KEY_16=0000111122223333
IV_16=5555666677778888
#SEED=

KEY_32=00001111222233334444555566667777
IV_32=33334444555566667777888899990000
#SEED
#######################################


#########-none-secret-settings-########
CURR_DIR="."
TMPF=".one_case_tmp_file"
IGNORED=(.git .project .idea .sh)
#######################################


#################-encryption and decryption-#############################################

function is_ignored(){
# $1 the file pathy

    path=$1
    for suffix in ${IGNORED[*]}
    do
        [[ $path == *"$suffix" ]] && echo "ignoring [$path] " &&  return 0
    done
    return 1
}


function encrypt_with_passwd(){
# $1: init path
# $2: passwd

    for file in `ls $1`
    do
        path=$1"/"$file
        is_ignored $path  &&  continue # if should be ignored

        echo "begin to encrypt [$path]"
        if [ -d "$path" ]
        then
            encrypt_with_passwd $path
        elif [ -n "$SALT" ]; then
            echo 'using pre-set salt:' $SALT
            openssl enc -aes-128-cbc -k $2 -salt -S $SALT -in $path -out $TMPF -p
            rm -r $path && mv $TMPF $path
        else
            echo 'without pre-set salt'
            openssl enc -aes-128-cbc -k $2 -salt -in $path -out $TMPF -p 
            rm -r $path && mv $TMPF $path
        fi
    done
}


function encrypt_with_key_iv(){
# $1: file to be encrypted
# $2: Key
# $3: IV

    for file in `ls $1`
    do 
        path=$1"/"$file
        is_ignored $path  &&  continue # if should be ignored

        echo "begin to encrypt [$path]"
        if [ -d "$path" ]
        then
            encrypt_with_key_iv $path $2 $3
            exit 0
        else
            openssl enc -aes-128-cbc -K $2 -iv $3 -in $path -out $TMPF -p
            rm -r $path && mv $TMPF $path
        fi
    done
}


function encrypt_with_key(){
    echo "none."
}


function decrypt_with_passwd(){
# $1 the init dir
# $2 the password

    for file in `ls $1`
    do
        path=$1"/"$file
        is_ignored $path  &&  continue # if should be ignored

        echo "begin to decrypt [$path]"
        if [ -d "$path" ]
        then
            decrypt_with_passwd $path
        else
            openssl enc -aes-128-cbc -d -k $2 -in $path -out $TMPF -p
            rm -r $path && mv $TMPF $path
        fi
    done
}


function decrypt_with_key_iv(){
# $1: init dir
# $2: KEY
# $3: IV

    for file in `ls $1`
    do 
        path=$1"/"$file
        is_ignored $path  &&  continue # if should be ignored

        echo "begin to decrypt [$path]"
        if [ -d "$path" ]
        then
            decrypt_with_key_iv $path $2 $3
            exit 0
        else
            openssl enc -aes-128-cbc -d -K $2 -iv $3 -in $path -out $TMPF -p
            rm -r $path && mv $TMPF $path
        fi
    done
}


function decrypt_with_key(){
    echo "none."
}
################################################################################



#########-algorithm selection logic--#################################
function encrypt_with_key_or_passwd(){
# $1: init dir
    if [ -n KEY_32 -a -n IV_32 ]
    then
        encrypt_with_key_iv $1 $KEY_32 $IV_32
        exit 0
    elif [ -n KEY_32 ]; then
        encrypt_with_key $1 $KEY_32
        exit 0
    fi

    if [ -n KEY_16 -a -n IV_16 ]
    then
        encrypt_with_key_iv $1 $KEY_16 $IV_16
        exit 0
    elif [ -n KEY_16 ]; then
        encrypt_with_key $1 $KEY_16
        exit 0
    fi

    if [ -n $PASSWD ]
    then
        encrypt_with_passwd $1 $PASSWD
        exit 0
    fi
}

function decrypt_with_key_or_passwd(){
# $1: init dir
    if [ -n KEY_32 -a -n IV_32 ]
    then
        decrypt_with_key_iv $1 $KEY_32 $IV_32
        exit 0
    elif [ -n KEY_32 ]; then
        decrypt_with_key $1 $KEY_32
        exit 0
    fi

    if [ -n KEY_16 -a -n IV_16 ]
    then
        decrypt_with_key_iv $1 $KEY_16 $IV_16
        exit 0
    elif [ -n KEY_16 ]; then
        decrypt_with_key $1 $KEY_16
        exit 0
    fi

    if [ -n $PASSWD ]
    then
        decrypt_with_passwd $1 $PASSWD
        exit 0
    fi
}
#####################################################################



##################-back up-###########################
function  backup_file(){
    TARGET_DIR=$CURR_DIR"/onecase.backup"
    if [ ! -x "$TARGET_DIR" ]; then
        mkdir "$TARGET_DIR"
    fi

    file=$1
    if [ ! -f $file ]; then
        echo "$file" does not exist!
        exit 1
    fi

    cp -f $file $TARGET_DIR"/"
}

function  restore_file(){
    SRC_DIR=$CURR_DIR"/onecase.backup"
    file=$1
    if [ ! -f $SRC_DIR"/"$file ]; then
        echo $SRC_DIR"/"$file does not exist!
        exit 1
    fi

    cp -f $SRC_DIR"/"$file $CURR_DIR"/"
}
####################################################



##########-decide encrypting or decrypting-##################
if [ "$1" = "enc" ]
then
    encrypt_with_key_or_passwd  $CURR_DIR
elif [ "$1" == "dec" ]; then
    decrypt_with_key_or_passwd  $CURR_DIR
fi        
#############################################################
