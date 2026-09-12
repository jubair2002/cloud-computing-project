# EC2 GitHub Actions deployment guide

This repository can be deployed in two separate EC2 targets:

- Backend EC2 host: runs the Laravel API and queue/process service stack.
- Frontend EC2 host: hosts the built Vue static assets from the `front-end/dist` directory.

The deployment workflow in `.github/workflows/deploy.yml` expects the following GitHub repository secrets.

## Required GitHub Actions secrets

Create these secrets in the repository settings under `Settings → Secrets and variables → Actions`.

### EC2 connect secrets

| Secret name | Required | Example | Purpose |
| --- | --- | --- | --- |
| `EC2_BACKEND_HOST` | Yes | `13.211.77.22` | Public or private domain name / IP of the backend EC2 machine. |
| `EC2_FRONTEND_HOST` | Yes | `13.211.77.23` | Public or private domain name / IP of the frontend EC2 machine. |
| `EC2_USER` | Yes | `ubuntu` | SSH username for both boxes. |
| `EC2_SSH_KEY` | Yes | `-----BEGIN OPENSSH PRIVATE KEY-----...` | PEM/private key used by `appleboy/ssh-action`. |
| `EC2_SSH_PORT` | Optional | `22` | SSH port, defaults to `22` when left blank. |

### Backend deployment secrets

| Secret name | Required | Example | Purpose |
| --- | --- | --- | --- |
| `BACKEND_PROD_ENV_FILE` | Yes | Multi-line `.env` content | Full backend runtime environment file copied to the backend server before running the app. |
| `BACKEND_DEPLOY_DIR` | Yes | `/home/ubuntu/shophub` | Directory where the backend repo is cloned on the backend EC2 server. |
| `BACKEND_PORT` | Optional | `8000` | Backend HTTP port. |
| `DB_HOST` | Yes | `shophub-prod-db.xxxxxxxxx.us-east-1.rds.amazonaws.com` | RDS/MySQL hostname used by Laravel. |
| `DB_PORT` | Yes | `3306` | RDS/MySQL port. |
| `DB_DATABASE` | Yes | `shophub` | MySQL database name. |
| `DB_USERNAME` | Yes | `shophubapp` | MySQL username. |
| `DB_PASSWORD` | Yes | `strong-db-password` | MySQL password. |
| `DB_CONNECTION` | Yes | `mysql` | Database driver used by Laravel. |

### Frontend deployment secrets

| Secret name | Required | Example | Purpose |
| --- | --- | --- | --- |
| `VITE_API_BASE_URL` | Yes | `http://BACKEND_HOST:8000/api` | The API URL baked into the frontend production build. |
| `BACKEND_PUBLIC_HOST` | Yes | `13.211.77.22` | Public hostname or IP of the backend EC2 instance that the frontend should call. This is the value the browser and the frontend build should use to reach the API. |
| `FRONTEND_DEPLOY_DIR` | Yes | `/var/www/shophub-frontend` | Static file directory on the frontend EC2 server. |

### Backend machine `.env` variables

The backend deployment secret `BACKEND_PROD_ENV_FILE` should contain the variables needed by the Laravel project. At a minimum:

```env
APP_NAME=ShopHub
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY
APP_DEBUG=false
APP_URL=http://<BACKEND_PUBLIC_HOST>:8000

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=database
FILESYSTEM_DISK=local

MAIL_MAILER=smtp
MAIL_HOST=<smtp-host>
MAIL_PORT=587
MAIL_USERNAME=<smtp-username>
MAIL_PASSWORD=<smtp-password>
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=no-reply@example.com
MAIL_FROM_NAME="ShopHub"

FRONTEND_URL=http://<FRONTEND_PUBLIC_HOST>
SANCTUM_STATEFUL_DOMAINS=<FRONTEND_PUBLIC_HOST>:5173,localhost:5173

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://<BACKEND_PUBLIC_HOST>:8000/api/auth/google/callback

FACEBOOK_CLIENT_ID=
FACEBOOK_CLIENT_SECRET=
FACEBOOK_REDIRECT_URI=http://<BACKEND_PUBLIC_HOST>:8000/api/auth/facebook/callback

STRIPE_SECRET=
STRIPE_WEBHOOK_SECRET=

DEMO_MODE=false
DEMO_SANDBOX_CONFIRMED=false
DEMO_ADMIN_EMAIL=admin@shophub.test
DEMO_ADMIN_PASSWORD=<demo-admin-password>
DEMO_CUSTOMER_EMAIL=customer@shophub.test
DEMO_CUSTOMER_PASSWORD=<demo-customer-password>
```

### Frontend machine build variables

The frontend build is produced from the `front-end` project. The build must receive the API base URL:

```env
VITE_API_BASE_URL=http://<BACKEND_PUBLIC_HOST>:8000/api
```

You should pass the backend public host through GitHub Actions as the `BACKEND_PUBLIC_HOST` secret and then use that host to derive the build-time `VITE_API_BASE_URL` value, or store the full final value directly in the `VITE_API_BASE_URL` repository secret.

## EC2 deployment layout

Use two EC2 machines:

1. Backend EC2
   - Clones the repository and runs the Laravel PHP service using the docker compose file.
   - Stores `back-end/.env` from `BACKEND_PROD_ENV_FILE`.
   - Exposes port `8000` through the security group.

2. Frontend EC2
   - Builds the Vue static assets in GitHub Actions.
   - Uploads the generated `front-end/dist` bundle to a web directory such as `/var/www/shophub-frontend`.
   - Serves that directory through an Nginx or Apache vhost on port `80` or `443`.

## Recommended GitHub Action workflow usage

The repository already has CI workflows for backend and frontend in `.github/workflows/backend.yml` and `.github/workflows/frontend.yml`. The deployment workflow in `.github/workflows/deploy.yml` should be triggered only on the `main` branch and should use the above secrets, so a push to `main` produces a clean deployment without manual SSH commands.

## Security notes

- Never commit `.env` files to the repository.
- Store the `.env` contents as the `BACKEND_PROD_ENV_FILE` secret.
- Put the SSH private key in `EC2_SSH_KEY` rather than checking it into version control.
- Rotate `APP_KEY`, database passwords, and OAuth keys on every production deployment when needed.
- Use `APP_ENV=production` and `APP_DEBUG=false` for a real EC2 deployment.
