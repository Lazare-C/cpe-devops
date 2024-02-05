FROM postgres:14.1-alpine

# Set environment variables
# Valeur par défaut remplacé par le .env au moment du docker run
ENV POSTGRES_DB=db \
    POSTGRES_USER=usr \
    POSTGRES_PASSWORD=pwd


# Copie des fichiers sql dans le répertoire d'initialisation de la base de données
COPY CreateScheme.sql/ /docker-entrypoint-initdb.d/
COPY InsertData.sql/ /docker-entrypoint-initdb.d/

# Expose le port 5432
EXPOSE 5432