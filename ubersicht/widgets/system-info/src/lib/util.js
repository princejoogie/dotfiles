import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * cn
 * @param {import("clsx").ClassValue[]} inputs - inputs
 * @returns {string} - className
 */
export function cn(...inputs) {
  return twMerge(clsx(inputs));
}
