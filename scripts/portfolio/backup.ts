import path from "node:path";
import { Database } from "bun:sqlite";
import fs from "node:fs/promises";
import { z } from "zod";

const env = z
  .object({
    MINIO_ENDPOINT: z.string().min(1, "MINIO_ENDPOINT is required"),
    MINIO_ACCESS_KEY: z.string().min(1, "MINIO_ACCESS_KEY is required"),
    MINIO_SECRET_KEY: z.string().min(1, "MINIO_SECRET_KEY is required"),
    MINIO_BUCKET_NAME: z.string().min(1, "MINIO_BUCKET_NAME is required"),
  })
  .parse(process.env);

const TMP_DIR = "/tmp";
const timestamp = new Date().toISOString();
const sourceDb = "/my-data/data.db";
const dbBackupPath = path.join(TMP_DIR, `backup_portfolio_${timestamp}.db`);

// Ensure tmp directory exists
await fs.mkdir(TMP_DIR, { recursive: true });

async function backupSqlite(): Promise<void> {
  const db = new Database(sourceDb, { readonly: true });
  // backup
  db.query("VACUUM INTO ?").run(dbBackupPath);
  console.log(`✅ SQLite backup successful: ${dbBackupPath}`);
}

async function uploadToMinio(): Promise<void> {
  const { Client: MinioClient } = await import("minio");

  const client = new MinioClient({
    endPoint: env.MINIO_ENDPOINT,
    accessKey: env.MINIO_ACCESS_KEY,
    secretKey: env.MINIO_SECRET_KEY,
    // useSSL: true  // Change to true if using HTTPS
  });

  try {
    const bucketExists = await client.bucketExists(env.MINIO_BUCKET_NAME);

    if (!bucketExists) {
      console.error(
        `❌ Bucket '${env.MINIO_BUCKET_NAME}' does not exist. Please create it first.`,
      );
      process.exit(1);
    }

    const objectName = path.basename(dbBackupPath);
    // Upload the file
    await client.fPutObject(env.MINIO_BUCKET_NAME, objectName, dbBackupPath);
    console.log(
      `🚀 Uploaded '${dbBackupPath}' to bucket '${env.MINIO_BUCKET_NAME}' as '${objectName}'`,
    );
  } catch (err) {
    console.error(`❌ Error during minio upload: ${err}`);
    process.exit(1);
  }
}

async function backup(): Promise<void> {
  await backupSqlite();
  await uploadToMinio();
}

backup();
