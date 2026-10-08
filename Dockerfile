FROM python:3.8-slim-bullseye

RUN printf '%s\n' \
    'deb http://snapshot.debian.org/archive/debian/20240926T000000Z bullseye main' \
    'deb http://snapshot.debian.org/archive/debian-security/20240926T000000Z bullseye-security main' \
    'deb http://snapshot.debian.org/archive/debian/20240926T000000Z bullseye-updates main' \
    > /etc/apt/sources.list && \
    printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99snapshot

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        git \
        build-essential \
        gcc \
        g++ \
        wkhtmltopdf \
        make \
        libpq-dev \
        libldap2-dev \
        libsasl2-dev \
        libxml2-dev \
        libxslt1-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libffi-dev \
        libssl-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libwebp-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        freetds-dev \
        libkrb5-dev \
        libxcb1 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        xfonts-75dpi \
        xfonts-base \
        fonts-dejavu \
        node-less \
        npm \
        && rm -rf /var/lib/apt/lists/*

RUN echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client-14 && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch 14.0 https://github.com/odoo/odoo.git /opt/odoo

WORKDIR /opt/odoo

RUN python -m pip install --no-cache-dir --upgrade \
        pip \
        setuptools \
        wheel

RUN pip install --upgrade "pip<24.1" "setuptools<70" wheel "Cython<3"

RUN pip install --no-cache-dir "Cython==0.29.21"

RUN pip install --no-cache-dir --no-build-isolation -r requirements.txt

# --- Library tambahan untuk modul-modul custom (ditambahkan 2026-10-03) ---
# izi_data:                pandas, sqlparse, xlsxwriter, requests
# upgrade_analysis:        odoorpc, openupgradelib
# sql_export_excel:        openpyxl
# auto_database_backup:    paramiko, boto3, dropbox, pyncclient, nextcloud-api-wrapper
# izi_tokopedia (2026-10-08): pycryptodomex, backports-datetime-fromisoformat
# izi_data_lib_* (2026-10-08): mysql-connector-python, gspread, oauth2client
# izi_data_lib_mssql (2026-10-08): pymssql
RUN pip install --no-cache-dir \
        pandas \
        "sqlparse>=0.4.2" \
        xlsxwriter \
        requests \
        odoorpc \
        openupgradelib \
        openpyxl \
        paramiko \
        boto3 \
        dropbox \
        pyncclient \
        nextcloud-api-wrapper \
        pycryptodomex \
        backports-datetime-fromisoformat \
        mysql-connector-python \
        gspread \
        oauth2client

# pymssql tidak punya wheel ARM64 untuk Python 3.8, jadi compile dari source:
# butuh Cython 0.29.21 (sudah dipasang di atas) + header FreeTDS & Kerberos,
# dan versinya ditentukan setuptools_scm (tidak ada .git saat build image).
RUN pip install --no-cache-dir "setuptools_scm==7.1.0" && \
    SETUPTOOLS_SCM_PRETEND_VERSION=2.2.7 pip install --no-cache-dir --no-build-isolation "pymssql==2.2.7"

RUN npm install -g rtlcss

RUN mkdir -p \
        /var/lib/odoo \
        /mnt/extra-addons \
        /mnt/custom-addons \
        /etc/odoo

RUN useradd \
        --system \
        --home /var/lib/odoo \
        --shell /bin/bash \
        odoo

RUN chown -R odoo:odoo \
        /var/lib/odoo \
        /opt/odoo \
        /mnt/extra-addons \
        /mnt/custom-addons

COPY config/odoo.conf /etc/odoo/odoo.conf

RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo

EXPOSE 8069

CMD ["python3", "/opt/odoo/odoo-bin", "-c", "/etc/odoo/odoo.conf"]
