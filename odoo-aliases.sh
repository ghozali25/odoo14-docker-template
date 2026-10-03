# ===== Alias Docker Odoo 14 =====
# Tempel isi file ini ke ~/.zshrc atau ~/.bashrc, sesuaikan path
# docker-compose.yml di baris export, lalu jalankan: source ~/.zshrc
# (atau buka terminal baru).

export ODOO_COMPOSE="/mnt/storage/odoo14/docker-compose.yml"

alias odoo-start='docker compose -f $ODOO_COMPOSE start odoo'
alias odoo-stop='docker compose -f $ODOO_COMPOSE stop odoo'
alias odoo-restart='docker compose -f $ODOO_COMPOSE restart odoo'
alias odoo-status='docker compose -f $ODOO_COMPOSE ps'
alias odoo-logs='docker compose -f $ODOO_COMPOSE logs --tail=100 odoo'
alias odoo-logsf='docker compose -f $ODOO_COMPOSE logs -f odoo'
alias odoo-up='docker compose -f $ODOO_COMPOSE up -d'
alias odoo-down='docker compose -f $ODOO_COMPOSE down'
alias odoo-rebuild='docker compose -f $ODOO_COMPOSE up -d --build'

# User psql di bawah mengikuti POSTGRES_USER di .env (default odoo14).
alias odoo-db='docker exec -it odoo14-db psql -U odoo14 -d postgres'
alias odoo-shell='docker exec -it odoo14 bash'
