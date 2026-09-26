`timescale 1ns/1ps

module axi_uart_tb;

    // ============================================================
    // ============================================================
    //                    1. CLOCK GENERATION
    // ============================================================
    // ============================================================
    //
    // Both clocks run at 100 MHz.
    //
    // Period = 10 ns
    //
    // axi_aclk  -> AXI interface clock
    // fixed_clk -> UART/internal logic clock
    //
    // ============================================================

    logic axi_aclk;
    logic fixed_clk;
    logic axi_aresetn;

    initial begin
        axi_aclk  = 1'b0;
        fixed_clk = 1'b0;
    end

    always #5 axi_aclk  = ~axi_aclk;
    always #5 fixed_clk = ~fixed_clk;


    // ============================================================
    // ============================================================
    //                 2. UART SIMULATION SETTINGS
    // ============================================================
    // ============================================================
    //
    // IMPORTANT:
    // These values are ONLY for the testbench.
    //
    // We are NOT changing the RTL.
    //
    // The existing DUT uses baud_div_i internally.
    //
    // We will program:
    //
    //             BAUD DIVISOR = 32
    //
    // into the DUT.
    //
    // ------------------------------------------------------------
    //
    // Existing DUT TX logic:
    //
    //     if(counter_int >= baud_div_i)
    //
    // Therefore:
    //
    //     TX bit period = baud_div_i + 1
    //                   = 33 fixed_clk cycles
    //
    // ------------------------------------------------------------
    //
    // Existing DUT RX logic:
    //
    //     if(counter_int >= baud_div_i - 1)
    //
    // Therefore the RX testbench will hold each UART bit for:
    //
    //     32 fixed_clk cycles
    //
    // ============================================================

    localparam integer SIM_BAUD_DIV = 32;

    localparam integer UART_TX_BIT_CYCLES =
                       SIM_BAUD_DIV + 1;

    localparam integer UART_RX_BIT_CYCLES =
                       SIM_BAUD_DIV;


    // ============================================================
    // ============================================================
    //                     3. AXI PARAMETERS
    // ============================================================
    // ============================================================

    localparam integer AXI_DATA_WIDTH = 32;
    localparam integer AXI_ADDR_WIDTH = 5;
    localparam integer AXI_ID_WIDTH   = 12;


    // ============================================================
    // ============================================================
    //                  4. UART REGISTER ADDRESSES
    // ============================================================
    // ============================================================
    //
    // Based on the existing UART register map.
    //
    // Address 0x00 -> RBR / THR
    // Address 0x04 -> IER
    // Address 0x08 -> BAUD divisor
    // Address 0x0C -> LCR
    // Address 0x14 -> LSR
    //
    // ============================================================

    localparam logic [AXI_ADDR_WIDTH-1:0] ADDR_RBR  = 5'h00;
    localparam logic [AXI_ADDR_WIDTH-1:0] ADDR_THR  = 5'h00;
    localparam logic [AXI_ADDR_WIDTH-1:0] ADDR_IER  = 5'h04;
    localparam logic [AXI_ADDR_WIDTH-1:0] ADDR_BAUD = 5'h08;
    localparam logic [AXI_ADDR_WIDTH-1:0] ADDR_LCR  = 5'h0C;
    localparam logic [AXI_ADDR_WIDTH-1:0] ADDR_LSR  = 5'h14;


    // ============================================================
    // ============================================================
    //                     5. AXI SIGNALS
    // ============================================================
    // ============================================================

    // -------------------------
    // AXI WRITE ADDRESS
    // -------------------------

    logic [AXI_ID_WIDTH-1:0]   axi_awid;
    logic [AXI_ADDR_WIDTH-1:0] axi_awaddr;
    logic                       axi_awvalid;
    wire                        axi_awready;


    // -------------------------
    // AXI WRITE DATA
    // -------------------------

    logic [AXI_DATA_WIDTH-1:0] axi_wdata;
    logic [3:0]                 axi_wstrb;
    logic                       axi_wvalid;
    wire                        axi_wready;


    // -------------------------
    // AXI WRITE RESPONSE
    // -------------------------

    wire [AXI_ID_WIDTH-1:0]     axi_bid;
    wire [1:0]                  axi_bresp;
    wire                        axi_bvalid;
    logic                       axi_bready;


    // -------------------------
    // AXI READ ADDRESS
    // -------------------------

    logic [AXI_ID_WIDTH-1:0]   axi_arid;
    logic [AXI_ADDR_WIDTH-1:0] axi_araddr;
    logic                       axi_arvalid;
    wire                        axi_arready;


    // -------------------------
    // AXI READ DATA
    // -------------------------

    wire [AXI_ID_WIDTH-1:0]     axi_rid;
    wire [AXI_DATA_WIDTH-1:0]  axi_rdata;
    wire [1:0]                  axi_rresp;
    wire                        axi_rvalid;
    logic                       axi_rready;


    // ============================================================
    // ============================================================
    //                     6. UART SIGNALS
    // ============================================================
    // ============================================================

    // UART RX:
    //
    // Testbench -> DUT
    //
    // We will drive this signal when testing UART RX.

    logic uart_rx;


    // UART TX:
    //
    // DUT -> Testbench
    //
    // We will monitor this signal when testing UART TX.

    wire uart_tx;


    // UART interrupt

    wire read_interrupt;


    // ============================================================
    // ============================================================
    //                    7. TEST VARIABLES
    // ============================================================
    // ============================================================

    logic [31:0] lsr_value;
    logic [31:0] rx_value;

    logic tx_monitor_done;


    // ============================================================
    // ============================================================
    //                         8. DUT
    // ============================================================
    // ============================================================

    axi_uart_top dut (

        // --------------------------------------------------------
        // CLOCK / RESET
        // --------------------------------------------------------

        .fixed_clk_i       (fixed_clk),
        .axi_aclk_i        (axi_aclk),
        .axi_aresetn_i     (axi_aresetn),


        // --------------------------------------------------------
        // AXI READ ADDRESS
        // --------------------------------------------------------

        .axi_arid_i        (axi_arid),
        .axi_araddr_i      (axi_araddr),
        .axi_arvalid_i     (axi_arvalid),
        .axi_arready_o     (axi_arready),


        // --------------------------------------------------------
        // AXI READ DATA
        // --------------------------------------------------------

        .axi_rid_o         (axi_rid),
        .axi_rdata_o       (axi_rdata),
        .axi_rresp_o       (axi_rresp),
        .axi_rvalid_o      (axi_rvalid),
        .axi_rready_i      (axi_rready),


        // --------------------------------------------------------
        // AXI WRITE ADDRESS
        // --------------------------------------------------------

        .axi_awid_i        (axi_awid),
        .axi_awaddr_i      (axi_awaddr),
        .axi_awvalid_i     (axi_awvalid),
        .axi_awready_o     (axi_awready),


        // --------------------------------------------------------
        // AXI WRITE DATA
        // --------------------------------------------------------

        .axi_wdata_i       (axi_wdata),
        .axi_wstrb_i       (axi_wstrb),
        .axi_wvalid_i      (axi_wvalid),
        .axi_wready_o      (axi_wready),


        // --------------------------------------------------------
        // AXI WRITE RESPONSE
        // --------------------------------------------------------

        .axi_bid_o         (axi_bid),
        .axi_bresp_o       (axi_bresp),
        .axi_bvalid_o      (axi_bvalid),
        .axi_bready_i      (axi_bready),


        // --------------------------------------------------------
        // INTERRUPT
        // --------------------------------------------------------

        .read_interrupt_o  (read_interrupt),


        // --------------------------------------------------------
        // UART
        // --------------------------------------------------------

        .uart_rx_i         (uart_rx),
        .uart_tx_o         (uart_tx)
    );


    // ============================================================
    // ============================================================
    //                       9. FSDB
    // ============================================================
    // ============================================================

    initial begin

        $fsdbDumpfile("uart.fsdb");
        $fsdbDumpvars(0, axi_uart_tb);

    end


    // ============================================================
    // ============================================================
    //                     10. MAIN TEST
    // ============================================================
    // ============================================================

    initial begin


        // ========================================================
        // INITIALIZE EVERYTHING
        // ========================================================

        axi_aresetn = 1'b0;

        axi_awid    = '0;
        axi_awaddr  = '0;
        axi_awvalid = 1'b0;

        axi_wdata   = '0;
        axi_wstrb   = 4'b0000;
        axi_wvalid  = 1'b0;

        axi_bready  = 1'b0;

        axi_arid    = '0;
        axi_araddr  = '0;
        axi_arvalid = 1'b0;

        axi_rready  = 1'b0;

        // UART is HIGH when idle.

        uart_rx = 1'b1;

        tx_monitor_done = 1'b0;


        // ========================================================
        // RESET
        // ========================================================

        $display("");
        $display("======================================================");
        $display("                  RESETTING DUT");
        $display("======================================================");

        repeat (5)
            @(posedge axi_aclk);

        axi_aresetn = 1'b1;

        repeat (5)
            @(posedge axi_aclk);

        $display("RESET RELEASED");
        $display("");


        // ========================================================
        // TEST INFORMATION
        // ========================================================

        $display("======================================================");
        $display("             AXI-LITE UART IP TEST");
        $display("======================================================");

        $display("");
        $display("CLOCK FREQUENCY       : 100 MHz");
        $display("SIM_BAUD_DIV          : %0d", SIM_BAUD_DIV);
        $display("TX BIT PERIOD         : %0d clocks", UART_TX_BIT_CYCLES);
        $display("RX BIT PERIOD         : %0d clocks", UART_RX_BIT_CYCLES);
        $display("");

        $display("UART CONFIGURATION    : 8 DATA BITS");
        $display("                        NO PARITY");
        $display("                        1 STOP BIT");
        $display("");

        $display("======================================================");
        $display("");


        // ========================================================
        // STEP 1
        // ENABLE DLAB
        // ========================================================
        //
        // We need DLAB = 1 before writing the baud divisor.
        //
        // LCR = 0x83
        //
        // Binary:
        //
        // 1000_0011
        // │       ││
        // │       └┴── 8 data bits
        // │
        // └─────────── DLAB = 1
        //
        // ========================================================

        $display("------------------------------------------------------");
        $display("STEP 1: ENABLE DLAB");
        $display("------------------------------------------------------");

        $display("Writing LCR = 0x83");
        $display("Purpose:");
        $display("  LCR[7] = 1 -> DLAB ENABLED");
        $display("  LCR[1:0] = 11 -> 8 DATA BITS");
        $display("");

        axi_write(
            ADDR_LCR,
            32'h00000083
        );

        $display("STEP 1 COMPLETE");
        $display("");


        // ========================================================
        // STEP 2
        // PROGRAM BAUD DIVISOR
        // ========================================================
        //
        // Because DLAB = 1, address 0x08 accesses the baud
        // divisor register.
        //
        // We write:
        //
        //          BAUD = 32
        //
        // ========================================================

        $display("------------------------------------------------------");
        $display("STEP 2: PROGRAM BAUD DIVISOR");
        $display("------------------------------------------------------");

        $display("DLAB is currently ENABLED");
        $display("Writing BAUD DIVISOR = %0d", SIM_BAUD_DIV);
        $display("Writing value = 0x%08h", SIM_BAUD_DIV);
        $display("");

        axi_write(
            ADDR_BAUD,
            SIM_BAUD_DIV
        );

        $display("STEP 2 COMPLETE");
        $display("");


        // ========================================================
        // STEP 3
        // DISABLE DLAB
        // ========================================================
        //
        // Now that the baud divisor is programmed, we no longer
        // need DLAB.
        //
        // LCR = 0x03
        //
        // DLAB = 0
        // 8 data bits
        // No parity
        // 1 stop bit
        //
        // ========================================================

        $display("------------------------------------------------------");
        $display("STEP 3: DISABLE DLAB");
        $display("------------------------------------------------------");

        $display("Writing LCR = 0x03");
        $display("Purpose:");
        $display("  LCR[7] = 0 -> DLAB DISABLED");
        $display("  LCR[1:0] = 11 -> 8 DATA BITS");
        $display("  No parity");
        $display("  1 stop bit");
        $display("");

        axi_write(
            ADDR_LCR,
            32'h00000003
        );

        $display("STEP 3 COMPLETE");
        $display("");


        // ========================================================
        // STEP 4
        // READ INITIAL LSR
        // ========================================================
        //
        // LSR[0] = Data Ready
        //
        // Before receiving anything:
        //
        //              LSR[0] should be 0
        //
        // ========================================================

        $display("------------------------------------------------------");
        $display("STEP 4: READ INITIAL LSR");
        $display("------------------------------------------------------");

        axi_read(
            ADDR_LSR,
            lsr_value
        );

        $display("");
        $display("LSR VALUE = 0x%08h", lsr_value);
        $display("");

        if (lsr_value[0] == 1'b0) begin

            $display("[PASS] LSR[0] = 0");
            $display("       No UART data is available yet.");

        end
        else begin

            $display("[FAIL] LSR[0] = 1");
            $display("       UART incorrectly reports data ready.");

        end

        $display("");


        // ========================================================
        // STEP 5
        // UART TRANSMITTER TEST
        // ========================================================
        //
        // AXI writes 0x41 into THR.
        //
        // 0x41 = ASCII 'A'
        //
        // The DUT should then transmit:
        //
        // START = 0
        //
        // DATA = 01000001
        //
        // But UART sends LSB first:
        //
        // DATA[0] = 1
        // DATA[1] = 0
        // DATA[2] = 0
        // DATA[3] = 0
        // DATA[4] = 0
        // DATA[5] = 0
        // DATA[6] = 1
        // DATA[7] = 0
        //
        // STOP = 1
        //
        // ========================================================

        $display("======================================================");
        $display("                  UART TX TEST");
        $display("======================================================");

        $display("");
        $display("TEST ACTION:");
        $display("  AXI WRITE -> THR");
        $display("  DATA      -> 0x41 ('A')");
        $display("");
        $display("EXPECTED UART FRAME:");
        $display("  START : 0");
        $display("  DATA0 : 1");
        $display("  DATA1 : 0");
        $display("  DATA2 : 0");
        $display("  DATA3 : 0");
        $display("  DATA4 : 0");
        $display("  DATA5 : 0");
        $display("  DATA6 : 1");
        $display("  DATA7 : 0");
        $display("  STOP  : 1");
        $display("");

        tx_monitor_done = 1'b0;

        // Start TX monitor before writing THR.
        // This guarantees that the monitor is already waiting
        // when uart_tx changes.

        fork
            monitor_uart_tx();
        join_none


        // Write ASCII 'A' to THR.

        axi_write(
            ADDR_THR,
            32'h00000041
        );


        // Wait until the TX monitor has completely checked
        // the UART frame.

        wait (tx_monitor_done == 1'b1);

        $display("");
        $display("UART TX TEST FINISHED");
        $display("");


        // ========================================================
        // STEP 6
        // UART RECEIVER TEST
        // ========================================================
        //
        // Now the direction is reversed.
        //
        // Testbench -> uart_rx -> DUT
        //
        // We will send:
        //
        //              0x55
        //
        // Binary:
        //
        //              01010101
        //
        // LSB-first transmission:
        //
        //              1 0 1 0 1 0 1 0
        //
        // ========================================================

        $display("======================================================");
        $display("                  UART RX TEST");
        $display("======================================================");

        $display("");
        $display("TEST ACTION:");
        $display("  External UART sends 0x55 to DUT");
        $display("");
        $display("EXPECTED UART FRAME:");
        $display("  START : 0");
        $display("  DATA0 : 1");
        $display("  DATA1 : 0");
        $display("  DATA2 : 1");
        $display("  DATA3 : 0");
        $display("  DATA4 : 1");
        $display("  DATA5 : 0");
        $display("  DATA6 : 1");
        $display("  DATA7 : 0");
        $display("  STOP  : 1");
        $display("");


        // Send 0x55 through uart_rx.

        uart_send_byte(8'h55);


        // Wait for the DUT receiver and FIFO/controller
        // to finish processing the byte.

        $display("");
        $display("Waiting for DUT RX logic to finish...");

        repeat (20)
            @(posedge fixed_clk);

        $display("RX processing wait complete.");
        $display("");


        // ========================================================
        // STEP 7
        // CHECK LSR AFTER RX
        // ========================================================
        //
        // LSR[0] should now be:
        //
        //              1
        //
        // because one byte should be available in the RX FIFO.
        //
        // ========================================================

        $display("------------------------------------------------------");
        $display("STEP 7: CHECK LSR AFTER RX");
        $display("------------------------------------------------------");

        axi_read(
            ADDR_LSR,
            lsr_value
        );

        $display("");
        $display("LSR AFTER RX = 0x%08h", lsr_value);
        $display("");

        if (lsr_value[0] == 1'b1) begin

            $display("[PASS] LSR[0] = 1");
            $display("       DUT reports RX DATA READY.");

        end
        else begin

            $display("[FAIL] LSR[0] = 0");
            $display("       DUT reports NO RX DATA.");

        end

        $display("");


        // ========================================================
        // STEP 8
        // READ RECEIVED BYTE
        // ========================================================
        //
        // Read RBR through AXI.
        //
        // Expected:
        //
        //              0x55
        //
        // ========================================================

        $display("------------------------------------------------------");
        $display("STEP 8: READ RECEIVED UART BYTE");
        $display("------------------------------------------------------");

        axi_read(
            ADDR_RBR,
            rx_value
        );

        $display("");
        $display("EXPECTED RX DATA = 0x55");
        $display("ACTUAL RX DATA   = 0x%02h", rx_value[7:0]);
        $display("");

        if (rx_value[7:0] == 8'h55) begin

            $display("======================================================");
            $display("                UART RX TEST PASS");
            $display("======================================================");

        end
        else begin

            $display("======================================================");
            $display("                UART RX TEST FAIL");
            $display("======================================================");

        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("======================================================");
        $display("                 TEST COMPLETE");
        $display("======================================================");
        $display("");

        #100;

        $finish;

    end


    // ============================================================
    // ============================================================
    //                    AXI WRITE TASK
    // ============================================================
    // ============================================================
    //
    // This task performs:
    //
    //      AXI WRITE ADDRESS
    //      AXI WRITE DATA
    //      AXI WRITE RESPONSE
    //
    // The existing DUT generates the write response very quickly,
    // so we monitor the response in the same transaction.
    //
    // ============================================================

    task automatic axi_write(
        input logic [AXI_ADDR_WIDTH-1:0] addr,
        input logic [AXI_DATA_WIDTH-1:0] data
    );

        begin

            $display("");
            $display("AXI WRITE START");
            $display("  Address = 0x%08h", addr);
            $display("  Data    = 0x%08h", data);


            // ----------------------------------------------------
            // Put AXI request on the bus.
            // ----------------------------------------------------

            @(negedge axi_aclk);

            axi_awid    = '0;
            axi_awaddr  = addr;
            axi_awvalid = 1'b1;

            axi_wdata   = data;
            axi_wstrb   = 4'b1111;
            axi_wvalid  = 1'b1;

            // We are ready to accept write response.

            axi_bready  = 1'b1;


            // ----------------------------------------------------
            // Wait for the DUT to accept the write.
            // ----------------------------------------------------

            forever begin

                @(posedge axi_aclk);

                #1;

                if (axi_awready && axi_wready) begin

                    $display(
                        "  AWREADY = 1"
                    );

                    $display(
                        "  WREADY  = 1"
                    );

                    $display(
                        "  WRITE ADDRESS/DATA ACCEPTED"
                    );


                    // The existing DUT produces BVALID as part
                    // of this same transaction.

                    if (axi_bvalid) begin

                        $display(
                            "  BVALID  = 1"
                        );

                        if (axi_bresp == 2'b00) begin

                            $display(
                                "  BRESP   = OKAY (00)"
                            );

                            $display(
                                "AXI WRITE SUCCESS"
                            );

                        end
                        else begin

                            $display(
                                "  BRESP   = %b",
                                axi_bresp
                            );

                            $display(
                                "AXI WRITE FAILED"
                            );

                        end

                        break;

                    end

                end

            end


            // ----------------------------------------------------
            // Remove AXI signals.
            // ----------------------------------------------------

            @(negedge axi_aclk);

            axi_awvalid = 1'b0;
            axi_wvalid  = 1'b0;
            axi_bready  = 1'b0;


            @(posedge axi_aclk);

        end

    endtask


    // ============================================================
    // ============================================================
    //                     AXI READ TASK
    // ============================================================
    // ============================================================
    //
    // Performs:
    //
    //      AXI READ ADDRESS
    //      AXI READ DATA
    //
    // ============================================================

    task automatic axi_read(
        input  logic [AXI_ADDR_WIDTH-1:0] addr,
        output logic [AXI_DATA_WIDTH-1:0] data
    );

        begin

            data = 32'h00000000;


            $display("");
            $display("AXI READ START");
            $display("  Address = 0x%08h", addr);


            // ----------------------------------------------------
            // Put read address on AXI bus.
            // ----------------------------------------------------

            @(negedge axi_aclk);

            axi_arid    = '0;
            axi_araddr  = addr;
            axi_arvalid = 1'b1;

            // Ready to accept read data.

            axi_rready  = 1'b1;


            // ----------------------------------------------------
            // Wait for read response.
            // ----------------------------------------------------

            forever begin

                @(posedge axi_aclk);

                #1;

                if (axi_arready) begin

                    $display(
                        "  ARREADY = 1"
                    );

                    $display(
                        "  READ ADDRESS ACCEPTED"
                    );


                    if (axi_rvalid) begin

                        data = axi_rdata;

                        $display(
                            "  RVALID = 1"
                        );

                        $display(
                            "  RDATA  = 0x%08h",
                            data
                        );


                        if (axi_rresp == 2'b00) begin

                            $display(
                                "  RRESP  = OKAY (00)"
                            );

                            $display(
                                "AXI READ SUCCESS"
                            );

                        end
                        else begin

                            $display(
                                "  RRESP  = %b",
                                axi_rresp
                            );

                            $display(
                                "AXI READ FAILED"
                            );

                        end

                        break;

                    end

                end

            end


            // ----------------------------------------------------
            // Remove AXI signals.
            // ----------------------------------------------------

            @(negedge axi_aclk);

            axi_arvalid = 1'b0;
            axi_rready  = 1'b0;


            @(posedge axi_aclk);

        end

    endtask


    // ============================================================
    // ============================================================
    //                    UART RX DRIVER
    // ============================================================
    // ============================================================
    //
    // This task behaves like an external UART transmitter.
    //
    // It sends:
    //
    //      START
    //      DATA[0]
    //      DATA[1]
    //      ...
    //      DATA[7]
    //      STOP
    //
    // Data is transmitted LSB first.
    //
    // ============================================================

    task automatic uart_send_byte(
        input logic [7:0] data
    );

        integer i;

        begin

            $display("");
            $display("UART RX DRIVER START");
            $display(
                "  Byte to send = 0x%02h",
                data
            );
            $display("");


            // ----------------------------------------------------
            // UART IDLE
            // ----------------------------------------------------
            //
            // UART line is normally HIGH.
            //
            // ----------------------------------------------------

            uart_rx = 1'b1;


            // ----------------------------------------------------
            // START BIT
            // ----------------------------------------------------
            //
            // A UART frame begins with LOW.
            //
            // ----------------------------------------------------

            @(negedge fixed_clk);

            uart_rx = 1'b0;

            $display(
                "  START BIT = 0 at %0t",
                $time
            );


            // Hold START for one complete UART bit period.

            repeat (UART_RX_BIT_CYCLES)
                @(posedge fixed_clk);


            // ----------------------------------------------------
            // DATA BITS
            // ----------------------------------------------------
            //
            // UART transmits LSB first.
            //
            // Example for 0x55:
            //
            // 0x55 = 01010101
            //
            // transmitted:
            //
            // DATA0 = 1
            // DATA1 = 0
            // DATA2 = 1
            // DATA3 = 0
            // DATA4 = 1
            // DATA5 = 0
            // DATA6 = 1
            // DATA7 = 0
            //
            // ----------------------------------------------------

            for (i = 0; i < 8; i = i + 1) begin

                @(negedge fixed_clk);

                uart_rx = data[i];

                $display(
                    "  DATA[%0d] = %0d at %0t",
                    i,
                    data[i],
                    $time
                );


                // Hold this data bit for one UART bit period.

                repeat (UART_RX_BIT_CYCLES)
                    @(posedge fixed_clk);

            end


            // ----------------------------------------------------
            // STOP BIT
            // ----------------------------------------------------
            //
            // UART stop bit is HIGH.
            //
            // ----------------------------------------------------

            @(negedge fixed_clk);

            uart_rx = 1'b1;

            $display(
                "  STOP BIT = 1 at %0t",
                $time
            );


            repeat (UART_RX_BIT_CYCLES)
                @(posedge fixed_clk);


            $display("");
            $display("UART RX DRIVER COMPLETE");
            $display("");

        end

    endtask


    // ============================================================
    // ============================================================
    //                     UART TX MONITOR
    // ============================================================
    // ============================================================
    //
    // This task watches uart_tx.
    //
    // The DUT is transmitting:
    //
    //       DUT -> uart_tx -> TB
    //
    // We decode the UART frame and reconstruct the byte.
    //
    // ============================================================

    task automatic monitor_uart_tx;

        logic [7:0] received_data;

        integer i;

        begin

            received_data = 8'h00;


            // ----------------------------------------------------
            // WAIT FOR START BIT
            // ----------------------------------------------------

            @(negedge uart_tx);

            $display("");
            $display("UART TX MONITOR START");

            $display(
                "  START BIT detected at %0t",
                $time
            );


            // ----------------------------------------------------
            // SAMPLE CENTER OF START BIT
            // ----------------------------------------------------

            repeat (UART_TX_BIT_CYCLES / 2)
                @(posedge fixed_clk);

            #1;


            if (uart_tx == 1'b0) begin

                $display(
                    "  START BIT = 0 -> CORRECT"
                );

            end
            else begin

                $display(
                    "  START BIT = 1 -> ERROR"
                );

            end


            // ----------------------------------------------------
            // SAMPLE DATA BITS
            // ----------------------------------------------------
            //
            // Wait one complete bit period between samples.
            //
            // ----------------------------------------------------

            for (i = 0; i < 8; i = i + 1) begin

                repeat (UART_TX_BIT_CYCLES)
                    @(posedge fixed_clk);

                #1;


                received_data[i] = uart_tx;


                $display(
                    "  DATA[%0d] = %0d at %0t",
                    i,
                    uart_tx,
                    $time
                );

            end


            // ----------------------------------------------------
            // SAMPLE STOP BIT
            // ----------------------------------------------------

            repeat (UART_TX_BIT_CYCLES)
                @(posedge fixed_clk);

            #1;


            if (uart_tx == 1'b1) begin

                $display(
                    "  STOP BIT = 1 -> CORRECT"
                );

            end
            else begin

                $display(
                    "  STOP BIT = 0 -> ERROR"
                );

            end


            // ----------------------------------------------------
            // DISPLAY RECEIVED BYTE
            // ----------------------------------------------------

            $display("");
            $display(
                "  EXPECTED BYTE = 0x41"
            );

            $display(
                "  RECEIVED BYTE = 0x%02h",
                received_data
            );


            if (received_data == 8'h41) begin

                $display("");
                $display(
                    "  UART TX RESULT = PASS"
                );

            end
            else begin

                $display("");
                $display(
                    "  UART TX RESULT = FAIL"
                );

            end


            // Tell main test that TX monitoring is finished.

            tx_monitor_done = 1'b1;

        end

    endtask


    // ============================================================
    // ============================================================
    //                    AXI DEBUG MONITOR
    // ============================================================
    // ============================================================

    always @(posedge axi_aclk) begin

        if (axi_aresetn) begin

            if (axi_awvalid && axi_awready) begin

                $display(
                    "[AXI DEBUG] AW HANDSHAKE: addr=0x%08h time=%0t",
                    axi_awaddr,
                    $time
                );

            end


            if (axi_wvalid && axi_wready) begin

                $display(
                    "[AXI DEBUG] W HANDSHAKE: data=0x%08h time=%0t",
                    axi_wdata,
                    $time
                );

            end


            if (axi_bvalid && axi_bready) begin

                $display(
                    "[AXI DEBUG] B HANDSHAKE: resp=%b time=%0t",
                    axi_bresp,
                    $time
                );

            end


            if (axi_arvalid && axi_arready) begin

                $display(
                    "[AXI DEBUG] AR HANDSHAKE: addr=0x%08h time=%0t",
                    axi_araddr,
                    $time
                );

            end


            if (axi_rvalid && axi_rready) begin

                $display(
                    "[AXI DEBUG] R HANDSHAKE: data=0x%08h time=%0t",
                    axi_rdata,
                    $time
                );

            end

        end

    end


    // ============================================================
    // ============================================================
    //                     UART TX DEBUG
    // ============================================================
    // ============================================================

    always @(uart_tx) begin

        if (axi_aresetn) begin

            $display(
                "[UART DEBUG] uart_tx = %0d at %0t",
                uart_tx,
                $time
            );

        end

    end


    // ============================================================
    // ============================================================
    //                    INTERRUPT DEBUG
    // ============================================================
    // ============================================================

    always @(read_interrupt) begin

        if (axi_aresetn) begin

            $display(
                "[UART DEBUG] read_interrupt = %0d at %0t",
                read_interrupt,
                $time
            );

        end

    end 

initial begin
    $fsdbDumpfile("uart.fsdb");  // Record the waveform, waveform name testname.fsdb
    $fsdbDumpvars("+all");    // + all parameters, Struct structures in Dump SV
    $fsdbDumpSVA();      // Present the result of Assertion in FSDB
    $fsdbDumpMDA(); 
  end

endmodule
