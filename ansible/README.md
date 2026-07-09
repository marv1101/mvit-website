# MWST-Website – Ansible Provisionierung

Wiederholbare VPS-Einrichtung. `setup-server.yml` installiert Docker, Firewall,
Fail2ban und den Deploy-User – der gesamte Stack läuft danach über die Docker-
Compose-Datei `infra/compose-prod.yaml`.

## Aufruf

```bash
cd ansible

# 1. SSH-Key für den VPS-Root hinterlegen (z. B. via ~/.ssh/config)
# 2. inventory.yml mit VPS-IP/Domain und User prüfen

ansible-playbook -i inventory.yml playbooks/setup-server.yml
```

Anschließend als `mvit-deploy`-User (oder root) `infra/setup.sh` ausführen, um den
Stack zu bauen und zu starten.

## Rollen

| Rolle | Aufgabe |
|------|---------|
| `docker` | Docker-Engine + Compose-Plugin installieren |
| `security` | UFW (22/80/443), fail2ban, logrotate, Zeitzone |
| `deploy_user` | Benutzer `mvit-deploy` (in docker-Gruppe) + sudoers-Eintrag |