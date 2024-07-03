
module clk_tb();

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire start_of_frame;
    wire pulse_repetition_interval;
    wire end_of_frame;

    // Instantiate the Unit Under Test (UUT)
    clk uut (
        .clk(clk),
        .reset(reset),
        .start_of_frame(start_of_frame),
        .pulse_repetition_interval(pulse_repetition_interval),
        .end_of_frame(end_of_frame)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test Sequence
    initial begin
        // Initialize Inputs
        reset = 1;
        #100; // Wait 100ns for global reset to finish
        reset = 0;

        // Wait for a few cycles to observe the signals
       // Wait 1ms
      

        // Finish simulation
        
    end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
     #50000000  $finish;
  end

endmodule
