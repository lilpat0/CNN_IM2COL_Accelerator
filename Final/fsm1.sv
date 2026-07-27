module fsm (
    input  logic clk, 
    input  logic rst_n,        // active-low, async reset
    input  logic start, 
    input  logic mmm_done,     // renamed from matrix_m
    input  logic process_done, 

    output logic busy, 
    output logic done, 
    output logic run_mm,
    output logic run_process
); 

    // Custom State Type Definition
    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        MMM,
        POST, 
        DONE
    } state_t; 

    state_t state, next_state; 

    // State Register Block (Sequential Logic)
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state; 
        end
    end 

    
    always_comb begin 
        // 1. Default Assignments (Prevents unwanted hardware latches)
        next_state  = state;
        busy        = 1'b0;
        done        = 1'b0;
        run_mm      = 1'b0;
        run_process = 1'b0;

        // 2. State Machine Transition Logic
        case (state) 

            IDLE: begin
                if (start) begin 
                    next_state = LOAD;
                    busy       = 1'b1;
                end
            end 

            LOAD: begin
                // Automatically transition to MMM (or add an input check here)
                next_state = MMM;
                busy       = 1'b1;
                // run_mm NOT asserted here — MMM state owns that signal
            end 

            MMM: begin
                if (mmm_done) begin
                    next_state  = POST; 
                    busy        = 1'b1; 
                    run_process = 1'b1; 
                end else begin
                    busy   = 1'b1;
                    run_mm = 1'b1; // Keep running matrix multiplication until done
                end
            end

            POST: begin
                if (process_done) begin 
                    next_state = DONE; 
                    done       = 1'b1;
                end else begin
                    busy        = 1'b1;
                    run_process = 1'b1;
                end
            end

            DONE: begin
                done = 1'b1;
                if (start) begin
                    next_state = LOAD; 
                    busy       = 1'b1;
                    done       = 1'b0;
                end
            end

            default: begin
                next_state = IDLE;
            end

        endcase 
    end 



endmodule