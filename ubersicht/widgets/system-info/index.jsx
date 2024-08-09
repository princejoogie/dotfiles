import "./src/tw";
import { getMemoryUsage } from "./src/memory";
import { getCpuUsage } from "./src/cpu";
import { Hexagon } from "./src/components/hexagon";
import { CpuIcon, DatabaseIcon } from "./src/lib/icons";

export const refreshFrequency = 1000;

/**
 * initialState
 * @type {import("./types").InitialState}
 */
export const initialState = { output: "", cpu: "00.00", memory: "00.00" };

/**
 * updateState
 * @param {import("./types").UpdateEvent} event - event object
 * @param {import("./types").InitialState} previousState - previous state
 * @returns {import("./types").InitialState} - updated state
 */
export const updateState = (event, previousState) => {
  switch (event.type) {
    case "SET_CPU":
      return { ...previousState, cpu: event.data };
    case "SET_MEMORY":
      return { ...previousState, memory: event.data };
    default: {
      return previousState;
    }
  }
};

export const command = (dispatch) => {
  getCpuUsage().then((e) => {
    dispatch({ type: "SET_CPU", data: e });
  });

  getMemoryUsage().then((e) => {
    dispatch({ type: "SET_MEMORY", data: e });
  });
};

export const render = (props) => {
  return (
    <div className="p-2 fixed bottom-2 left-2 font-mono text-xs">
      <Hexagon className="fixed bottom-[calc(80px+10px)]">
        <div className="flex flex-col items-center gap-1 mb-1">
          <div className="flex items-center gap-1">
            <CpuIcon />
            <p>CPU1</p>
          </div>
          <span className="text-green-300">{props.cpu}%</span>
        </div>
      </Hexagon>

      <Hexagon className="fixed bottom-[calc(40px+9px)] left-[calc(90px)]">
        <div className="flex flex-col items-center gap-1 mb-1">
          <div className="flex items-center gap-1">
            <CpuIcon />
            <p>CPU2</p>
          </div>
          <span className="text-green-300">{props.cpu}%</span>
        </div>
      </Hexagon>

      <Hexagon className="fixed bottom-[calc(80px+9px)] left-[calc(164px)]">
        <div className="flex flex-col items-center gap-1 mb-1">
          <div className="flex items-center gap-1">
            <CpuIcon />
            <p>CPU3</p>
          </div>
          <span className="text-green-300">{props.cpu}%</span>
        </div>
      </Hexagon>

      <Hexagon className="fixed bottom-2">
        <div className="flex flex-col items-center gap-1">
          <div className="flex items-center gap-1">
            <DatabaseIcon />
            <p>MEM</p>
          </div>
          <span className="text-green-300">{props.memory}%</span>
        </div>
      </Hexagon>
    </div >
  );
};
