"""Test autentikasi: register (role user), login, token, dan gerbang role admin.

Jalankan: .venv\\Scripts\\python.exe -m unittest discover -s backend/tests -v
"""
import sys
import unittest
import uuid
from pathlib import Path

BACKEND = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND))

from database import db  # noqa: E402
from werkzeug.security import generate_password_hash  # noqa: E402


class AuthApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from app import create_app

        cls.client = create_app().test_client()
        if not db.available():
            raise unittest.SkipTest("MySQL tidak aktif")
        cls.email = f"uji-{uuid.uuid4().hex[:8]}@sleepwise.test"
        cls.admin_email = f"admin-{uuid.uuid4().hex[:8]}@sleepwise.test"
        cls.sandi = "rahasia123"

    @classmethod
    def tearDownClass(cls):
        db.execute("DELETE FROM users WHERE email IN (%s, %s)", (cls.email, cls.admin_email))

    def test_1_register_then_login(self):
        response = self.client.post("/api/auth/register", json={
            "nama_lengkap": "Budi Uji", "email": self.email, "kata_sandi": self.sandi,
        })
        self.assertEqual(response.status_code, 201, response.get_json())
        data = response.get_json()["data"]
        self.assertEqual(data["role"], "user")
        self.assertEqual(data["email"], self.email)
        self.assertTrue(data["token"])

        login = self.client.post("/api/auth/login", json={"email": self.email, "kata_sandi": self.sandi})
        self.assertEqual(login.status_code, 200, login.get_json())
        self.assertEqual(login.get_json()["data"]["role"], "user")

    def test_2_register_validation(self):
        body = self.client.post("/api/auth/register", json={"nama_lengkap": "Al"}).get_json()
        self.assertEqual(len(body["details"]), 3)

    def test_3_duplicate_email_rejected(self):
        payload = {"nama_lengkap": "Budi Uji", "email": self.email, "kata_sandi": self.sandi}
        self.assertEqual(self.client.post("/api/auth/register", json=payload).status_code, 409)

    def test_4_wrong_password_rejected(self):
        response = self.client.post(
            "/api/auth/login", json={"email": self.email, "kata_sandi": "salahsekali"}
        )
        self.assertEqual(response.status_code, 401)

    def test_5_token_protects_endpoints(self):
        token = self.client.post(
            "/api/auth/login", json={"email": self.email, "kata_sandi": self.sandi}
        ).get_json()["data"]["token"]

        me = self.client.get("/api/auth/me", headers={"Authorization": f"Bearer {token}"})
        self.assertEqual(me.status_code, 200)
        self.assertEqual(me.get_json()["data"]["email"], self.email)

        self.assertEqual(self.client.get("/api/auth/me").status_code, 401)
        self.assertEqual(
            self.client.get("/api/auth/me", headers={"Authorization": "Bearer palsu"}).status_code, 401
        )
        # user biasa tidak boleh melihat daftar user
        self.assertEqual(
            self.client.get("/api/auth/users", headers={"Authorization": f"Bearer {token}"}).status_code, 403
        )

    def test_6_admin_can_list_users(self):
        db.execute(
            "INSERT INTO users (full_name, email, password_hash, role) VALUES (%s, %s, %s, 'admin')",
            ("Admin Uji", self.admin_email, generate_password_hash(self.sandi)),
        )
        token = self.client.post(
            "/api/auth/login", json={"email": self.admin_email, "kata_sandi": self.sandi}
        ).get_json()["data"]["token"]

        response = self.client.get("/api/auth/users", headers={"Authorization": f"Bearer {token}"})
        self.assertEqual(response.status_code, 200)
        self.assertIn(self.email, {row["email"] for row in response.get_json()["data"]})


if __name__ == "__main__":
    unittest.main()
