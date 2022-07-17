LOCAL_USER=`yq ".config.staticPasswords[0].email" $(dirname "$0")/values.yaml`
echo $LOCAL_USER
yq -i e '.subjects[0].name = "'"$LOCAL_USER"'"' \
    $(dirname "$0")/addition-resources/RBAC.yaml
cat $(dirname "$0")/addition-resources/RBAC.yaml