import { run } from "uebersicht";

export const getTopRamProcess = async () => {
  const output = await run("/usr/bin/top -l 1 -o mem -n 5 -stats command,mem");
  const processList = output.trim().split("\n").slice(12, 17);
  const modProcessList = [];

  processList.forEach((value) => {
    let temp = value.trim().split(" ");
    temp = [
      temp.slice(0, -1).join(" "),
      `${temp[temp.length - 1].slice(0, -1)} MB`,
    ];

    modProcessList.push(temp);
  });

  return modProcessList;
};

export const getMemoryUsage = async () => {
  const pHwPagesize = await run("/usr/sbin/sysctl -n hw.pagesize");
  const hwPagesize = parseFloat(pHwPagesize);
  const pMemTotal = await run("/usr/sbin/sysctl -n hw.memsize");
  const memTotal = parseFloat(pMemTotal) / 1024 / 1024;
  const pVmPagePageableInternalCount = await run(
    "/usr/sbin/sysctl -n vm.page_pageable_internal_count"
  );
  const pVmPagePurgeableCount = await run(
    "/usr/sbin/sysctl -n vm.page_purgeable_count"
  );
  const pagesApp =
    parseFloat(pVmPagePageableInternalCount) -
    parseFloat(pVmPagePurgeableCount);
  const pPagesWired = await run(
    "/usr/bin/vm_stat | awk '/ wired/ { print $4 }'"
  );
  const pagesWired = parseFloat(pPagesWired);
  const pPagesCompressed = await run(
    "/usr/bin/vm_stat | awk '/ occupied/ { printf $5 }'"
  );
  const pagesCompressed = parseFloat(pPagesCompressed) || 0;
  const memUsed =
    ((pagesApp + pagesWired + pagesCompressed) * hwPagesize) / 1024 / 1024;

  return Number(((memUsed / memTotal) * 100).toFixed(2));
};
