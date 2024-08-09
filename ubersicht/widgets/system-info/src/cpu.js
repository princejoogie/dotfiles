import { run } from "uebersicht";

const UNITS = {
  year: 24 * 60 * 60 * 365,
  month: (24 * 60 * 60 * 365) / 12,
  day: 24 * 60 * 60,
  hour: 60 * 60,
  minute: 60,
  second: 0,
};

export const getTopCpuProcess = async (count) => {
  const output = await run("/bin/ps -Aceo pcpu,comm -r");
  const processList = output
    .trim()
    .split("\n")
    .slice(1, count + 1);
  const modProcessList = [];

  processList.forEach((value) => {
    let temp = value.trim().split(" ");
    temp = [temp[0], temp.slice(1).join(" ")];

    modProcessList.push(temp);
  });

  return modProcessList;
};

export const getRelativeTime = (uptime) => {
  const rtf = new Intl.RelativeTimeFormat("en");

  for (const unit in UNITS) {
    const seconds = UNITS[unit];

    if (uptime > seconds || unit == "second") {
      return rtf.format(-Math.round(uptime / seconds), unit);
    }
  }

  return "Unknown";
};

export const getCpuUsage = async () => {
  const output = +(
    await run("top -l 1 -s 0 | awk '/CPU usage/ {print $3 + $5}'")
  ).trim();
  return output.toFixed(2);
};
