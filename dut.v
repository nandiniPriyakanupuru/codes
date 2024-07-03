
module clk(
    input wire clk,
    input wire reset,
    output reg start_of_frame,
    output reg pulse_repetition_interval,
    output reg end_of_frame
);

    // Parameters
    parameter SOF_WIDTH = 4;  // in microseconds
    parameter PRI_WIDTH = 30; // in microseconds
    parameter PRI_PERIOD = 100; // in microseconds
    parameter EOF_WIDTH = 12; // in microseconds
    parameter EOF_PERIODS = 50; // Number of PRIs after which EOF occurs

    // Clock frequency
    parameter CLK_FREQ = 100_000_00; // 100 MHz

    // Clock cycles calculation
    localparam SOF_CYCLES = (SOF_WIDTH * CLK_FREQ) / 1_000_000;
    localparam PRI_CYCLES = (PRI_WIDTH * CLK_FREQ) / 1_000_000;
    localparam PRI_PERIOD_CYCLES = (PRI_PERIOD * CLK_FREQ) / 1_000_000;
    localparam EOF_CYCLES = (EOF_WIDTH * CLK_FREQ) / 1_000_000;
    localparam EOF_PERIOD_CYCLES = EOF_PERIODS * PRI_PERIOD_CYCLES;

    // Counters
    reg [31:0] counter;
    reg [31:0] pri_counter;
    reg [1:0] current_state, next_state;
parameter IDLE=2'd0,SOF=2'd1,PRI=2'd2,EOF=2'd3;
    // State Machine States
//    typedef enum logic [1:0] {
//        IDLE,
//        SOF,
//        PRI,
//        EOF
//    } state_t;

    //state_t current_state, next_state;

    // State Machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            counter <= 0;
            pri_counter <= 0;
            start_of_frame <= 0;
            pulse_repetition_interval <= 0;
            end_of_frame <= 0;
        end else begin
            current_state <= next_state;

            case (current_state)
                IDLE: begin
                    counter <= 0;
                    pri_counter <= 0;
                    start_of_frame <= 0;
                    pulse_repetition_interval <= 0;
                    end_of_frame <= 0;
                end
                SOF: begin
                    if (counter < SOF_CYCLES) begin
                        counter <= counter + 1;
                        start_of_frame <= 1;
                    end else begin
                        counter <= 0;
                        start_of_frame <= 0;
                        next_state <= PRI;
                    end
                end
                PRI: begin
                    if (counter < PRI_PERIOD_CYCLES) begin
                        counter <= counter + 1;
                        if (counter < PRI_CYCLES) begin
                            pulse_repetition_interval <= 1;
                        end else begin
                            pulse_repetition_interval <= 0;
                        end
                    end else begin
                        counter <= 0;
                        pri_counter <= pri_counter + 1;
                        if (pri_counter < EOF_PERIODS - 1) begin
                            next_state <= PRI;
                        end else begin
                            next_state <= EOF;
                        end
                    end
                end
                EOF: begin
                    if (counter < EOF_CYCLES) begin
                        counter <= counter + 1;
                        end_of_frame <= 1;
                    end else begin
                        counter <= 0;
                        end_of_frame <= 0;
                        next_state <= IDLE;
                    end
                end
            endcase
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: next_state = SOF;
            SOF: next_state = (counter < SOF_CYCLES) ? SOF : PRI;
            PRI: next_state = (pri_counter < EOF_PERIODS) ? PRI : EOF;
            EOF: next_state = (counter < EOF_CYCLES) ? EOF : IDLE;
            default: next_state = IDLE;
        endcase
    end

endmodule
