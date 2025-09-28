# Basic Configuration
# az account list-locations -o table | egrep -i 'DisplayName|newzea'
# DisplayName               Name                 RegionalDisplayName
# New Zealand North         newzealandnorth      (Asia Pacific) New Zealand North
# New Zealand               newzealand           New Zealand

prefix              = "nz3es-prefix-default"
resource_group_name = "rg-aks-private-default"
location            = "newzealandnorth"
