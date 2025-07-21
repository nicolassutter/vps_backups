import { create as tarCreate } from "tar";
import path from "path";
import fs from "fs/promises";
import { accessSync } from "fs";
import { backupSqlite, uploadToMinio } from "../../utils";

export async function backupVaultwarden(): Promise<void> {
  const VW_DATA_DIR = "/vw-data";
  const TMP_DIR = "/tmp";
  const timestamp = new Date().toISOString();
  const sourceDb = "/vw-data/db.sqlite3";
  const dbBackupPath = path.join(TMP_DIR, `backup_${timestamp}.sqlite3`);
  const outputTarGz = `archive_${timestamp}.tar.gz`;

  // Ensure tmp directory exists
  await fs.mkdir(TMP_DIR, { recursive: true });

  async function cleanup(): Promise<void> {
    try {
      await fs.unlink(outputTarGz);
      console.log(`➡️ Removed archive: ${outputTarGz}`);
    } catch {
      console.log(`🤔 No archive to remove: ${outputTarGz}`);
    }

    try {
      await fs.unlink(dbBackupPath);
      console.log(`➡️ Removed SQLite backup: ${dbBackupPath}`);
    } catch {
      console.log(`🤔 No SQLite backup to remove: ${dbBackupPath}`);
    }
  }

  async function createTarArchive(filesToBackup: string[]): Promise<void> {
    const files = filesToBackup.filter((file) => {
      try {
        accessSync(file);
        return true;
      } catch {
        console.log(`❌ File not found: ${file}`);
        return false;
      }
    });

    await tarCreate(
      {
        gzip: true,
        file: outputTarGz,
        cwd: "/", // Set working directory to root
        // portable: true,
      },
      files,
    );

    console.log(`✅ Created archive ${outputTarGz}`);
  }

  try {
    // Backup SQLite database
    await backupSqlite({
      sourcePath: sourceDb,
      backupPath: dbBackupPath,
    });

    // Define files to backup
    const filesToBackup = [
      `${VW_DATA_DIR}/config.json`,
      `${VW_DATA_DIR}/attachments`,
      `${VW_DATA_DIR}/rsa_key.pem`,
      dbBackupPath,
    ];

    // Create tar.gz archive
    await createTarArchive(filesToBackup);
    await uploadToMinio({
      filePath: outputTarGz,
    });
  } catch (error) {
    console.error(`❌ Backup failed: ${error}`);
    await cleanup();
    process.exit(1);
  }
}
