export type InitialState = { output: string; cpu: string; memory: string };

export type UpdateEvent =
    | {
        type: "SET_CPU";
        data: number;
    }
    | {
        type: "SET_MEMORY";
        data: number;
    }
    | {
        type: "SET_OUTPUT";
        data: string;
    };
