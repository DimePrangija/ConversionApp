from datetime import datetime
from pathlib import Path
import sqlite3
from typing import List

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

DB_PATH = Path(__file__).parent / "db.sqlite3"

app = FastAPI(title="ConversionApp Server", version="1.0.0")


def get_connection():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS conversions (
            id TEXT PRIMARY KEY,
            input_value REAL NOT NULL,
            from_unit TEXT NOT NULL,
            to_unit TEXT NOT NULL,
            result REAL NOT NULL,
            timestamp TEXT NOT NULL
        );
        """
    )
    return conn


class ConversionPayload(BaseModel):
    id: str = Field(..., description="Client-generated UUID")
    inputValue: float
    fromUnit: str
    toUnit: str
    result: float
    timestamp: datetime


@app.post("/convert", status_code=201)
async def log_conversion(payload: ConversionPayload):
    conn = get_connection()
    try:
        conn.execute(
            """
            INSERT OR REPLACE INTO conversions (id, input_value, from_unit, to_unit, result, timestamp)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                payload.id,
                payload.inputValue,
                payload.fromUnit,
                payload.toUnit,
                payload.result,
                payload.timestamp.isoformat(),
            ),
        )
        conn.commit()
    except sqlite3.DatabaseError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    finally:
        conn.close()
    return {"status": "ok"}


@app.get("/history", response_model=List[ConversionPayload])
async def get_history():
    conn = get_connection()
    try:
        rows = conn.execute(
            "SELECT * FROM conversions ORDER BY datetime(timestamp) DESC LIMIT 50"
        ).fetchall()
        return [
            ConversionPayload(
                id=row["id"],
                inputValue=row["input_value"],
                fromUnit=row["from_unit"],
                toUnit=row["to_unit"],
                result=row["result"],
                timestamp=datetime.fromisoformat(row["timestamp"]),
            )
            for row in rows
        ]
    finally:
        conn.close()


@app.delete("/history", status_code=204)
async def clear_history():
    conn = get_connection()
    try:
        conn.execute("DELETE FROM conversions")
        conn.commit()
    finally:
        conn.close()
    return {"status": "cleared"}


@app.get("/health")
async def health_check():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)
