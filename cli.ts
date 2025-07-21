import { program } from "@commander-js/extra-typings";
import { backupPortfolio } from "./scripts/portfolio/backup";
import { backupVaultwarden } from "./scripts/vaultwarden/backup";

program.command("portfolio-backup").action(async () => {
  await backupPortfolio();
});

program.command("vaultwarden-backup").action(async () => {
  await backupVaultwarden();
});

program.parse();
