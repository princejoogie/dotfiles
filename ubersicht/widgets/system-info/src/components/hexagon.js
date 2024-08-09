import { cn } from "../lib/util";

export const heptagonClipPath =
  "[clip-path:polygon(30%_0%,70%_0%,100%_30%,100%_70%,70%_100%,30%_100%,0%_70%,0%_30%)]";

export const hexagonClipPath =
  "[clip-path:polygon(25%_0%,75%_0%,100%_50%,75%_100%,25%_100%,0%_50%)]";


/**
 * Hexagon
 * @param {object} params - parameters
 * @param {import("react").ReactNode} params.children - children
 * @param {string} params.className - className
 * @returns {import("react").ReactElement} - element
 */
export const Hexagon = ({ children, className = "" }) => {
  return (
    <div
      className={cn(`bg-opacity-40 m-1 bg-neutral-500 flex items-center justify-center w-24 h-20 rounded-3xl backdrop-blur-sm overflow-clip text-[#F9F7FC]`, hexagonClipPath, className)}
    >
      {children}
    </div>
  );
};
