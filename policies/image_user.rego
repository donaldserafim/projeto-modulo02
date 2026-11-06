package supply.image

import rego.v1

# Contrato deliberadamente estrito: UID numerico nao zero, grupo opcional.
# Nomes nao comprovam UID sem consultar /etc/passwd; falhamos de forma fechada.
valid_user if {
    user := input.config.User
    is_string(user)
    regex.match(`^[0-9]+(:[0-9]+)?$`, user)
    uid := split(user, ":")[0]
    to_number(uid) > 0
}

deny contains "Defina USER com UID numerico maior que zero (grupo numerico opcional)." if {
    not valid_user
}
