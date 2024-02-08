# CPE - Devops 4IRC

## Introduction

Trois TP sur docker, github action, ansible. Le code est commenté directement dans les README

## Table of Contents

- [TP n°1 sur Docker](<./README TP1.md>)
- [TP n°2 sur Github Action](<./README TP2.md>)
- [TP n°3 sur Ansible & extra](<./README TP3.md>)

## Usage

1. copier le fichier `.env.example` en `.env` pour lancer docker compose
2. le vault contient la data:

    ```yaml
    spring_db_url: jdbc:postgresql://postgres:5432/db
    db_user: admin
    db_pass: admin
    db_db: db
    ```
