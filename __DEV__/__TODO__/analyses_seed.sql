-- MySQL dump 10.13  Distrib 5.7.13, for osx10.11 (x86_64)
--
-- Host: localhost    Database: boite-a-outils_biblio
-- ------------------------------------------------------
-- Server version	5.7.13


-- Pour ré-injecter les données :
-- se placer dans ce dossier et incorporer dans mysql :
-- cd '/Users/philippeperret/Sites/WriterToolbox2/__DEV__/__TODO__'
-- mysql < analyses_seed.sql

USE `boite-a-outils_biblio`;

TRUNCATE TABLE user_per_analyse;

-- JAWS

-- Créator : Phil

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (1, 67, 1|32|64|128|256, 1462053600, 1462053600);

-- Correctrice : Marion

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (3, 67, 1|4, 1462065600, 1462065600);

-- MINORITY REPORT

-- Créator : Phil

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (1, 102, 1|32|64|128|256, 1456354800, 1456354800);

-- Correctrice : Marion

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (3, 102, 1|4, 1459116000, 1459116000);


-- ROCKY #125 (25-02-2016)

-- Créator : Phil

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (1, 125, 1|32|64|128|256, 1456354800, 1456354800);

-- Correctrice : Marion

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (3, 125, 1|4, 1464213600, 1464213600);


-- THE LAST SAMOURAI #249 (28-12-2016)

-- Créator : Phil

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (1, 249, 1|32|64|128|256, 1482879600, 1482879600);

-- Co-créateur : Benoit

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (2, 249, 1|16|64|128, 1482891600, 1482891600);

-- Correctrice : Marion

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES (3, 249, 1|4, 1483570800, 1483570800);
