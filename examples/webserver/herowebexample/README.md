<h1>Hero Webserver</h2>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Deploy Locally](#deploy-locally)
  - [Prerequisites](#prerequisites)
  - [Deploy with Makefile](#deploy-with-makefile)

---

## Introduction

This contains the Hero Webserver code.

## Deploy Locally

We provide a script that first deploys Hero, Vlang and Crystallib on a Ubuntu Docker container, then it runs the Hero Webserver. You can use Makefile to run it.

### Prerequisites

- Docker Engine
- SSH keys added on GitHub with local paths `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`

### Deploy with Makefile

```
make run
```