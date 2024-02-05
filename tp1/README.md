# TP n°1: Docker

## Postgres

on build postgres `docker build -t lazarec/postgres postgres`
on build postgres `docker build -t lazarec/postgres postgres`

on créer un réseau docker: `docker network create app-network`

on lance admier:

```bash
        docker run \
        -p "8090:8080" \
        --net=app-network \
        --name=adminer \
        -d \
        adminer

```

on lance postgres:

```bash
docker run \
-p 5432:5432 \
--name postgres \
--env-file ./.env \
--net=app-network \
-d \
-v devops-postgres:/var/lib/postgresql/data \
lazarec/postgres
```

*Why do we need a volume to be attached to our postgres container?:*
On à besoin de créer un volume afin de pouvoir supprimer le container et de persisster de la donnée

*1-1 Document your database container essentials: commands and Dockerfile.*

```yaml

#image d'origine
FROM postgres:14.1-alpine

# Set environment variables
# Valeur par défaut remplacé par le .env au moment du docker run
ENV POSTGRES_DB=db \
    POSTGRES_USER=usr \
    POSTGRES_PASSWORD=pwd


# Copie des fichiers sql dans le répertoire d'initialisation de la base de données
COPY init/. /docker-entrypoint-initdb.d/

# Expose le port 5432
EXPOSE 5432

```

## Backend API

*1-2 Why do we need a multistage build? And explain each step of this dockerfile.*
Le fait d'utiliser des stages, dans ce cas la, permet de ne pas importer dans l'image final un JDK bien trop lourd avec Maven et les autres tools de build mais seulement un jdk leger pour lancer l'application final.

On pourrait imaginer un système avec deux containers séparés avec un volume commun mais ca serait bien plus lourd et innutile comparé à des stages

```dockerfile
# Build
#premier stage nommé "myapp-build", il part d'une image d'un jdk qui comprends maven, qui est un gestionnaire de dépendances
FROM maven:3.8.6-amazoncorretto-17 AS myapp-build
# on définie le workdir de l'image docker, les commandes seront exécutés dedans
ENV MYAPP_HOME /opt/myapp
WORKDIR $MYAPP_HOME
# on copie les sources et le pom.xml
COPY pom.xml .
COPY src ./src
# On télécharge les dépendances
#RUN mvn dependency:go-offline
# on build l'application avec maven
# on build l'application avec maven
RUN mvn package -DskipTests

# Run
# on lance un jdk
FROM amazoncorretto:17
# on définie le workdir de l'image docker, les commandes seront exécutés dedans
ENV MYAPP_HOME=/opt/myapp \
    DB_CONFIG_URL=jdbc:postgresql://db:5432/db \
    POSTGRES_USER=admin \
    POSTGRES_PASSWORD=admin
WORKDIR $MYAPP_HOME
# en deplace le jar build dans l'autre stage dans le répertoire courant
COPY --from=myapp-build $MYAPP_HOME/target/*.jar $MYAPP_HOME/myapp.jar
EXPOSE 8080
ENTRYPOINT java -jar myapp.jar

```

on build le back `docker build -t lazarec/backend backend`

on lance le container:

```bash
docker run \
-p 8080:8080 \
--name backend \
--env-file ./.env \
--net=app-network \
-d \
lazarec/backend
```

## Reverse proxy

**Why do we need a reverse proxy?**
Un reverse proxy permet plusieurs chose, dans notre cas il peut permettre dans notre cas, de passer de HTTP en HTTPS sans devoir gérer la partie SSL en java. Il permet aussi d'avoir plusieurs endpoints sur le même ports qui seront redigirer sur différents services (ou docker). Il permet aussi le load balancing et même faire de la sécurité.

Pour avoir la config et la modifier je la récupère directement de l'image avec la commande: `docker run --rm httpd cat /usr/local/apache2/conf/httpd.conf > localhost.conf`

on build le proxy: `docker build -t lazarec/proxy proxy`

on lance le proxy:

```bash
docker run \
-p 80:80 \
--name proxy \
--net=app-network \
-d \
lazarec/proxy
```

## Docker compose

**1-3 Document docker-compose most important commands.**

`docker-compose up -d`: permet de lancer les services qui sont down et de se détacher pour que les containers tourent en arrière-plan

`docker-compose down`: permet de stopper les services du docker compose ainsi que les networks ect...

`docker-compose logs -f`: permet de voir les logs de tous les services et de follow

`docker-compose ps`: permet de voir les services en cours

**1-4 Document your docker-compose file.**

```yaml
#version du docker compose
version: "3.7"

#liste des services
services:
  #service backend
  backend:
    #c'est un service à build avant de lancer, on lui donne le contexte
    build:
      context: ./backend
    #on donne le network
    networks:
      - my-network
    #on donne les variables d'env
    env_file: .env
    #on attend que la base de donnée soit en ligne
    depends_on:
      - database
    #on précise le nom dans le réseau
    hostname: backend

  database:
    build:
      context: ./postgres
    networks:
      - my-network
    #on indique le volume à utiliser
    volumes:
      - devops-postgres:/var/lib/postgresql/data
    env_file: .env
    hostname: postgres

  httpd:
    build:
      context: ./proxy
    #on indique le port à ouvrir sur la machine host
    ports:
      - "80:80"
    networks:
      - my-network
    env_file: .env
    depends_on:
      - backend
    hostname: proxy

#on initialise le network
networks:
  my-network:

#on initialise le volume de la bd
volumes:
  devops-postgres:
```
