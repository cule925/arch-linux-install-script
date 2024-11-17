# INSTALACIJSKA SKRIPTA ZA ARCH LINUX OPERACIJSKE SUSTAVE

Projekt je potrebno preuzeti na računalo koje je pokrenulo Arch Linux ISO sliku. Ali je prije toga potrebno preuzeti alat *git*:

```
loadkeys croat					# If Croatian keyboard layout is needed
setfont Lat2-Terminus16				# If setting another font is needed, for example "Lat2-Terminus16"
timedatectl set-timezone Europe/Zagreb
timedatectl set-ntp true
pacman -Syu
pacman -S git
git clone https://github.com/cule925/arch-linux-install-script.git
cd arch-linux-install-script/
```

## Postavke instalacije

Postavke sustava koje će on imati nakon instalacije mogu se postaviti uređivanjem datoteke **settings.txt**.

Ako se žele dodati još neki paketi koji će se instalirati, to je moguće napraviti uređivanjem sljedećih datoteka:

- **custom_packages.txt**
	- ako se ne odabere minimalna instalacija, ovi paketi se instaliraju
- **custom_gui_packages.txt**
	- ako se ne odabere minimalna instalacija i odabere se desktop radno okruženje, ovi paketi se instaliraju

Osnovni paketi koji će se instalirati bez obzira je li odabrana minimalna instalacija ili ne se nalaze na lokaciji **system/default_packages.txt**. Paket Linux jezgre je naveden na lokaciji **system/kernel_and_base_packages.txt**, a paketi potrebni za GRUB bootloader se nalaze u datotekama **bootloader_packages_uefi.txt** (UEFI) i **bootloader_packages_bios.txt** (BIOS)

## Pokretanje instalacije

Dovoljno je pokrenuti skriptu ```./install.sh``` za instalaciju.

## Dodatno

Opaske:
- multiboot automatska instalacija još nije dodana
- ako se želi pristupiti računalu ili virtualnom koji pokreću Arch Linux ISO sliku, prvo je potrebno na Arch Linux ISO slici stvoriti zaporku za **root** korisnika (naredba ```passwd```), udaljeni pristup s udaljenog računala se može napraviti naredbom:

```
ssh root@[IP adresa]
```
