import { program } from "@commander-js/extra-typings";
import { backupPortfolio } from "./scripts/portfolio/backup";

program.command("portfolio-backup").action(async () => {
  await backupPortfolio();
});

program.parse();
