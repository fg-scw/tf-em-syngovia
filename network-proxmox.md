Renommage d'interface réseau sur Proxmox 9
Cette procédure vous guide à travers les étapes pour renommer une interface réseau sur un serveur Proxmox, en utilisant un nom plus simple et plus stable, comme eth1. Nous utiliserons une règle systemd .link pour que le renommage soit permanent après les redémarrages.

Méthode 1 : Utilisation de l'adresse MAC (recommandé)
Cette méthode est la plus fiable car l'adresse MAC est un identifiant unique et stable pour votre carte réseau.

Étape 1 : Obtenir l'adresse MAC de l'interface
Identifiez l'adresse MAC de l'interface actuelle (par exemple, enp129s0f0np0) en utilisant la commande ip link show.

Bash

ip link show enp129s0f0np0 | grep "link/ether"
Vous obtiendrez une sortie similaire à : link/ether 7c:c2:55:b8:fe:54 brd ff:ff:ff:ff:ff:ff

Étape 2 : Créer le fichier de configuration .link
Créez un nouveau fichier de configuration systemd .link dans le répertoire /etc/systemd/network/. Le nom du fichier doit se terminer par .link. Nous utiliserons 10-eth1.link.

Bash

nano /etc/systemd/network/10-eth1.link
Ajoutez le contenu suivant en utilisant l'adresse MAC que vous avez obtenue à l'étape précédente.

Ini, TOML

[Match]
MACAddress=7c:c2:55:b8:fe:54

[Link]
Name=eth1
Méthode 2 : Utilisation d'autres attributs de l'interface
Si vous préférez ne pas utiliser l'adresse MAC, vous pouvez identifier d'autres attributs stables de l'interface en utilisant udevadm.

Étape 1 : Identifier les attributs de votre interface
Utilisez udevadm info pour obtenir tous les attributs de l'interface.

Bash

# Obtenir tous les attributs disponibles
udevadm info /sys/class/net/enps129s0f0np0
Pour trouver un attribut pertinent comme l'ID du chemin d'accès (ID_PATH), filtrez la sortie :

Bash

# Chercher des attributs utiles (MAC, Serial, etc.)
udevadm info /sys/class/net/enps129s0f0np0 | grep -E "ID_|DEVPATH|INTERFACE"
Étape 2 : Créer le fichier de configuration .link
Créez le fichier de configuration 10-enps129s0f0np0.link et adaptez son contenu en fonction de l'attribut que vous avez choisi.

Bash

nano /etc/systemd/network/10-enps129s0f0np0.link
Ajoutez le contenu, en utilisant par exemple OriginalName ou Property (comme ID_PATH).

Ini, TOML

[Match]
OriginalName=enps129s0f0np0
[Link]
Name=eth1
Ou bien, en utilisant l'attribut Property=ID_PATH :

Ini, TOML

[Match]
Property=ID_PATH=pci-0000:81:00.0
[Link]
Name=eth1
Finalisation et redémarrage
Quelle que soit la méthode choisie, les étapes suivantes sont obligatoires pour appliquer les changements.

Étape 1 : Recharger et redémarrer les services systemd
Il est crucial de recharger la configuration de systemd pour qu'elle prenne en compte le nouveau fichier .link.

Bash

systemctl daemon-reload
systemctl restart systemd-udev-trigger.service
Étape 2 : Modifier le fichier de configuration réseau (/etc/network/interfaces)
Éditez le fichier de configuration réseau principal de Proxmox pour remplacer le nom de l'ancienne interface par le nouveau nom (eth1).

Bash

nano /etc/network/interfaces
Remplacez toutes les occurrences de enp129s0f0np0 par eth1 dans la configuration de votre pont réseau (vmbr0).

Exemple de configuration mise à jour :

Bash

auto lo
iface lo inet loopback

iface eth1 inet manual

auto vmbr0
iface vmbr0 inet static
    address 195.154.212.110/24
    gateway 195.154.212.1
    bridge-ports eth1
    bridge-stp off
    bridge-fd 0
source /etc/network/interfaces.d/*
Étape 3 : Redémarrer le système
Le renommage est effectif au prochain démarrage du système. Redémarrez votre serveur pour appliquer les modifications.

Bash

reboot
Vérification après le redémarrage
Après le redémarrage, vérifiez que l'interface a été renommée avec succès et que la connectivité réseau est fonctionnelle.

Bash

# Vérifier que l'interface s'appelle maintenant eth1
ip link show

# Vérifier que la configuration réseau fonctionne
ip addr show eth1
ping -c 3 195.154.212.1
