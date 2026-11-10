module bist_top_tb;
 
    logic       clk, rst_n, bist_en;
    logic [3:0] a, b;
    logic       cin;
 
    logic       active_g;
    logic       pass_g, pass_s0, pass_s1;
 
    int pass_count, fail_count;
 
    always #5 clk = ~clk;
 
    bist_top #(
        .GOLDEN_SIG   (5'b10001),
        .INJECT_FAULT (1'b0),
        .FAULT_BIT    (0),
        .FAULT_VAL    (1'b0)
    ) u_golden (
        .clk(clk), .rst_n(rst_n), .bist_en(bist_en),
        .a(a), .b(b), .cin(cin),
        .sum(), .cout(),
        .bist_active(active_g), .pass_out(pass_g)
    );
 
    bist_top #(
        .GOLDEN_SIG   (5'b10001),
        .INJECT_FAULT (1'b1),
        .FAULT_BIT    (0),
        .FAULT_VAL    (1'b0)
    ) u_sa0 (
        .clk(clk), .rst_n(rst_n), .bist_en(bist_en),
        .a(a), .b(b), .cin(cin),
        .sum(), .cout(),
        .bist_active(), .pass_out(pass_s0)
    );
 
    bist_top #(
        .GOLDEN_SIG   (5'b10001),
        .INJECT_FAULT (1'b1),
        .FAULT_BIT    (1),
        .FAULT_VAL    (1'b1)
    ) u_sa1 (
        .clk(clk), .rst_n(rst_n), .bist_en(bist_en),
        .a(a), .b(b), .cin(cin),
        .sum(), .cout(),
        .bist_active(), .pass_out(pass_s1)
    );
 
    task automatic do_reset();
        rst_n   = 1'b0;
        bist_en = 1'b0;
        a = 4'b0; b = 4'b0; cin = 1'b0;
        repeat (4) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        @(posedge clk);
    endtask
 
    task automatic run_bist();
        @(negedge clk);
        bist_en = 1'b1;
        @(posedge clk);
        wait (active_g == 1'b1);
        @(negedge clk);
        bist_en = 1'b0;
        wait (active_g == 1'b0);
        repeat (4) @(posedge clk);
    endtask
 
    task automatic report(
        input string label,
        input logic  actual,
        input logic  expected
    );
        if (actual === expected) begin
            $display("  PASS  %s", label);
            pass_count++;
        end else begin
            $display("  FAIL  %s", label);
            fail_count++;
        end
    endtask
 
    initial begin
        clk = 1'b0; pass_count = 0; fail_count = 0;
 
        $display("========================================");
        $display("  BIST Testbench");
        $display("  Golden signature = 5'b10001");
        $display("========================================");
 
        do_reset();
        run_bist();
 
        $display("\n[1] Fault-free run");
        $display("    Signature = 5'b%05b", u_golden.misr_sig);
        report("Fault-free: signature matches golden",
               (u_golden.misr_sig == 5'b10001), 1'b1);
        report("Fault-free: pass_out asserted", pass_g, 1'b1);
 
        $display("\n[2] Stuck-at-0 on sum[0]");
        $display("    Signature = 5'b%05b", u_sa0.misr_sig);
        report("SA0: signature differs from golden",
               (u_sa0.misr_sig !== 5'b10001), 1'b1);
        report("SA0: pass_out deasserted", pass_s0, 1'b0);
 
        $display("\n[3] Stuck-at-1 on sum[1]");
        $display("    Signature = 5'b%05b", u_sa1.misr_sig);
        report("SA1: signature differs from golden",
               (u_sa1.misr_sig !== 5'b10001), 1'b1);
        report("SA1: pass_out deasserted", pass_s1, 1'b0);
 
        $display("\n========================================");
        $display("  Results: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0)
            $display("  ALL CHECKS PASSED");
        else
            $display("  FAILURES DETECTED");
        $display("========================================");
 
        $finish;
    end
 
endmodule
