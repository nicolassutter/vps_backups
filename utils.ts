import path from "node:path";
import { Database } from "bun:sqlite";
import { z } from "zod";

export async function backupSqlite(config: {
  sourcePath: string;
  backupPath: string;
}): Promise<void> {
  const db = new Database(config.sourcePath, { readonly: true });
  // backup
  db.query("VACUUM INTO ?").run(config.backupPath);
  console.log(`✅ SQLite backup successful: ${config.backupPath}`);
}

export function readEnv() {
  return z
    .object({
      MINIO_ENDPOINT: z.string().min(1, "MINIO_ENDPOINT is required"),
      MINIO_ACCESS_KEY: z.string().min(1, "MINIO_ACCESS_KEY is required"),
      MINIO_SECRET_KEY: z.string().min(1, "MINIO_SECRET_KEY is required"),
      MINIO_BUCKET_NAME: z.string().min(1, "MINIO_BUCKET_NAME is required"),
    })
    .parse(process.env);
}

export async function uploadToMinio(config: {
  filePath: string;
  fileNameInBucket?: string;
}): Promise<void> {
  const env = z
    .object({
      MINIO_ENDPOINT: z.string().min(1, "MINIO_ENDPOINT is required"),
      MINIO_ACCESS_KEY: z.string().min(1, "MINIO_ACCESS_KEY is required"),
      MINIO_SECRET_KEY: z.string().min(1, "MINIO_SECRET_KEY is required"),
      MINIO_BUCKET_NAME: z.string().min(1, "MINIO_BUCKET_NAME is required"),
    })
    .parse(process.env);

  const { Client: MinioClient } = await import("minio");

  const client = new MinioClient({
    endPoint: env.MINIO_ENDPOINT,
    accessKey: env.MINIO_ACCESS_KEY,
    secretKey: env.MINIO_SECRET_KEY,
  });

  try {
    const bucketExists = await client.bucketExists(env.MINIO_BUCKET_NAME);

    if (!bucketExists) {
      console.error(
        `❌ Bucket '${env.MINIO_BUCKET_NAME}' does not exist. Please create it first.`,
      );
      process.exit(1);
    }

    const objectName =
      config.fileNameInBucket ?? path.basename(config.filePath);

    // Upload the file
    await client.fPutObject(env.MINIO_BUCKET_NAME, objectName, config.filePath);

    console.log(
      `🚀 Uploaded '${config.filePath}' to bucket '${env.MINIO_BUCKET_NAME}' as '${objectName}'`,
    );
  } catch (err) {
    console.error(`❌ Error during minio upload: ${err}`);
    process.exit(1);
  }
}
