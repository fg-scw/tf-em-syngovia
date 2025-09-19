Je comprends. Voici un guide détaillé pour renommer une interface réseau sur Proxmox 9, au format Markdown en un seul bloc.

-----

### **Configuration Proxmox 9 : Renommage d'interface réseau**

Ce guide vous explique comment renommer une interface réseau sur un serveur Proxmox, remplaçant un nom complexe (`enp129s0f0np0`) par un nom plus simple et stable (`eth1`). Ce renommage est rendu permanent à l'aide d'une règle `systemd .link`.

-----

#### **Méthode 1 : Utilisation de l'adresse MAC (Recommandée)**

Cette approche est la plus fiable car elle s'appuie sur l'adresse MAC, un identifiant matériel unique et immuable.

**Étape 1 : Obtenir l'adresse MAC de l'interface**

Utilisez la commande `ip link show` pour trouver l'adresse MAC de l'interface que vous souhaitez renommer.

```bash
ip link show enp129s0f0np0 | grep "link/ether"
```

Vous obtiendrez une sortie similaire à : `link/ether 7c:c2:55:b8:fe:54 brd ff:ff:ff:ff:ff:ff`.

**Étape 2 : Créer le fichier `systemd .link`**

Créez un nouveau fichier de configuration dans le répertoire `/etc/systemd/network/`. Le nom de fichier doit commencer par un numéro pour définir l'ordre et se terminer par `.link`.

```bash
nano /etc/systemd/network/10-eth1.link
```

Ajoutez le contenu suivant en utilisant l'adresse MAC obtenue à l'étape précédente.

```ini
[Match]
MACAddress=7c:c2:55:b8:fe:54

[Link]
Name=eth1
```

-----

#### **Méthode 2 : Utilisation d'autres attributs `udevadm`**

Si vous ne souhaitez pas utiliser l'adresse MAC, vous pouvez trouver d'autres identifiants persistants avec `udevadm`.

**Étape 1 : Identifier les attributs de l'interface**

Utilisez `udevadm info` pour afficher tous les attributs de l'interface.

```bash
# Obtenir tous les attributs disponibles
udevadm info /sys/class/net/enps129s0f0np0
```

Vous pouvez filtrer la sortie pour des attributs couramment utilisés pour l'identification, comme `ID_PATH` ou `DEVPATH`.

```bash
# Chercher des attributs utiles (MAC, Serial, etc.)
udevadm info /sys/class/net/enps129s0f0np0 | grep -E "ID_|DEVPATH|INTERFACE"
```

**Étape 2 : Créer le fichier `systemd .link`**

Créez le fichier de configuration et adaptez son contenu en fonction de l'attribut choisi.

```bash
nano /etc/systemd/network/10-enps129s0f0np0.link
```

Exemples de contenu :

```ini
[Match]
OriginalName=enps129s0f0np0

[Link]
Name=eth1
```

Ou, en utilisant l'attribut `ID_PATH` :

```ini
[Match]
Property=ID_PATH=pci-0000:81:00.0

[Link]
Name=eth1
```

-----

### **Finalisation de la configuration**

Ces étapes sont communes aux deux méthodes et sont essentielles pour appliquer le renommage et mettre à jour la configuration réseau de Proxmox.

**Étape 1 : Redémarrer les services `systemd`**

Rechargez les démons `systemd` et redémarrez le service `udev-trigger` pour prendre en compte le nouveau fichier `.link`.

```bash
systemctl daemon-reload
systemctl restart systemd-udev-trigger.service
```

**Étape 2 : Modifier le fichier des interfaces réseau**

Éditez le fichier `/etc/network/interfaces` pour remplacer le nom de l'ancienne interface par `eth1` dans la configuration du pont réseau (`vmbr0`).

```bash
nano /etc/network/interfaces
```

Remplacez `enp129s0f0np0` par `eth1` dans les sections `iface` et `bridge-ports`.

```bash
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
```

**Étape 3 : Redémarrer complètement le système**

Un redémarrage complet est nécessaire pour que le noyau applique le nouveau nom d'interface au démarrage.

```bash
reboot
```

-----

### **Vérification**

Après le redémarrage, vérifiez que le renommage est effectif et que la configuration réseau fonctionne correctement.

```bash
# Vérifier que l'interface s'appelle maintenant eth1
ip link show

# Vérifier que la configuration réseau fonctionne
ip addr show eth1
ping -c 3 195.154.212.1
```
