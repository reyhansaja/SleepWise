"""Akses MySQL: satu koneksi per operasi, gagal lunak bila server mati."""
import logging
import threading
import time
from pathlib import Path

import mysql.connector

from config import BASE_DIR, Config

log = logging.getLogger(__name__)
_init_lock = threading.Lock()
_initialized = False
_DOWN_COOLDOWN = 5.0
_down_until = 0.0


def get_connection():
    """Kembalikan koneksi MySQL atau None bila tidak tersedia."""
    global _down_until
    if time.monotonic() < _down_until:
        return None
    try:
        return mysql.connector.connect(
            host=Config.MYSQL_HOST,
            port=Config.MYSQL_PORT,
            user=Config.MYSQL_USER,
            password=Config.MYSQL_PASSWORD,
            database=Config.MYSQL_DATABASE,
            connection_timeout=3,
            autocommit=True,
        )
    except mysql.connector.Error as exc:
        _down_until = time.monotonic() + _DOWN_COOLDOWN
        log.warning("MySQL tidak tersedia: %s", exc)
        return None


def available() -> bool:
    conn = get_connection()
    if conn is None:
        return False
    conn.close()
    return True


def query_all(sql: str, params: tuple = ()) -> list[dict]:
    conn = get_connection()
    if conn is None:
        return []
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params)
        return cur.fetchall()
    finally:
        conn.close()


def query_one(sql: str, params: tuple = ()):
    rows = query_all(sql, params)
    return rows[0] if rows else None


def execute(sql: str, params: tuple = ()):
    """INSERT/UPDATE; kembalikan lastrowid atau None bila DB mati."""
    conn = get_connection()
    if conn is None:
        return None
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        return cur.lastrowid
    finally:
        conn.close()


def execute_many(sql: str, rows: list[tuple]) -> int:
    conn = get_connection()
    if conn is None or not rows:
        return 0
    try:
        cur = conn.cursor()
        cur.executemany(sql, rows)
        return cur.rowcount
    finally:
        conn.close()


def init_schema() -> bool:
    """Buat tabel bila belum ada. Dipanggil sekali saat startup."""
    global _initialized
    with _init_lock:
        if _initialized:
            return True
        conn = get_connection()
        if conn is None:
            return False
        try:
            cur = conn.cursor()
            sql_text = (Path(BASE_DIR) / "database" / "schema.sql").read_text(encoding="utf-8")
            for statement in sql_text.split(";"):
                cleaned = "\n".join(
                    line for line in statement.splitlines() if not line.strip().startswith("--")
                ).strip()
                if cleaned:
                    cur.execute(cleaned)
            _initialized = True
            return True
        except mysql.connector.Error as exc:
            log.warning("Gagal menyiapkan skema: %s", exc)
            return False
        finally:
            conn.close()
