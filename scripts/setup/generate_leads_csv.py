"""Gera arquivos de leads como o Excel brasileiro exporta: Windows-1252 e ponto e vírgula.

Simula duas exportações diárias do CRM. Cada arquivo traz TODOS os leads do dia.
"""

import csv
from pathlib import Path

OUTPUT_DIR = Path("data/raw/crm")

HEADER = ["lead_id", "nome", "email", "origem", "status",
          "criado_em", "atualizado_em", "valor_estimado"]

DAY_1 = [
    ["L001", "João Araújo",       "joao.araujo@email.com",  "Site",      "novo",        "10/10/2026", "10/10/2026 09:15", "1.299,90"],
    ["L002", "Mariana Conceição", "mariana.c@email.com",    "Indicação", "qualificado", "11/10/2026", "14/10/2026 16:40", "850,00"],
    ["L003", "Pedro Ribeiro",     "pedro.ribeiro@email.com", "LinkedIn", "novo",        "13/10/2026", "13/10/2026 11:02", "2.500,00"],
    ["L004", "Luísa Gonçalves",   "luisa.g@email.com",      "Site",      "perdido",     "08/10/2026", "15/10/2026 10:30", "430,00"],
]

DAY_2 = [
    ["L001", "João Araújo",       "joao.araujo@email.com",  "Site",      "qualificado", "10/10/2026", "16/10/2026 14:20", "1.299,90"],
    ["L002", "Mariana Conceição", "mariana.c@email.com",    "Indicação", "convertido",  "11/10/2026", "17/10/2026 09:05", "850,00"],
    ["L003", "Pedro Ribeiro",     "pedro.ribeiro@email.com", "LinkedIn", "novo",        "13/10/2026", "13/10/2026 11:02", "2.500,00"],
    ["L004", "Luísa Gonçalves",   "luisa.g@email.com",      "Site",      "perdido",     "08/10/2026", "15/10/2026 10:30", "430,00"],
    ["L005", "Antônio Simões",    "antonio.simoes@email.com", "Evento",  "novo",        "17/10/2026", "17/10/2026 08:45", "3.100,00"],
]


def write_file(file_name: str, rows: list[list[str]]) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUTPUT_DIR / file_name
    with open(path, "w", encoding="cp1252", newline="") as file:
        writer = csv.writer(file, delimiter=";")
        writer.writerow(HEADER)
        writer.writerows(rows)
    print(f"Gerado: {path} ({len(rows)} leads)")


if __name__ == "__main__":
    write_file("leads_20261016.csv", DAY_1)
    write_file("leads_20261017.csv", DAY_2)