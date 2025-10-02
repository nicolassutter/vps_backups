// @ts-check
import { existsSync } from 'fs';
import { $ } from 'bun';

// Files to check for existence
const filesToCheck = ['config.json', 'attachments', 'rsa_key.pem'];

// Find which files actually exist
const existingFiles = filesToCheck.filter(file => existsSync(file));

if (existingFiles.length === 0) {
    console.error('Error: No files found to backup');
    process.exit(1);
}

try {
    await $`tar -cz ${existingFiles}`; // output to stdout so we can pipe it later
} catch (error) {
    console.error('Error creating tar archive:', error.message);
    process.exit(1);
}