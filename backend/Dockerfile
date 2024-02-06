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
ENV MYAPP_HOME=/opt/myapp \
    DB_CONFIG_URL=jdbc:postgresql://db:5432/db \
    POSTGRES_USER=admin \
    POSTGRES_PASSWORD=admin
# on définie le workdir de l'image docker, les commandes seront exécutés dedans
WORKDIR $MYAPP_HOME
# en deplace le jar build dans l'autre stage dans le répertoire courant
COPY --from=myapp-build $MYAPP_HOME/target/*.jar $MYAPP_HOME/myapp.jar
EXPOSE 8080
ENTRYPOINT java -jar myapp.jar