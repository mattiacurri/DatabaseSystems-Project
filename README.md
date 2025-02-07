# Brightway: Decentralized Logistics Management System

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Design](#system-design)
- [Database Schema](#database-schema)
- [Implementation](#implementation)
- [Triggers](#triggers)
- [Database Population](#database-population)
- [Web Application](#web-application)
- [Setup Instructions](#setup-instructions)

## Overview
Brightway is a database system designed to manage decentralized logistics operations. It facilitates efficient handling of orders, operational centers, teams, and customers, supporting services such as long-term storage and expedited shipping.

## Features
- **Decentralized Operations**: Multiple operational centers manage logistics independently.
- **Comprehensive Order Management**: Supports regular, urgent, and bulk orders.
- **Business Accounts**: Customers can have multiple business accounts.
- **Team Performance Tracking**: Orders are assigned to teams, and their performance is tracked based on customer feedback.
- **Database Integrity**: Uses triggers and constraints to maintain data consistency.
- **Web Interface**: Built with Flask for easy interaction with the database.

## System Design
Brightway follows a structured database design process, including:
- **Conceptual Design**: Entity-Relationship (ER) modeling for logistics management.
- **Logical Design**: Refining schema, redundancy analysis, and query optimization.
- **Physical Design**: Performance considerations for high-frequency operations.

## Database Schema
The schema includes:
- **OperationalCenter**: Name, address, city/province, number of employees.
- **Order**: Type, date, cost, customer information.
- **BusinessAccount**: Unique code per customer.
- **Team**: Employee groups handling orders, performance scores.
- **Customer**: Individual and business customers with order history.
- **Employee**: Assigned to teams, handling orders.

## Implementation
The database is implemented in Oracle SQL, utilizing:
- **Object-Relational Mapping (ORM)**: Using custom types (e.g., `AddressTY`, `OrderTY`).
- **Referential Constraints**: Ensuring consistency between entities.

## Triggers
Several triggers enforce business rules, including:
- **Order Constraints**: Prevent orders from being completed without an assigned team.
- **Team Management**: Limits team size to 8 employees.
- **Performance Tracking**: Updates team performance scores based on feedback.
- **Automatic Cleanup**: Ensures data integrity when entities are deleted.

## Database Population
Stored procedures populate the database with sample data:
- `populateCustomer`: Creates individual and business customers.
- `populateOrder`: Inserts new orders.
- `populateTeam`: Generates teams assigned to operational centers.
- `populateEmployee`: Assigns employees to teams.

## Web Application
A Flask web app provides an interface for interacting with the database. Features include:
- **Customer Registration** (`/register_customer`)
- **Order Management** (`/add_order`, `/assign_order`)
- **Team Performance** (`/team_stats`, `/teams_list`)

## Setup Instructions
### Prerequisites
- Python 3.x
- Oracle Database
- Flask (`pip install flask`)
- OracleDB (`pip install oracledb`)
