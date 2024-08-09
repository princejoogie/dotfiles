/**
 * Hexagon
 * @param {object} params - parameters
 * @param {import("react").ReactNode} params.children - children
 * @returns {import("react").ReactElement} - element
 */
export const Hexagon = ({ children }) => {
  return (
    <div className="m-1 bg-[#4A494A] flex items-center justify-center w-20 h-20 rounded-3xl backdrop-blur-lg overflow-clip text-[#F9F7FC] [clip-path:polygon(30%_0%,70%_0%,100%_30%,100%_70%,70%_100%,30%_100%,0%_70%,0%_30%)]">
      {children}
    </div>
  );
};
