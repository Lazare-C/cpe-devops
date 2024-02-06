# TP 2

**2-1 What are testcontainers?**

Les tests containers sont des librairies java qui permetent de lancer des containers et dans ce cas la d'émuler une base de donnée afin de vérifier que le code fonctionne bien.

**2-2 Document your Github Actions configurations.**

```yaml
name: CI devops 2023
on:
  #to begin you want to launch this job in main and develop
  push:
    # on donne les branches à tester (la develop existe pas encore)
    branches:
      - main
      - develop
  pull_request:

jobs:
  test-backend:
    runs-on: ubuntu-22.04
    steps:
      #checkout your github code using actions/checkout@v2.5.0
      - uses: actions/checkout@v2.5.0

      #do the same with another action (actions/setup-java@v3) that enable to setup jdk 17
      - name: Set up JDK 17
      # on utilise l'action setup java officiel
        uses: actions/setup-java@v4
        with:
          # on utilise le même jdk que le Dockerfile
          distribution: 'corretto'
          # on précise la même version que le Dockerfile
          java-version: '17'

      #finally build your app with the latest command
      - name: Build and test with Maven
        #on run maven clean verify dans le dossier du backend
        run: mvn clean verify --file ./backend/
```

## Sonar Quality Gate

**Document your quality gate configuration.**
J'utilise la liste de règle par defaut pour Java: Sonar way