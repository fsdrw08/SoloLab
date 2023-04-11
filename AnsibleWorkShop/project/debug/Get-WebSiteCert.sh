# https://stackoverflow.com/questions/59889176/how-to-get-the-final-group-of-text-between-two-patterns-with-sed-or-awk

URL="ipa.infra.sololab"

# https://github.com/search?p=1&q=openssl+s_client+showcerts+awk+tac&type=Code
# https://github.com/rcor/terraform_scripts/blob/a82ed62f694449baf1c7a6dea3b26336f23b458a/eks/bash/oidc-thumbprint.sh
echo | openssl s_client -showcerts -connect $URL:443 2>&- | tac | sed -n '/-END CERTIFICATE-/,/-BEGIN CERTIFICATE-/p; /-BEGIN CERTIFICATE-/q' | tac

echo | openssl s_client -showcerts -connect $URL:443 2>&- | tac | awk ''