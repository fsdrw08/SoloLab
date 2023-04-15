
# https://nikhilism.com/post/2016/understanding-ansible-jinja2-default-filter/
# https://www.freecodecamp.org/news/truthy-and-falsy-values-in-python/
keys="
{{ vault_unseal_keys_b64 | default('', true) }}
"

# https://blog.csdn.net/Jerry_1126/article/details/51835119
length=$(echo -n $keys | wc -c)
echo "length $length"

if [ "$length" -le 2 ]; 
then
    echo "no unseal key"
else
    for i in $keys
    do
        # echo "it's $i"
        vault operator unseal $i
        # sleep 1
    done
fi