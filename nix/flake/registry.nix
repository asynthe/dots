# Enables `flake.modules.<class>.<name>`, the registry every aspect file writes
# into. Without this flake-parts module the option does not exist.
{ inputs, ... }:
{
    imports = [ inputs.flake-parts.flakeModules.modules ];

    systems = [ "x86_64-linux" "aarch64-linux" ];
}
