"""Ingestão do arquivo diário de leads exportado do CRM (Excel).

Extract + Load: lê o CSV como texto e grava em raw_crm.leads.
Nenhuma conversão de tipo acontece aqui; isso é papel do staging no dbt.

Uso:
    uv run python ingestion/files/leads.py data/raw/crm/leads_20261016.csv
"""

import csv
import logging
import os
import sys
from pathlib import Path

import psycopg

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("leads")

# Decisão 1: formato declarado, nunca adivinhado.
FILE_ENCODING = "cp1252"
FILE_DELIMITER = ";"

# Decisão 4: contrato de esquema do arquivo.
EXPECTED_COLUMNS = [
    "lead_id", "nome", "email", "origem", "status",
    "criado_em", "atualizado_em", "valor_estimado",
]

CREATE_SCHEMA = "create schema if not exists raw_crm"

# Decisão 3: tudo em text (espelho da fonte) + colunas de controle da carga.
CREATE_TABLE = """
create table if not exists raw_crm.leads (
    lead_id         text,
    nome            text,
    email           text,
    origem          text,
    status          text,
    criado_em       text,
    atualizado_em   text,
    valor_estimado  text,
    _source_file    text        not null,
    _row_number     integer     not null,
    _loaded_at      timestamptz not null default now()
)
"""


def read_file(path: Path) -> list[dict[str, str]]:
    """Lê o CSV e valida o contrato de colunas antes de qualquer contato com o banco."""
    with open(path, encoding=FILE_ENCODING, newline="") as file:
        reader = csv.DictReader(file, delimiter=FILE_DELIMITER)
        columns = reader.fieldnames or []

        missing = [c for c in EXPECTED_COLUMNS if c not in columns]
        if missing:
            raise ValueError(
                f"{path.name}: colunas obrigatórias ausentes {missing}. "
                f"Colunas encontradas: {columns}"
            )

        extra = [c for c in columns if c not in EXPECTED_COLUMNS]
        if extra:
            log.warning("%s: colunas novas serão ignoradas: %s", path.name, extra)

        rows = list(reader)

    if not rows:
        raise ValueError(f"{path.name}: arquivo sem nenhum lead. Exportação incompleta?")

    return rows


def connect() -> psycopg.Connection:
    return psycopg.connect(
        host=os.environ["DBT_POSTGRES_HOST"],
        port=os.environ["DBT_POSTGRES_PORT"],
        user=os.environ["DBT_POSTGRES_USER"],
        password=os.environ["DBT_ENV_SECRET_POSTGRES_PASSWORD"],
        dbname=os.environ["DBT_POSTGRES_DATABASE"],
    )


def load(rows: list[dict[str, str]], source_file: str) -> int:
    """Decisão 2: substitui a fatia deste arquivo, numa única transação."""
    columns = EXPECTED_COLUMNS + ["_source_file", "_row_number"]
    placeholders = ", ".join(["%s"] * len(columns))
    insert_sql = f"insert into raw_crm.leads ({', '.join(columns)}) values ({placeholders})"

    # Linha 1 do arquivo é o cabeçalho, então o primeiro lead está na linha 2.
    values = [
        [row[c] for c in EXPECTED_COLUMNS] + [source_file, line_number]
        for line_number, row in enumerate(rows, start=2)
    ]

    with connect() as conn:
        with conn.transaction():
            conn.execute(CREATE_SCHEMA)
            conn.execute(CREATE_TABLE)
            deleted = conn.execute(
                "delete from raw_crm.leads where _source_file = %s", (source_file,)
            ).rowcount
            with conn.cursor() as cursor:
                cursor.executemany(insert_sql, values)

    return deleted


def main() -> None:
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)

    path = Path(sys.argv[1])
    rows = read_file(path)
    deleted = load(rows, path.name)
    log.info("%s: %d linhas da carga anterior removidas, %d inseridas",
             path.name, deleted, len(rows))


if __name__ == "__main__":
    main()