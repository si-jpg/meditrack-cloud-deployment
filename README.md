# MediTrack Cloud Deployment

Projet **GreenOps Solutions** — automatisation du déploiement d'un site web statique pour **MediTrack** sur AWS, avec **Terraform** et **Ansible**.

---

## Architecture

```
   Internet → CloudFront (HTTPS) → S3 (statique, chiffré)
                              ↘
                                EC2 (Nginx, backup) — VPC sécurisé
```

| Composant | Service AWS | Rôle |
|---|---|---|
| Réseau | VPC + sous-réseau public | Isolation et accès Internet |
| Hébergement | S3 (AES-256, OAC) | Fichiers HTML/CSS |
| Diffusion | CloudFront (TLS 1.2+) | CDN mondial, HTTPS forcé |
| Compute | EC2 t3.micro (EBS chiffré) | Serveur web Nginx (option) |

---

## Structure du dépôt

```
.
├── README.md             # Ce fichier
├── terraform/            # Code IaC AWS
│   ├── providers.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── s3.tf
│   ├── cloudfront.tf
│   ├── ec2.tf
│   └── outputs.tf
├── ansible/              # Configuration serveur
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yml
│   └── requirements.yml
├── site/                 # Site statique MediTrack
│   ├── index.html
│   ├── services.html
│   ├── contact.html
│   ├── error.html
│   ├── css/style.css
│   └── images/
```

---

## Prérequis

- Linux ou WSL · `terraform >= 1.5` · `ansible >= 2.14` · `aws-cli >= 2`
- AWS configuré : `aws configure` puis `aws sts get-caller-identity` doit répondre
- Droits IAM suffisants (EC2, VPC, S3, CloudFront, création de clés)

---

## Déploiement express

```bash
# 1. Cloner
git clone https://github.com/si-jpg/meditrack-cloud-deployment.git
cd meditrack-cloud-deployment

# 2. Infrastructure (~5–10 min, CloudFront se déploie en arrière-plan)
cd terraform && terraform init && terraform apply -auto-approve

# 3. Site sur S3 + invalidation cache CloudFront
aws s3 sync ../site/ s3://$(terraform output -raw s3_bucket_name)/ --delete
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"

# 4. EC2 (optionnel, ~5 min)
cd ../ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory.ini playbook.yml \
  -e ansible_host="$(cd ../terraform && terraform output -raw ec2_public_ip)" \
  --private-key "$(find ../terraform -maxdepth 1 -name '*.pem' -print -quit)"

# 5. URL publique
cd ../terraform && terraform output cloudfront_url
```

URL CloudFront disponible dans le navigateur (attendre 5 min si la page met du temps à apparaître).

---

## Sécurité (RGPD / HDS)

| Mesure | Implémentation |
|---|---|
| **Région UE** | `eu-west-3` (Paris) — données dans l'Union européenne |
| **IAM** | Utilisateur dédié, moindre privilège (5 politiques managées) |
| **S3** | Chiffrement AES-256, Block Public Access, accès via OAC uniquement |
| **EBS** | Volumes EC2 chiffrés (KMS) |
| **TLS** | CloudFront force HTTPS, TLS 1.2 minimum |
| **Réseau** | Security Group : 22/80/443 uniquement |
| **OS** | UFW activé, Fail2ban, SSH durci (no root, no password) |
| **EC2 metadata** | IMDSv2 obligatoire (`http_tokens = required`) |

---

## Licence

MIT — usage pédagogique uniquement.
