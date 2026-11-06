package supply.image

import rego.v1

test_reject_missing_config if {
    violations := deny with input as {}
    count(violations) == 1
}

test_reject_missing_user if {
    violations := deny with input as {"config": {}}
    count(violations) == 1
}

test_reject_invalid_users if {
    every user in ["", "root", "0", "00", "root:root", "root:1000", "0:1000", "00:0", "daemon", "-1", "1000:", "1000:root", " 1000", null, 1000] {
        violations := deny with input as {"config": {"User": user}}
        count(violations) == 1
    }
}

test_allow_nonzero_uid if {
    every user in ["10001", "10001:10001", "1", "10001:0"] {
        violations := deny with input as {"config": {"User": user}}
        count(violations) == 0
    }
}
