import sqlite3
import datetime
import os
import tarfile
import sys
from minio import Minio

vw_data_dir = "/vw-data"
tmp_dir = "/tmp"
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
source_db = "/vw-data/db.sqlite3"
db_backup_path = os.path.join(tmp_dir, f"backup_{timestamp}.sqlite3")
output_tar_gz = f"archive_{timestamp}.tar.gz"


os.makedirs(tmp_dir, exist_ok=True)

def cleanup():
    """Remove the archive and SQLite backup if they exist."""
    if os.path.exists(output_tar_gz):
        os.remove(output_tar_gz)
        print(f"➡️ Removed archive: {output_tar_gz}")
    else:
        print(f"🤔 No archive to remove: {output_tar_gz}")

    if os.path.exists(db_backup_path):
        os.remove(db_backup_path)
        print(f"➡️ Removed SQLite backup: {db_backup_path}")
    else:
        print(f"🤔 No SQLite backup to remove: {db_backup_path}")

def backup():
    # Open the source and destination connections
    with sqlite3.connect(f"{vw_data_dir}/db.sqlite3",) as src_conn:
        with sqlite3.connect(db_backup_path) as dest_conn:
            src_conn.backup(dest_conn)
            print(f"✅ SQLite backup successful: {db_backup_path}")

    files_to_backup = [
        f"{vw_data_dir}/config.json",
        f"{vw_data_dir}/attachments",
        f"{vw_data_dir}/rsa_key.pem",
        db_backup_path,
    ]

    object_name = output_tar_gz  # name in the bucket
    minio_endpoint = os.getenv("MINIO_ENDPOINT", "")
    minio_access_key = os.getenv("MINIO_ACCESS_KEY", "")
    minio_secret_key = os.getenv("MINIO_SECRET_KEY", "")
    bucket_name = os.getenv("MINIO_BUCKET_NAME", "")

    # Step 1: Create tar.gz archive
    with tarfile.open(output_tar_gz, "w:gz") as tar:
        for file_path in files_to_backup:
            if os.path.exists(file_path):
                tar.add(file_path, arcname=os.path.basename(file_path))
                print(f"✅ Added {file_path} to archive")
            else:
                print(f"🤔 File not found: {file_path}")

    print(f"✅ Created archive {output_tar_gz}")

    # Step 2: Upload to MinIO using minio-py
    client = Minio(
        minio_endpoint,
        access_key=minio_access_key,
        secret_key=minio_secret_key,
        # secure=True  # Change to True if using HTTPS
    )

    try:
        found = client.bucket_exists(bucket_name)

        if not found:
            print(f"Bucket '{bucket_name}' does not exist. Exiting.")
            cleanup()
            print(f"❌ Bucket '{bucket_name}' does not exist. Please create it first.", file=sys.stderr)
            raise Exception()

        # Upload the file
        client.fput_object(
            bucket_name,
            object_name,
            output_tar_gz,
        )

        cleanup()
        print(f"🚀 Uploaded '{output_tar_gz}' to bucket '{bucket_name}' as '{object_name}'")

    except Exception as err:
        print(f"❌ error during minio upload: {err}", file=sys.stderr)
        cleanup()
        raise SystemExit(1)

if __name__ == "__main__":
    backup()
