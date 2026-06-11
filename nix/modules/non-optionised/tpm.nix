# TODO Test TPM Unlock of Root partition
# https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde
# sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/nvme0n1p2

let
    user = "meow";
in {
    security.tpm2.enable = true;
    security.tpm2.pkcs11.enable = true;
    security.tpm2.tctiEnvironment.enable = true;
    users.users.${user}.extraGroups = [ "tss" ];
}
