from flask import Flask, render_template
import os
import psycopg2

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        database=os.getenv("POSTGRES_DB", "studentdb"),
        user=os.getenv("POSTGRES_USER", "postgres"),
        password=os.getenv("POSTGRES_PASSWORD", "postgres")
    )


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/health")
def health():
    try:
        connection = get_db_connection()
        connection.close()
        return {"status": "healthy"}, 200
    except Exception:
        return {"status": "unhealthy"}, 503


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)