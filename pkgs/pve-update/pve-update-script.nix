{ lib, pve-update }:

{
  attrPath ? null,
  extraArgs ? [ ],
}:
[ "${lib.getExe pve-update}" ] ++ extraArgs ++ lib.optionals (attrPath != null) [ attrPath ]
