## Postgres

on build postgres `docker build -t lazarec/postgres -f ./postgres/postgres.dockerfile postgres`

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

## Backend API
*1-2 Why do we need a multistage build? And explain each step of this dockerfile.*
Le fait d'utiliser des stages dans ce cas la permet de ne pas importer dans l'image un JDK bien trop lourd avec Maven et les autres tools de build mais seulement un jre leger pour lancer l'application final

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

