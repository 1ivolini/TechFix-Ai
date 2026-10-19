from pathlib import Path
import sys

import pytest

# Caminho até a pasta que contém app.py e database.py
BACKEND_DIR = (
    Path(__file__).resolve().parents[1]
    / "Back-end"
    / "Banco de dados"
)

sys.path.insert(0, str(BACKEND_DIR))

import app as app_module


@pytest.fixture
def client():
    app_module.app.config.update(TESTING=True)

    with app_module.app.test_client() as client:
        yield client