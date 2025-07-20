import path from "node:path";
import fs from "node:fs/promises";
import { backupSqlite, uploadToMinio, readEnv } from "../../utils";

export async function backupPortfolio(): Promise<void> {
  // throws if any required env variable is missing
  readEnv();

  const TMP_DIR = "/tmp";
  const timestamp = new Date().toISOString();
  const sourceDb = "/my-data/data.db";
  const dbBackupPath = path.join(TMP_DIR, `backup_portfolio_${timestamp}.db`);

  // Ensure tmp directory exists
  await fs.mkdir(TMP_DIR, { recursive: true });

  async function backup(): Promise<void> {
    await backupSqlite({
      sourcePath: sourceDb,
      backupPath: dbBackupPath,
    });

    await uploadToMinio({
      filePath: dbBackupPath,
    });
  }

  backup();
}
