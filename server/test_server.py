from datetime import datetime
from fastapi.testclient import TestClient

from main import app, DB_PATH, get_connection

client = TestClient(app)


def setup_module(module=None):
    if DB_PATH.exists():
        DB_PATH.unlink()


def test_convert_and_history_flow():
    payload = {
        "id": "test-123",
        "inputValue": 10,
        "fromUnit": "pounds",
        "toUnit": "kilograms",
        "result": 4.5359237,
        "timestamp": datetime.utcnow().isoformat(),
    }

    response = client.post("/convert", json=payload)
    assert response.status_code == 201

    history = client.get("/history")
    assert history.status_code == 200
    items = history.json()
    assert len(items) == 1
    assert items[0]["id"] == "test-123"

    delete_response = client.delete("/history")
    assert delete_response.status_code == 204

    empty_history = client.get("/history")
    assert empty_history.status_code == 200
    assert empty_history.json() == []
