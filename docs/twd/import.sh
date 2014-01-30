#!/bin/bash
mongoimport --host dbh76.mongolab.com:27767 --db schemes -u root -p 2661 --collection schemes --type csv --headerline --file twd2.csv -vvvvv

