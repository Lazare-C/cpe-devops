# Ansible

**3-1 Document your inventory and base commands**

Pour le moment mon inventaire contient un seul groupe "all" qui définie une clé ssh, un nom d'utilisateur. Le groupe contient un enfant: la vm définie par l'host lazare.chevereau.takima.cloud

- `ansible all -i inventories/setup.yml -m ping` : cette commande permet de vérifier la connectivité avec tous les hôtes de l'inventaire.
- `ansible all -i inventories/setup.yml ansible-playbook playbook.yml` : permet de lancer un playbook pour des tests à la place d'un role
- `ansible-galaxy init my_role` : afin de créer l'architecture d'un role

**3-2 Document your playbook**

pour la partie tasks, on en à qu'une seule: tasks/main.yml

```yml
---
# handlers file for roles/docker
#On installe device-mapper-persistent-data qui permet de gérer les données perisistantes
- name: Install device-mapper-persistent-data
yum:
    name: device-mapper-persistent-data
    state: latest

#on installe avec yum lvm2 qui est un paquet qui fournit un gestionnaire de volume afin, dans ce contexte de gérer l'espace de stockage des conteneurs dockers
- name: Install lvm2
yum:
    name: lvm2
    state: latest

#on rajoute le dépot de docker.com à yum afin de pouvoir télécharger docker
- name: add repo docker
command:
    cmd: sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

#on vérifie si docker-ce est présent, sinon on télécharge
- name: Install Docker
yum:
    name: docker-ce
    state: present

#on vérifie si python3 est présent, sinon on télécharge
- name: Install python3
yum:
    name: python3
    state: present

# on installe la lib docker pour python
- name: Install docker with Python 3
pip:
    name: docker
    executable: pip3
vars:
    ansible_python_interpreter: /usr/bin/python3

# on vérifie que le service docker est bien start
- name: Make sure Docker is running
service: name=docker state=started
tags: docker
    ```
on utilise aussi un handler 

```yaml
---
# handlers file for roles/docker
    #le handler permet de restart le service docker
- name: restart docker
  service:
    name: docker
    state: restarted
```

on appel le role depuis notre playbook:

```yaml
    # on selectionne le groupe "all"
- hosts: all
    # on ne récupère pas les Facs de la machine
  gather_facts: false
    # on s'accorde les droits su
  become: true
    # on attribue le role
  roles:
    - docker
```

**Document your docker_container tasks configuration.**

Un example de configuration:

```yml
---
# tasks file for roles/backend
  # nom de la tache
- name: Run Backend
  #on utilise le module ansible "docker_container" 
  docker_container:
    #on nomme l'image
    name: backend
    #on indique qu'elle image pull sur dockerhub 
    image: lazarec/backend:latest
    # on selectionne un network commun, ici veriabilise dans le playbook
    networks:
      - name: "{{ docker_network_name }}"
    # on définie nos variables d'env pour le docker
    env:
      POSTGRES_USER: "{{ db_user }}"
      POSTGRES_PASSWORD: "{{ db_pass }}"
      DB_CONFIG_URL: "{{ spring_db_url }}"
    # pour les tests on recréer le docker
    recreate: true
      #on indique à ansible ou trouver l'interpréteur python
  vars:
    ansible_python_interpreter: /usr/bin/python3
```

on peut rajouter :

```yaml
    #pour ouvrir le port du proxy
    port:
        - "80:80"
    # permet de créer un volume docker pour la base de donnée
    volumes:
      - postgres:/var/lib/postgresql/data
```


