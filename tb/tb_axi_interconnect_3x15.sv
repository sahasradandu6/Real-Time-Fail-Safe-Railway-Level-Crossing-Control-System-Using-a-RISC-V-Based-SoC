`timescale 1ns/1ps

module tb_axi_interconnect_3x15;

    // ============================================================
    // PARAMETERS
    // ============================================================

    parameter DATA_WIDTH = 64;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH   = 8;
    parameter STRB_WIDTH = DATA_WIDTH/8;

    parameter NUM_SLAVES = 15;
    parameter NUM_MASTERS = 3;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    logic clk;
    logic rst;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // MASTER S00 SIGNALS
    // ============================================================

    logic [ID_WIDTH-1:0]   s00_awid;
    logic [ADDR_WIDTH-1:0] s00_awaddr;
    logic [7:0]            s00_awlen;
    logic [2:0]            s00_awsize;
    logic [1:0]            s00_awburst;
    logic                  s00_awvalid;
    logic                  s00_awready;

    logic [DATA_WIDTH-1:0] s00_wdata;
    logic [STRB_WIDTH-1:0] s00_wstrb;
    logic                  s00_wlast;
    logic                  s00_wvalid;
    logic                  s00_wready;

    logic [ID_WIDTH-1:0]   s00_bid;
    logic [1:0]            s00_bresp;
    logic                  s00_bvalid;
    logic                  s00_bready;

    logic [ID_WIDTH-1:0]   s00_arid;
    logic [ADDR_WIDTH-1:0] s00_araddr;
    logic [7:0]            s00_arlen;
    logic [2:0]            s00_arsize;
    logic [1:0]            s00_arburst;
    logic                  s00_arvalid;
    logic                  s00_arready;

    logic [ID_WIDTH-1:0]   s00_rid;
    logic [DATA_WIDTH-1:0] s00_rdata;
    logic [1:0]            s00_rresp;
    logic                  s00_rlast;
    logic                  s00_rvalid;
    logic                  s00_rready;


    // ============================================================
    // MASTER S01 SIGNALS
    // ============================================================

    logic [ID_WIDTH-1:0]   s01_awid;
    logic [ADDR_WIDTH-1:0] s01_awaddr;
    logic [7:0]            s01_awlen;
    logic [2:0]            s01_awsize;
    logic [1:0]            s01_awburst;
    logic                  s01_awvalid;
    logic                  s01_awready;

    logic [DATA_WIDTH-1:0] s01_wdata;
    logic [STRB_WIDTH-1:0] s01_wstrb;
    logic                  s01_wlast;
    logic                  s01_wvalid;
    logic                  s01_wready;

    logic [ID_WIDTH-1:0]   s01_bid;
    logic [1:0]            s01_bresp;
    logic                  s01_bvalid;
    logic                  s01_bready;

    logic [ID_WIDTH-1:0]   s01_arid;
    logic [ADDR_WIDTH-1:0] s01_araddr;
    logic [7:0]            s01_arlen;
    logic [2:0]            s01_arsize;
    logic [1:0]            s01_arburst;
    logic                  s01_arvalid;
    logic                  s01_arready;

    logic [ID_WIDTH-1:0]   s01_rid;
    logic [DATA_WIDTH-1:0] s01_rdata;
    logic [1:0]            s01_rresp;
    logic                  s01_rlast;
    logic                  s01_rvalid;
    logic                  s01_rready;


    // ============================================================
    // MASTER S02 SIGNALS
    // ============================================================

    logic [ID_WIDTH-1:0]   s02_awid;
    logic [ADDR_WIDTH-1:0] s02_awaddr;
    logic [7:0]            s02_awlen;
    logic [2:0]            s02_awsize;
    logic [1:0]            s02_awburst;
    logic                  s02_awvalid;
    logic                  s02_awready;

    logic [DATA_WIDTH-1:0] s02_wdata;
    logic [STRB_WIDTH-1:0] s02_wstrb;
    logic                  s02_wlast;
    logic                  s02_wvalid;
    logic                  s02_wready;

    logic [ID_WIDTH-1:0]   s02_bid;
    logic [1:0]            s02_bresp;
    logic                  s02_bvalid;
    logic                  s02_bready;

    logic [ID_WIDTH-1:0]   s02_arid;
    logic [ADDR_WIDTH-1:0] s02_araddr;
    logic [7:0]            s02_arlen;
    logic [2:0]            s02_arsize;
    logic [1:0]            s02_arburst;
    logic                  s02_arvalid;
    logic                  s02_arready;

    logic [ID_WIDTH-1:0]   s02_rid;
    logic [DATA_WIDTH-1:0] s02_rdata;
    logic [1:0]            s02_rresp;
    logic                  s02_rlast;
    logic                  s02_rvalid;
    logic                  s02_rready;


    // ============================================================
    // SLAVE SIGNAL ARRAYS
    //
    // Each array element corresponds to one slave:
    //
    // [0]  = M00
    // [1]  = M01
    // ...
    // [14] = M14
    // ============================================================

    logic [ID_WIDTH-1:0]   m_awid    [0:14];
    logic [ADDR_WIDTH-1:0] m_awaddr  [0:14];
    logic [7:0]            m_awlen   [0:14];
    logic [2:0]            m_awsize  [0:14];
    logic [1:0]            m_awburst [0:14];
    logic                  m_awvalid [0:14];
    logic                  m_awready [0:14];

    logic [DATA_WIDTH-1:0] m_wdata   [0:14];
    logic [STRB_WIDTH-1:0] m_wstrb   [0:14];
    logic                  m_wlast   [0:14];
    logic                  m_wvalid  [0:14];
    logic                  m_wready  [0:14];

    logic [ID_WIDTH-1:0]   m_bid     [0:14];
    logic [1:0]            m_bresp   [0:14];
    logic                  m_bvalid  [0:14];
    logic                  m_bready  [0:14];

    logic [ID_WIDTH-1:0]   m_arid    [0:14];
    logic [ADDR_WIDTH-1:0] m_araddr  [0:14];
    logic [7:0]            m_arlen   [0:14];
    logic [2:0]            m_arsize  [0:14];
    logic [1:0]            m_arburst [0:14];
    logic                  m_arvalid [0:14];
    logic                  m_arready [0:14];

    logic [ID_WIDTH-1:0]   m_rid     [0:14];
    logic [DATA_WIDTH-1:0] m_rdata   [0:14];
    logic [1:0]            m_rresp   [0:14];
    logic                  m_rlast   [0:14];
    logic                  m_rvalid  [0:14];
    logic                  m_rready  [0:14];


    // ============================================================
    // DUMMY SLAVE INTERNAL STATE
    // ============================================================

    logic                  m_aw_seen [0:14];
    logic                  m_w_seen  [0:14];

    logic [ID_WIDTH-1:0]   saved_awid [0:14];


    // ============================================================
    // CONNECT DUMMY SLAVES
    //
    // Every M00-M14 has its own dummy AXI slave.
    // ============================================================

    genvar g;

    generate

        for (g = 0; g < NUM_SLAVES; g = g + 1) begin : GEN_DUMMY_SLAVES

            always_comb begin

                // Accept AW only when we do not already have one
                // pending and there is no outstanding B response.
                m_awready[g] = !m_aw_seen[g] &&
                                !m_bvalid[g];

                // Accept W independently of AW.
                m_wready[g]  = !m_w_seen[g] &&
                                !m_bvalid[g];

                // Accept a read address when no read response
                // is currently waiting.
                m_arready[g] = !m_rvalid[g];

            end


            always_ff @(posedge clk) begin

                if (rst) begin

                    m_aw_seen[g]  <= 1'b0;
                    m_w_seen[g]   <= 1'b0;

                    saved_awid[g] <= '0;

                    m_bvalid[g]   <= 1'b0;
                    m_bid[g]      <= '0;
                    m_bresp[g]    <= 2'b00;

                    m_rvalid[g]   <= 1'b0;
                    m_rid[g]      <= '0;
                    m_rdata[g]   <= '0;
                    m_rresp[g]   <= 2'b00;
                    m_rlast[g]   <= 1'b0;

                end

                else begin

                    // ------------------------------------------------
                    // WRITE ADDRESS
                    // ------------------------------------------------

                    if (m_awvalid[g] && m_awready[g]) begin

                        m_aw_seen[g]  <= 1'b1;
                        saved_awid[g] <= m_awid[g];

                        $display(
                            "[SLAVE M%0d] AW accepted : ID=%h ADDR=%h",
                            g,
                            m_awid[g],
                            m_awaddr[g]
                        );

                    end


                    // ------------------------------------------------
                    // WRITE DATA
                    // ------------------------------------------------

                    if (m_wvalid[g] && m_wready[g]) begin

                        m_w_seen[g] <= 1'b1;

                        $display(
                            "[SLAVE M%0d] W accepted  : DATA=%h",
                            g,
                            m_wdata[g]
                        );

                    end


                    // ------------------------------------------------
                    // GENERATE WRITE RESPONSE
                    //
                    // AXI allows AW and W to arrive independently.
                    // Once both have arrived, generate BVALID.
                    // ------------------------------------------------

                    if (m_aw_seen[g] &&
                        m_w_seen[g] &&
                        !m_bvalid[g]) begin

                        m_bid[g]   <= saved_awid[g];
                        m_bresp[g] <= 2'b00;       // OKAY
                        m_bvalid[g] <= 1'b1;

                        m_aw_seen[g] <= 1'b0;
                        m_w_seen[g]  <= 1'b0;

                        $display(
                            "[SLAVE M%0d] B generated : BID=%h",
                            g,
                            saved_awid[g]
                        );

                    end


                    // ------------------------------------------------
                    // COMPLETE WRITE RESPONSE
                    // ------------------------------------------------

                    if (m_bvalid[g] && m_bready[g]) begin

                        m_bvalid[g] <= 1'b0;

                        $display(
                            "[SLAVE M%0d] B handshake complete",
                            g
                        );

                    end


                    // ------------------------------------------------
                    // READ ADDRESS
                    // ------------------------------------------------

                    if (m_arvalid[g] && m_arready[g]) begin

                        m_rid[g]    <= m_arid[g];

                        // Return the slave number as read data.
                        //
                        // M00 -> 0
                        // M01 -> 1
                        // ...
                        // M14 -> 14
                        //
                        // This makes routing very easy to verify.
                        m_rdata[g]  <= g;

                        m_rresp[g]  <= 2'b00;
                        m_rlast[g]  <= 1'b1;
                        m_rvalid[g] <= 1'b1;

                        $display(
                            "[SLAVE M%0d] AR accepted : ID=%h ADDR=%h",
                            g,
                            m_arid[g],
                            m_araddr[g]
                        );

                    end


                    // ------------------------------------------------
                    // COMPLETE READ RESPONSE
                    // ------------------------------------------------

                    if (m_rvalid[g] && m_rready[g]) begin

                        m_rvalid[g] <= 1'b0;
                        m_rlast[g]  <= 1'b0;

                        $display(
                            "[SLAVE M%0d] R handshake complete",
                            g
                        );

                    end

                end

            end

        end

    endgenerate


    // ============================================================
    // DUT
    // ============================================================

    axi_interconnect_wrap_3x15 dut (

        .clk  (clk),
        .rst  (rst),

        // ========================================================
        // S00
        // ========================================================

        .s00_axi_awid     (s00_awid),
        .s00_axi_awaddr   (s00_awaddr),
        .s00_axi_awlen    (s00_awlen),
        .s00_axi_awsize   (s00_awsize),
        .s00_axi_awburst  (s00_awburst),
        .s00_axi_awvalid  (s00_awvalid),
        .s00_axi_awready  (s00_awready),

        .s00_axi_wdata    (s00_wdata),
        .s00_axi_wstrb    (s00_wstrb),
        .s00_axi_wlast    (s00_wlast),
        .s00_axi_wvalid   (s00_wvalid),
        .s00_axi_wready   (s00_wready),

        .s00_axi_bid     (s00_bid),
        .s00_axi_bresp   (s00_bresp),
        .s00_axi_bvalid  (s00_bvalid),
        .s00_axi_bready  (s00_bready),

        .s00_axi_arid    (s00_arid),
        .s00_axi_araddr  (s00_araddr),
        .s00_axi_arlen   (s00_arlen),
        .s00_axi_arsize  (s00_arsize),
        .s00_axi_arburst (s00_arburst),
        .s00_axi_arvalid (s00_arvalid),
        .s00_axi_arready (s00_arready),

        .s00_axi_rid    (s00_rid),
        .s00_axi_rdata  (s00_rdata),
        .s00_axi_rresp  (s00_rresp),
        .s00_axi_rlast  (s00_rlast),
        .s00_axi_rvalid (s00_rvalid),
        .s00_axi_rready (s00_rready),


        // ========================================================
        // S01
        // ========================================================

        .s01_axi_awid     (s01_awid),
        .s01_axi_awaddr   (s01_awaddr),
        .s01_axi_awlen    (s01_awlen),
        .s01_axi_awsize   (s01_awsize),
        .s01_axi_awburst  (s01_awburst),
        .s01_axi_awvalid  (s01_awvalid),
        .s01_axi_awready  (s01_awready),

        .s01_axi_wdata    (s01_wdata),
        .s01_axi_wstrb    (s01_wstrb),
        .s01_axi_wlast    (s01_wlast),
        .s01_axi_wvalid   (s01_wvalid),
        .s01_axi_wready   (s01_wready),

        .s01_axi_bid     (s01_bid),
        .s01_axi_bresp   (s01_bresp),
        .s01_axi_bvalid  (s01_bvalid),
        .s01_axi_bready  (s01_bready),

        .s01_axi_arid    (s01_arid),
        .s01_axi_araddr  (s01_araddr),
        .s01_axi_arlen   (s01_arlen),
        .s01_axi_arsize  (s01_arsize),
        .s01_axi_arburst (s01_arburst),
        .s01_axi_arvalid (s01_arvalid),
        .s01_axi_arready (s01_arready),

        .s01_axi_rid    (s01_rid),
        .s01_axi_rdata  (s01_rdata),
        .s01_axi_rresp  (s01_rresp),
        .s01_axi_rlast  (s01_rlast),
        .s01_axi_rvalid (s01_rvalid),
        .s01_axi_rready (s01_rready),


        // ========================================================
        // S02
        // ========================================================

        .s02_axi_awid     (s02_awid),
        .s02_axi_awaddr   (s02_awaddr),
        .s02_axi_awlen    (s02_awlen),
        .s02_axi_awsize   (s02_awsize),
        .s02_axi_awburst  (s02_awburst),
        .s02_axi_awvalid  (s02_awvalid),
        .s02_axi_awready  (s02_awready),

        .s02_axi_wdata    (s02_wdata),
        .s02_axi_wstrb    (s02_wstrb),
        .s02_axi_wlast    (s02_wlast),
        .s02_axi_wvalid   (s02_wvalid),
        .s02_axi_wready   (s02_wready),

        .s02_axi_bid     (s02_bid),
        .s02_axi_bresp   (s02_bresp),
        .s02_axi_bvalid  (s02_bvalid),
        .s02_axi_bready  (s02_bready),

        .s02_axi_arid    (s02_arid),
        .s02_axi_araddr  (s02_araddr),
        .s02_axi_arlen   (s02_arlen),
        .s02_axi_arsize  (s02_arsize),
        .s02_axi_arburst (s02_arburst),
        .s02_axi_arvalid (s02_arvalid),
        .s02_axi_arready (s02_arready),

        .s02_axi_rid    (s02_rid),
        .s02_axi_rdata  (s02_rdata),
        .s02_axi_rresp  (s02_rresp),
        .s02_axi_rlast  (s02_rlast),
        .s02_axi_rvalid (s02_rvalid),
        .s02_axi_rready (s02_rready),


        // ========================================================
        // M00
        // ========================================================

        .m00_axi_awid     (m_awid[0]),
        .m00_axi_awaddr   (m_awaddr[0]),
        .m00_axi_awlen    (m_awlen[0]),
        .m00_axi_awsize   (m_awsize[0]),
        .m00_axi_awburst  (m_awburst[0]),
        .m00_axi_awvalid  (m_awvalid[0]),
        .m00_axi_awready  (m_awready[0]),

        .m00_axi_wdata    (m_wdata[0]),
        .m00_axi_wstrb    (m_wstrb[0]),
        .m00_axi_wlast    (m_wlast[0]),
        .m00_axi_wvalid   (m_wvalid[0]),
        .m00_axi_wready   (m_wready[0]),

        .m00_axi_bid     (m_bid[0]),
        .m00_axi_bresp   (m_bresp[0]),
        .m00_axi_bvalid  (m_bvalid[0]),
        .m00_axi_bready  (m_bready[0]),

        .m00_axi_arid    (m_arid[0]),
        .m00_axi_araddr  (m_araddr[0]),
        .m00_axi_arlen   (m_arlen[0]),
        .m00_axi_arsize  (m_arsize[0]),
        .m00_axi_arburst (m_arburst[0]),
        .m00_axi_arvalid (m_arvalid[0]),
        .m00_axi_arready (m_arready[0]),

        .m00_axi_rid    (m_rid[0]),
        .m00_axi_rdata  (m_rdata[0]),
        .m00_axi_rresp  (m_rresp[0]),
        .m00_axi_rlast  (m_rlast[0]),
        .m00_axi_rvalid (m_rvalid[0]),
        .m00_axi_rready (m_rready[0]),


        // ========================================================
        // M01
        // ========================================================

        .m01_axi_awid     (m_awid[1]),
        .m01_axi_awaddr   (m_awaddr[1]),
        .m01_axi_awlen    (m_awlen[1]),
        .m01_axi_awsize   (m_awsize[1]),
        .m01_axi_awburst  (m_awburst[1]),
        .m01_axi_awvalid  (m_awvalid[1]),
        .m01_axi_awready  (m_awready[1]),

        .m01_axi_wdata    (m_wdata[1]),
        .m01_axi_wstrb    (m_wstrb[1]),
        .m01_axi_wlast    (m_wlast[1]),
        .m01_axi_wvalid   (m_wvalid[1]),
        .m01_axi_wready   (m_wready[1]),

        .m01_axi_bid     (m_bid[1]),
        .m01_axi_bresp   (m_bresp[1]),
        .m01_axi_bvalid  (m_bvalid[1]),
        .m01_axi_bready  (m_bready[1]),

        .m01_axi_arid    (m_arid[1]),
        .m01_axi_araddr  (m_araddr[1]),
        .m01_axi_arlen   (m_arlen[1]),
        .m01_axi_arsize  (m_arsize[1]),
        .m01_axi_arburst (m_arburst[1]),
        .m01_axi_arvalid (m_arvalid[1]),
        .m01_axi_arready (m_arready[1]),

        .m01_axi_rid    (m_rid[1]),
        .m01_axi_rdata  (m_rdata[1]),
        .m01_axi_rresp  (m_rresp[1]),
        .m01_axi_rlast  (m_rlast[1]),
        .m01_axi_rvalid (m_rvalid[1]),
        .m01_axi_rready (m_rready[1]),


        // ========================================================
        // M02
        // ========================================================

        .m02_axi_awid     (m_awid[2]),
        .m02_axi_awaddr   (m_awaddr[2]),
        .m02_axi_awlen    (m_awlen[2]),
        .m02_axi_awsize   (m_awsize[2]),
        .m02_axi_awburst  (m_awburst[2]),
        .m02_axi_awvalid  (m_awvalid[2]),
        .m02_axi_awready  (m_awready[2]),

        .m02_axi_wdata    (m_wdata[2]),
        .m02_axi_wstrb    (m_wstrb[2]),
        .m02_axi_wlast    (m_wlast[2]),
        .m02_axi_wvalid   (m_wvalid[2]),
        .m02_axi_wready   (m_wready[2]),

        .m02_axi_bid     (m_bid[2]),
        .m02_axi_bresp   (m_bresp[2]),
        .m02_axi_bvalid  (m_bvalid[2]),
        .m02_axi_bready  (m_bready[2]),

        .m02_axi_arid    (m_arid[2]),
        .m02_axi_araddr  (m_araddr[2]),
        .m02_axi_arlen   (m_arlen[2]),
        .m02_axi_arsize  (m_arsize[2]),
        .m02_axi_arburst (m_arburst[2]),
        .m02_axi_arvalid (m_arvalid[2]),
        .m02_axi_arready (m_arready[2]),

        .m02_axi_rid    (m_rid[2]),
        .m02_axi_rdata  (m_rdata[2]),
        .m02_axi_rresp  (m_rresp[2]),
        .m02_axi_rlast  (m_rlast[2]),
        .m02_axi_rvalid (m_rvalid[2]),
        .m02_axi_rready (m_rready[2]),


        // ========================================================
        // M03
        // ========================================================

        .m03_axi_awid     (m_awid[3]),
        .m03_axi_awaddr   (m_awaddr[3]),
        .m03_axi_awlen    (m_awlen[3]),
        .m03_axi_awsize   (m_awsize[3]),
        .m03_axi_awburst  (m_awburst[3]),
        .m03_axi_awvalid  (m_awvalid[3]),
        .m03_axi_awready  (m_awready[3]),

        .m03_axi_wdata    (m_wdata[3]),
        .m03_axi_wstrb    (m_wstrb[3]),
        .m03_axi_wlast    (m_wlast[3]),
        .m03_axi_wvalid   (m_wvalid[3]),
        .m03_axi_wready   (m_wready[3]),

        .m03_axi_bid     (m_bid[3]),
        .m03_axi_bresp   (m_bresp[3]),
        .m03_axi_bvalid  (m_bvalid[3]),
        .m03_axi_bready  (m_bready[3]),

        .m03_axi_arid    (m_arid[3]),
        .m03_axi_araddr  (m_araddr[3]),
        .m03_axi_arlen   (m_arlen[3]),
        .m03_axi_arsize  (m_arsize[3]),
        .m03_axi_arburst (m_arburst[3]),
        .m03_axi_arvalid (m_arvalid[3]),
        .m03_axi_arready (m_arready[3]),

        .m03_axi_rid    (m_rid[3]),
        .m03_axi_rdata  (m_rdata[3]),
        .m03_axi_rresp  (m_rresp[3]),
        .m03_axi_rlast  (m_rlast[3]),
        .m03_axi_rvalid (m_rvalid[3]),
        .m03_axi_rready (m_rready[3]),


        // ========================================================
        // M04
        // ========================================================

        .m04_axi_awid     (m_awid[4]),
        .m04_axi_awaddr   (m_awaddr[4]),
        .m04_axi_awlen    (m_awlen[4]),
        .m04_axi_awsize   (m_awsize[4]),
        .m04_axi_awburst  (m_awburst[4]),
        .m04_axi_awvalid  (m_awvalid[4]),
        .m04_axi_awready  (m_awready[4]),

        .m04_axi_wdata    (m_wdata[4]),
        .m04_axi_wstrb    (m_wstrb[4]),
        .m04_axi_wlast    (m_wlast[4]),
        .m04_axi_wvalid   (m_wvalid[4]),
        .m04_axi_wready   (m_wready[4]),

        .m04_axi_bid     (m_bid[4]),
        .m04_axi_bresp   (m_bresp[4]),
        .m04_axi_bvalid  (m_bvalid[4]),
        .m04_axi_bready  (m_bready[4]),

        .m04_axi_arid    (m_arid[4]),
        .m04_axi_araddr  (m_araddr[4]),
        .m04_axi_arlen   (m_arlen[4]),
        .m04_axi_arsize  (m_arsize[4]),
        .m04_axi_arburst (m_arburst[4]),
        .m04_axi_arvalid (m_arvalid[4]),
        .m04_axi_arready (m_arready[4]),

        .m04_axi_rid    (m_rid[4]),
        .m04_axi_rdata  (m_rdata[4]),
        .m04_axi_rresp  (m_rresp[4]),
        .m04_axi_rlast  (m_rlast[4]),
        .m04_axi_rvalid (m_rvalid[4]),
        .m04_axi_rready (m_rready[4]),


        // ========================================================
        // M05
        // ========================================================

        .m05_axi_awid     (m_awid[5]),
        .m05_axi_awaddr   (m_awaddr[5]),
        .m05_axi_awlen    (m_awlen[5]),
        .m05_axi_awsize   (m_awsize[5]),
        .m05_axi_awburst  (m_awburst[5]),
        .m05_axi_awvalid  (m_awvalid[5]),
        .m05_axi_awready  (m_awready[5]),

        .m05_axi_wdata    (m_wdata[5]),
        .m05_axi_wstrb    (m_wstrb[5]),
        .m05_axi_wlast    (m_wlast[5]),
        .m05_axi_wvalid   (m_wvalid[5]),
        .m05_axi_wready   (m_wready[5]),

        .m05_axi_bid     (m_bid[5]),
        .m05_axi_bresp   (m_bresp[5]),
        .m05_axi_bvalid  (m_bvalid[5]),
        .m05_axi_bready  (m_bready[5]),

        .m05_axi_arid    (m_arid[5]),
        .m05_axi_araddr  (m_araddr[5]),
        .m05_axi_arlen   (m_arlen[5]),
        .m05_axi_arsize  (m_arsize[5]),
        .m05_axi_arburst (m_arburst[5]),
        .m05_axi_arvalid (m_arvalid[5]),
        .m05_axi_arready (m_arready[5]),

        .m05_axi_rid    (m_rid[5]),
        .m05_axi_rdata  (m_rdata[5]),
        .m05_axi_rresp  (m_rresp[5]),
        .m05_axi_rlast  (m_rlast[5]),
        .m05_axi_rvalid (m_rvalid[5]),
        .m05_axi_rready (m_rready[5]),


        // ========================================================
        // M06
        // ========================================================

        .m06_axi_awid     (m_awid[6]),
        .m06_axi_awaddr   (m_awaddr[6]),
        .m06_axi_awlen    (m_awlen[6]),
        .m06_axi_awsize   (m_awsize[6]),
        .m06_axi_awburst  (m_awburst[6]),
        .m06_axi_awvalid  (m_awvalid[6]),
        .m06_axi_awready  (m_awready[6]),

        .m06_axi_wdata    (m_wdata[6]),
        .m06_axi_wstrb    (m_wstrb[6]),
        .m06_axi_wlast    (m_wlast[6]),
        .m06_axi_wvalid   (m_wvalid[6]),
        .m06_axi_wready   (m_wready[6]),

        .m06_axi_bid     (m_bid[6]),
        .m06_axi_bresp   (m_bresp[6]),
        .m06_axi_bvalid  (m_bvalid[6]),
        .m06_axi_bready  (m_bready[6]),

        .m06_axi_arid    (m_arid[6]),
        .m06_axi_araddr  (m_araddr[6]),
        .m06_axi_arlen   (m_arlen[6]),
        .m06_axi_arsize  (m_arsize[6]),
        .m06_axi_arburst (m_arburst[6]),
        .m06_axi_arvalid (m_arvalid[6]),
        .m06_axi_arready (m_arready[6]),

        .m06_axi_rid    (m_rid[6]),
        .m06_axi_rdata  (m_rdata[6]),
        .m06_axi_rresp  (m_rresp[6]),
        .m06_axi_rlast  (m_rlast[6]),
        .m06_axi_rvalid (m_rvalid[6]),
        .m06_axi_rready (m_rready[6]),


        // ========================================================
        // M07
        // ========================================================

        .m07_axi_awid     (m_awid[7]),
        .m07_axi_awaddr   (m_awaddr[7]),
        .m07_axi_awlen    (m_awlen[7]),
        .m07_axi_awsize   (m_awsize[7]),
        .m07_axi_awburst  (m_awburst[7]),
        .m07_axi_awvalid  (m_awvalid[7]),
        .m07_axi_awready  (m_awready[7]),

        .m07_axi_wdata    (m_wdata[7]),
        .m07_axi_wstrb    (m_wstrb[7]),
        .m07_axi_wlast    (m_wlast[7]),
        .m07_axi_wvalid   (m_wvalid[7]),
        .m07_axi_wready   (m_wready[7]),

        .m07_axi_bid     (m_bid[7]),
        .m07_axi_bresp   (m_bresp[7]),
        .m07_axi_bvalid  (m_bvalid[7]),
        .m07_axi_bready  (m_bready[7]),

        .m07_axi_arid    (m_arid[7]),
        .m07_axi_araddr  (m_araddr[7]),
        .m07_axi_arlen   (m_arlen[7]),
        .m07_axi_arsize  (m_arsize[7]),
        .m07_axi_arburst (m_arburst[7]),
        .m07_axi_arvalid (m_arvalid[7]),
        .m07_axi_arready (m_arready[7]),

        .m07_axi_rid    (m_rid[7]),
        .m07_axi_rdata  (m_rdata[7]),
        .m07_axi_rresp  (m_rresp[7]),
        .m07_axi_rlast  (m_rlast[7]),
        .m07_axi_rvalid (m_rvalid[7]),
        .m07_axi_rready (m_rready[7]),


        // ========================================================
        // M08
        // ========================================================

        .m08_axi_awid     (m_awid[8]),
        .m08_axi_awaddr   (m_awaddr[8]),
        .m08_axi_awlen    (m_awlen[8]),
        .m08_axi_awsize   (m_awsize[8]),
        .m08_axi_awburst  (m_awburst[8]),
        .m08_axi_awvalid  (m_awvalid[8]),
        .m08_axi_awready  (m_awready[8]),

        .m08_axi_wdata    (m_wdata[8]),
        .m08_axi_wstrb    (m_wstrb[8]),
        .m08_axi_wlast    (m_wlast[8]),
        .m08_axi_wvalid   (m_wvalid[8]),
        .m08_axi_wready   (m_wready[8]),

        .m08_axi_bid     (m_bid[8]),
        .m08_axi_bresp   (m_bresp[8]),
        .m08_axi_bvalid  (m_bvalid[8]),
        .m08_axi_bready  (m_bready[8]),

        .m08_axi_arid    (m_arid[8]),
        .m08_axi_araddr  (m_araddr[8]),
        .m08_axi_arlen   (m_arlen[8]),
        .m08_axi_arsize  (m_arsize[8]),
        .m08_axi_arburst (m_arburst[8]),
        .m08_axi_arvalid (m_arvalid[8]),
        .m08_axi_arready (m_arready[8]),

        .m08_axi_rid    (m_rid[8]),
        .m08_axi_rdata  (m_rdata[8]),
        .m08_axi_rresp  (m_rresp[8]),
        .m08_axi_rlast  (m_rlast[8]),
        .m08_axi_rvalid (m_rvalid[8]),
        .m08_axi_rready (m_rready[8]),


        // ========================================================
        // M09
        // ========================================================

        .m09_axi_awid     (m_awid[9]),
        .m09_axi_awaddr   (m_awaddr[9]),
        .m09_axi_awlen    (m_awlen[9]),
        .m09_axi_awsize   (m_awsize[9]),
        .m09_axi_awburst  (m_awburst[9]),
        .m09_axi_awvalid  (m_awvalid[9]),
        .m09_axi_awready  (m_awready[9]),

        .m09_axi_wdata    (m_wdata[9]),
        .m09_axi_wstrb    (m_wstrb[9]),
        .m09_axi_wlast    (m_wlast[9]),
        .m09_axi_wvalid   (m_wvalid[9]),
        .m09_axi_wready   (m_wready[9]),

        .m09_axi_bid     (m_bid[9]),
        .m09_axi_bresp   (m_bresp[9]),
        .m09_axi_bvalid  (m_bvalid[9]),
        .m09_axi_bready  (m_bready[9]),

        .m09_axi_arid    (m_arid[9]),
        .m09_axi_araddr  (m_araddr[9]),
        .m09_axi_arlen   (m_arlen[9]),
        .m09_axi_arsize  (m_arsize[9]),
        .m09_axi_arburst (m_arburst[9]),
        .m09_axi_arvalid (m_arvalid[9]),
        .m09_axi_arready (m_arready[9]),

        .m09_axi_rid    (m_rid[9]),
        .m09_axi_rdata  (m_rdata[9]),
        .m09_axi_rresp  (m_rresp[9]),
        .m09_axi_rlast  (m_rlast[9]),
        .m09_axi_rvalid (m_rvalid[9]),
        .m09_axi_rready (m_rready[9]),


        // ========================================================
        // M10
        // ========================================================

        .m10_axi_awid     (m_awid[10]),
        .m10_axi_awaddr   (m_awaddr[10]),
        .m10_axi_awlen    (m_awlen[10]),
        .m10_axi_awsize   (m_awsize[10]),
        .m10_axi_awburst  (m_awburst[10]),
        .m10_axi_awvalid  (m_awvalid[10]),
        .m10_axi_awready  (m_awready[10]),

        .m10_axi_wdata    (m_wdata[10]),
        .m10_axi_wstrb    (m_wstrb[10]),
        .m10_axi_wlast    (m_wlast[10]),
        .m10_axi_wvalid   (m_wvalid[10]),
        .m10_axi_wready   (m_wready[10]),

        .m10_axi_bid     (m_bid[10]),
        .m10_axi_bresp   (m_bresp[10]),
        .m10_axi_bvalid  (m_bvalid[10]),
        .m10_axi_bready  (m_bready[10]),

        .m10_axi_arid    (m_arid[10]),
        .m10_axi_araddr  (m_araddr[10]),
        .m10_axi_arlen   (m_arlen[10]),
        .m10_axi_arsize  (m_arsize[10]),
        .m10_axi_arburst (m_arburst[10]),
        .m10_axi_arvalid (m_arvalid[10]),
        .m10_axi_arready (m_arready[10]),

        .m10_axi_rid    (m_rid[10]),
        .m10_axi_rdata  (m_rdata[10]),
        .m10_axi_rresp  (m_rresp[10]),
        .m10_axi_rlast  (m_rlast[10]),
        .m10_axi_rvalid (m_rvalid[10]),
        .m10_axi_rready (m_rready[10]),


        // ========================================================
        // M11
        // ========================================================

        .m11_axi_awid     (m_awid[11]),
        .m11_axi_awaddr   (m_awaddr[11]),
        .m11_axi_awlen    (m_awlen[11]),
        .m11_axi_awsize   (m_awsize[11]),
        .m11_axi_awburst  (m_awburst[11]),
        .m11_axi_awvalid  (m_awvalid[11]),
        .m11_axi_awready  (m_awready[11]),

        .m11_axi_wdata    (m_wdata[11]),
        .m11_axi_wstrb    (m_wstrb[11]),
        .m11_axi_wlast    (m_wlast[11]),
        .m11_axi_wvalid   (m_wvalid[11]),
        .m11_axi_wready   (m_wready[11]),

        .m11_axi_bid     (m_bid[11]),
        .m11_axi_bresp   (m_bresp[11]),
        .m11_axi_bvalid  (m_bvalid[11]),
        .m11_axi_bready  (m_bready[11]),

        .m11_axi_arid    (m_arid[11]),
        .m11_axi_araddr  (m_araddr[11]),
        .m11_axi_arlen   (m_arlen[11]),
        .m11_axi_arsize  (m_arsize[11]),
        .m11_axi_arburst (m_arburst[11]),
        .m11_axi_arvalid (m_arvalid[11]),
        .m11_axi_arready (m_arready[11]),

        .m11_axi_rid    (m_rid[11]),
        .m11_axi_rdata  (m_rdata[11]),
        .m11_axi_rresp  (m_rresp[11]),
        .m11_axi_rlast  (m_rlast[11]),
        .m11_axi_rvalid (m_rvalid[11]),
        .m11_axi_rready (m_rready[11]),


        // ========================================================
        // M12
        // ========================================================

        .m12_axi_awid     (m_awid[12]),
        .m12_axi_awaddr   (m_awaddr[12]),
        .m12_axi_awlen    (m_awlen[12]),
        .m12_axi_awsize   (m_awsize[12]),
        .m12_axi_awburst  (m_awburst[12]),
        .m12_axi_awvalid  (m_awvalid[12]),
        .m12_axi_awready  (m_awready[12]),

        .m12_axi_wdata    (m_wdata[12]),
        .m12_axi_wstrb    (m_wstrb[12]),
        .m12_axi_wlast    (m_wlast[12]),
        .m12_axi_wvalid   (m_wvalid[12]),
        .m12_axi_wready   (m_wready[12]),

        .m12_axi_bid     (m_bid[12]),
        .m12_axi_bresp   (m_bresp[12]),
        .m12_axi_bvalid  (m_bvalid[12]),
        .m12_axi_bready  (m_bready[12]),

        .m12_axi_arid    (m_arid[12]),
        .m12_axi_araddr  (m_araddr[12]),
        .m12_axi_arlen   (m_arlen[12]),
        .m12_axi_arsize  (m_arsize[12]),
        .m12_axi_arburst (m_arburst[12]),
        .m12_axi_arvalid (m_arvalid[12]),
        .m12_axi_arready (m_arready[12]),

        .m12_axi_rid    (m_rid[12]),
        .m12_axi_rdata  (m_rdata[12]),
        .m12_axi_rresp  (m_rresp[12]),
        .m12_axi_rlast  (m_rlast[12]),
        .m12_axi_rvalid (m_rvalid[12]),
        .m12_axi_rready (m_rready[12]),


        // ========================================================
        // M13
        // ========================================================

        .m13_axi_awid     (m_awid[13]),
        .m13_axi_awaddr   (m_awaddr[13]),
        .m13_axi_awlen    (m_awlen[13]),
        .m13_axi_awsize   (m_awsize[13]),
        .m13_axi_awburst  (m_awburst[13]),
        .m13_axi_awvalid  (m_awvalid[13]),
        .m13_axi_awready  (m_awready[13]),

        .m13_axi_wdata    (m_wdata[13]),
        .m13_axi_wstrb    (m_wstrb[13]),
        .m13_axi_wlast    (m_wlast[13]),
        .m13_axi_wvalid   (m_wvalid[13]),
        .m13_axi_wready   (m_wready[13]),

        .m13_axi_bid     (m_bid[13]),
        .m13_axi_bresp   (m_bresp[13]),
        .m13_axi_bvalid  (m_bvalid[13]),
        .m13_axi_bready  (m_bready[13]),

        .m13_axi_arid    (m_arid[13]),
        .m13_axi_araddr  (m_araddr[13]),
        .m13_axi_arlen   (m_arlen[13]),
        .m13_axi_arsize  (m_arsize[13]),
        .m13_axi_arburst (m_arburst[13]),
        .m13_axi_arvalid (m_arvalid[13]),
        .m13_axi_arready (m_arready[13]),

        .m13_axi_rid    (m_rid[13]),
        .m13_axi_rdata  (m_rdata[13]),
        .m13_axi_rresp  (m_rresp[13]),
        .m13_axi_rlast  (m_rlast[13]),
        .m13_axi_rvalid (m_rvalid[13]),
        .m13_axi_rready (m_rready[13]),


        // ========================================================
        // M14
        // ========================================================

        .m14_axi_awid     (m_awid[14]),
        .m14_axi_awaddr   (m_awaddr[14]),
        .m14_axi_awlen    (m_awlen[14]),
        .m14_axi_awsize   (m_awsize[14]),
        .m14_axi_awburst  (m_awburst[14]),
        .m14_axi_awvalid  (m_awvalid[14]),
        .m14_axi_awready  (m_awready[14]),

        .m14_axi_wdata    (m_wdata[14]),
        .m14_axi_wstrb    (m_wstrb[14]),
        .m14_axi_wlast    (m_wlast[14]),
        .m14_axi_wvalid   (m_wvalid[14]),
        .m14_axi_wready   (m_wready[14]),

        .m14_axi_bid     (m_bid[14]),
        .m14_axi_bresp   (m_bresp[14]),
        .m14_axi_bvalid  (m_bvalid[14]),
        .m14_axi_bready  (m_bready[14]),

        .m14_axi_arid    (m_arid[14]),
        .m14_axi_araddr  (m_araddr[14]),
        .m14_axi_arlen   (m_arlen[14]),
        .m14_axi_arsize  (m_arsize[14]),
        .m14_axi_arburst (m_arburst[14]),
        .m14_axi_arvalid (m_arvalid[14]),
        .m14_axi_arready (m_arready[14]),

        .m14_axi_rid    (m_rid[14]),
        .m14_axi_rdata  (m_rdata[14]),
        .m14_axi_rresp  (m_rresp[14]),
        .m14_axi_rlast  (m_rlast[14]),
        .m14_axi_rvalid (m_rvalid[14]),
        .m14_axi_rready (m_rready[14])

    );


    // ============================================================
    // FSDB WAVEFORM DUMP
    // ============================================================

    initial begin

        $fsdbDumpfile("axi_3x15.fsdb");

        $fsdbDumpvars(0, tb_axi_interconnect_3x15);

    end


    // ============================================================
    // TEST COUNTERS
    // ============================================================

    integer total_tests;
    integer passed_tests;
    integer failed_tests;


    // ============================================================
    // MASTER SELECT TASK
    //
    // This task assigns the correct signals depending on
    // which master is being used.
    // ============================================================

    task automatic drive_write_request(
        input integer master,
        input [ADDR_WIDTH-1:0] addr,
        input [DATA_WIDTH-1:0] data,
        input [ID_WIDTH-1:0] id
    );

        begin

            if (master == 0) begin

                s00_awid    = id;
                s00_awaddr  = addr;
                s00_awlen   = 0;
                s00_awsize  = 3'b011;
                s00_awburst = 2'b01;
                s00_awvalid = 1'b1;

                s00_wdata   = data;
                s00_wstrb   = {STRB_WIDTH{1'b1}};
                s00_wlast   = 1'b1;
                s00_wvalid  = 1'b1;

            end

            else if (master == 1) begin

                s01_awid    = id;
                s01_awaddr  = addr;
                s01_awlen   = 0;
                s01_awsize  = 3'b011;
                s01_awburst = 2'b01;
                s01_awvalid = 1'b1;

                s01_wdata   = data;
                s01_wstrb   = {STRB_WIDTH{1'b1}};
                s01_wlast   = 1'b1;
                s01_wvalid  = 1'b1;

            end

            else begin

                s02_awid    = id;
                s02_awaddr  = addr;
                s02_awlen   = 0;
                s02_awsize  = 3'b011;
                s02_awburst = 2'b01;
                s02_awvalid = 1'b1;

                s02_wdata   = data;
                s02_wstrb   = {STRB_WIDTH{1'b1}};
                s02_wlast   = 1'b1;
                s02_wvalid  = 1'b1;

            end

        end

    endtask


    // ============================================================
    // WRITE TEST
    // ============================================================

    task automatic test_write(
        input integer master,
        input integer slave,
        input [ID_WIDTH-1:0] req_id
    );

        reg [ADDR_WIDTH-1:0] addr;
        reg [DATA_WIDTH-1:0] data;
        integer timeout;
        bit aw_done;
        bit w_done;
        bit b_done;

        begin

            total_tests = total_tests + 1;

            addr = (slave << 24) + 32'h00000100;
            data = 64'hA0000000 + slave;

            aw_done = 0;
            w_done  = 0;
            b_done  = 0;

            $display("");
            $display("-----------------------------------------------");
            $display("WRITE TEST : S%0d -> M%0d", master, slave);
            $display("ADDR        = %h", addr);
            $display("DATA        = %h", data);
            $display("REQUEST ID  = %h", req_id);
            $display("-----------------------------------------------");


            // ------------------------------------------------------
            // Drive AW and W
            // ------------------------------------------------------

            drive_write_request(
                master,
                addr,
                data,
                req_id
            );


            // ------------------------------------------------------
            // Wait for AW and W handshakes
            // ------------------------------------------------------

            timeout = 0;

            while ((!aw_done || !w_done) && timeout < 100) begin

                @(posedge clk);

                if (master == 0) begin

                    if (s00_awvalid && s00_awready) begin
                        aw_done = 1;
                        s00_awvalid = 0;
                        $display("[MASTER S0] AW handshake");
                    end

                    if (s00_wvalid && s00_wready) begin
                        w_done = 1;
                        s00_wvalid = 0;
                        $display("[MASTER S0] W handshake");
                    end

                end

                else if (master == 1) begin

                    if (s01_awvalid && s01_awready) begin
                        aw_done = 1;
                        s01_awvalid = 0;
                        $display("[MASTER S1] AW handshake");
                    end

                    if (s01_wvalid && s01_wready) begin
                        w_done = 1;
                        s01_wvalid = 0;
                        $display("[MASTER S1] W handshake");
                    end

                end

                else begin

                    if (s02_awvalid && s02_awready) begin
                        aw_done = 1;
                        s02_awvalid = 0;
                        $display("[MASTER S2] AW handshake");
                    end

                    if (s02_wvalid && s02_wready) begin
                        w_done = 1;
                        s02_wvalid = 0;
                        $display("[MASTER S2] W handshake");
                    end

                end

                timeout = timeout + 1;

            end


            // ------------------------------------------------------
            // AW/W TIMEOUT
            // ------------------------------------------------------

            if (!aw_done || !w_done) begin

                failed_tests = failed_tests + 1;

                $display(
                    "FAIL WRITE : S%0d -> M%0d : AW/W TIMEOUT",
                    master,
                    slave
                );

                // Deassert all write valids.
                s00_awvalid = 0;
                s00_wvalid  = 0;
                s01_awvalid = 0;
                s01_wvalid  = 0;
                s02_awvalid = 0;
                s02_wvalid  = 0;

                return;

            end


            // ------------------------------------------------------
            // Select correct BREADY
            // ------------------------------------------------------

            if (master == 0)
                s00_bready = 1'b1;
            else if (master == 1)
                s01_bready = 1'b1;
            else
                s02_bready = 1'b1;


            // ------------------------------------------------------
            // Wait for BVALID
            // ------------------------------------------------------

            timeout = 0;

            while (!b_done && timeout < 100) begin

                @(posedge clk);

                if (master == 0) begin

                    if (s00_bvalid && s00_bready) begin

                        b_done = 1;

                        $display(
                            "[MASTER S0] B response : BID=%h BRESP=%b",
                            s00_bid,
                            s00_bresp
                        );

                        if (s00_bresp == 2'b00)
                            passed_tests = passed_tests + 1;
                        else
                            failed_tests = failed_tests + 1;

                    end

                end

                else if (master == 1) begin

                    if (s01_bvalid && s01_bready) begin

                        b_done = 1;

                        $display(
                            "[MASTER S1] B response : BID=%h BRESP=%b",
                            s01_bid,
                            s01_bresp
                        );

                        if (s01_bresp == 2'b00)
                            passed_tests = passed_tests + 1;
                        else
                            failed_tests = failed_tests + 1;

                    end

                end

                else begin

                    if (s02_bvalid && s02_bready) begin

                        b_done = 1;

                        $display(
                            "[MASTER S2] B response : BID=%h BRESP=%b",
                            s02_bid,
                            s02_bresp
                        );

                        if (s02_bresp == 2'b00)
                            passed_tests = passed_tests + 1;
                        else
                            failed_tests = failed_tests + 1;

                    end

                end

                timeout = timeout + 1;

            end


            // ------------------------------------------------------
            // B RESPONSE TIMEOUT
            // ------------------------------------------------------

            if (!b_done) begin

                failed_tests = failed_tests + 1;

                $display(
                    "FAIL WRITE : S%0d -> M%0d : B RESPONSE TIMEOUT",
                    master,
                    slave
                );

            end

            else if (
                (master == 0 && s00_bresp == 2'b00) ||
                (master == 1 && s01_bresp == 2'b00) ||
                (master == 2 && s02_bresp == 2'b00)
            ) begin

                $display(
                    "PASS WRITE : S%0d -> M%0d   ADDR=%h DATA=%h",
                    master,
                    slave,
                    addr,
                    data
                );

            end


            // ------------------------------------------------------
            // Clear BREADY
            // ------------------------------------------------------

            s00_bready = 0;
            s01_bready = 0;
            s02_bready = 0;

        end

    endtask


    // ============================================================
    // READ TEST
    // ============================================================

    task automatic test_read(
        input integer master,
        input integer slave,
        input [ID_WIDTH-1:0] req_id
    );

        reg [ADDR_WIDTH-1:0] addr;
        integer timeout;
        bit ar_done;
        bit r_done;

        begin

            total_tests = total_tests + 1;

            addr = (slave << 24) + 32'h00000200;

            ar_done = 0;
            r_done  = 0;

            $display("");
            $display("-----------------------------------------------");
            $display("READ TEST : S%0d -> M%0d", master, slave);
            $display("ADDR       = %h", addr);
            $display("REQUEST ID = %h", req_id);
            $display("-----------------------------------------------");


            // ------------------------------------------------------
            // Drive AR
            // ------------------------------------------------------

            if (master == 0) begin

                s00_arid    = req_id;
                s00_araddr  = addr;
                s00_arlen   = 0;
                s00_arsize  = 3'b011;
                s00_arburst = 2'b01;
                s00_arvalid = 1'b1;

            end

            else if (master == 1) begin

                s01_arid    = req_id;
                s01_araddr  = addr;
                s01_arlen   = 0;
                s01_arsize  = 3'b011;
                s01_arburst = 2'b01;
                s01_arvalid = 1'b1;

            end

            else begin

                s02_arid    = req_id;
                s02_araddr  = addr;
                s02_arlen   = 0;
                s02_arsize  = 3'b011;
                s02_arburst = 2'b01;
                s02_arvalid = 1'b1;

            end


            // ------------------------------------------------------
            // Wait for AR handshake
            // ------------------------------------------------------

            timeout = 0;

            while (!ar_done && timeout < 100) begin

                @(posedge clk);

                if (master == 0) begin

                    if (s00_arvalid && s00_arready) begin

                        ar_done = 1;
                        s00_arvalid = 0;

                        $display("[MASTER S0] AR handshake");

                    end

                end

                else if (master == 1) begin

                    if (s01_arvalid && s01_arready) begin

                        ar_done = 1;
                        s01_arvalid = 0;

                        $display("[MASTER S1] AR handshake");

                    end

                end

                else begin

                    if (s02_arvalid && s02_arready) begin

                        ar_done = 1;
                        s02_arvalid = 0;

                        $display("[MASTER S2] AR handshake");

                    end

                end

                timeout = timeout + 1;

            end


            // ------------------------------------------------------
            // AR TIMEOUT
            // ------------------------------------------------------

            if (!ar_done) begin

                failed_tests = failed_tests + 1;

                $display(
                    "FAIL READ : S%0d -> M%0d : AR TIMEOUT",
                    master,
                    slave
                );

                s00_arvalid = 0;
                s01_arvalid = 0;
                s02_arvalid = 0;

                return;

            end


            // ------------------------------------------------------
            // Assert RREADY
            // ------------------------------------------------------

            if (master == 0)
                s00_rready = 1'b1;
            else if (master == 1)
                s01_rready = 1'b1;
            else
                s02_rready = 1'b1;


            // ------------------------------------------------------
            // Wait for RVALID
            // ------------------------------------------------------

            timeout = 0;

            while (!r_done && timeout < 100) begin

                @(posedge clk);

                if (master == 0) begin

                    if (s00_rvalid && s00_rready) begin

                        r_done = 1;

                        $display(
                            "[MASTER S0] R response : RID=%h DATA=%h RRESP=%b RLAST=%b",
                            s00_rid,
                            s00_rdata,
                            s00_rresp,
                            s00_rlast
                        );

                        if ((s00_rresp == 2'b00) &&
                            (s00_rlast == 1'b1) &&
                            (s00_rdata == slave)) begin

                            passed_tests = passed_tests + 1;

                            $display(
                                "PASS READ : S0 -> M%0d   DATA=%h",
                                slave,
                                s00_rdata
                            );

                        end

                        else begin

                            failed_tests = failed_tests + 1;

                            $display(
                                "FAIL READ : S0 -> M%0d : BAD RESPONSE",
                                slave
                            );

                        end

                    end

                end

                else if (master == 1) begin

                    if (s01_rvalid && s01_rready) begin

                        r_done = 1;

                        $display(
                            "[MASTER S1] R response : RID=%h DATA=%h RRESP=%b RLAST=%b",
                            s01_rid,
                            s01_rdata,
                            s01_rresp,
                            s01_rlast
                        );

                        if ((s01_rresp == 2'b00) &&
                            (s01_rlast == 1'b1) &&
                            (s01_rdata == slave)) begin

                            passed_tests = passed_tests + 1;

                            $display(
                                "PASS READ : S1 -> M%0d   DATA=%h",
                                slave,
                                s01_rdata
                            );

                        end

                        else begin

                            failed_tests = failed_tests + 1;

                            $display(
                                "FAIL READ : S1 -> M%0d : BAD RESPONSE",
                                slave
                            );

                        end

                    end

                end

                else begin

                    if (s02_rvalid && s02_rready) begin

                        r_done = 1;

                        $display(
                            "[MASTER S2] R response : RID=%h DATA=%h RRESP=%b RLAST=%b",
                            s02_rid,
                            s02_rdata,
                            s02_rresp,
                            s02_rlast
                        );

                        if ((s02_rresp == 2'b00) &&
                            (s02_rlast == 1'b1) &&
                            (s02_rdata == slave)) begin

                            passed_tests = passed_tests + 1;

                            $display(
                                "PASS READ : S2 -> M%0d   DATA=%h",
                                slave,
                                s02_rdata
                            );

                        end

                        else begin

                            failed_tests = failed_tests + 1;

                            $display(
                                "FAIL READ : S2 -> M%0d : BAD RESPONSE",
                                slave
                            );

                        end

                    end

                end

                timeout = timeout + 1;

            end


            // ------------------------------------------------------
            // R TIMEOUT
            // ------------------------------------------------------

            if (!r_done) begin

                failed_tests = failed_tests + 1;

                $display(
                    "FAIL READ : S%0d -> M%0d : R RESPONSE TIMEOUT",
                    master,
                    slave
                );

            end


            // ------------------------------------------------------
            // Clear RREADY
            // ------------------------------------------------------

            s00_rready = 0;
            s01_rready = 0;
            s02_rready = 0;

        end

    endtask


    // ============================================================
    // INITIALIZE ALL MASTER SIGNALS
    // ============================================================

    task automatic initialize_masters;

        begin

            // S00

            s00_awid    = '0;
            s00_awaddr  = '0;
            s00_awlen   = '0;
            s00_awsize  = '0;
            s00_awburst = '0;
            s00_awvalid = 0;

            s00_wdata   = '0;
            s00_wstrb   = '0;
            s00_wlast   = 0;
            s00_wvalid  = 0;

            s00_bready  = 0;

            s00_arid    = '0;
            s00_araddr  = '0;
            s00_arlen   = '0;
            s00_arsize  = '0;
            s00_arburst = '0;
            s00_arvalid = 0;

            s00_rready  = 0;


            // S01

            s01_awid    = '0;
            s01_awaddr  = '0;
            s01_awlen   = '0;
            s01_awsize  = '0;
            s01_awburst = '0;
            s01_awvalid = 0;

            s01_wdata   = '0;
            s01_wstrb   = '0;
            s01_wlast   = 0;
            s01_wvalid  = 0;

            s01_bready  = 0;

            s01_arid    = '0;
            s01_araddr  = '0;
            s01_arlen   = '0;
            s01_arsize  = '0;
            s01_arburst = '0;
            s01_arvalid = 0;

            s01_rready  = 0;


            // S02

            s02_awid    = '0;
            s02_awaddr  = '0;
            s02_awlen   = '0;
            s02_awsize  = '0;
            s02_awburst = '0;
            s02_awvalid = 0;

            s02_wdata   = '0;
            s02_wstrb   = '0;
            s02_wlast   = 0;
            s02_wvalid  = 0;

            s02_bready  = 0;

            s02_arid    = '0;
            s02_araddr  = '0;
            s02_arlen   = '0;
            s02_arsize  = '0;
            s02_arburst = '0;
            s02_arvalid = 0;

            s02_rready  = 0;

        end

    endtask


    // ============================================================
    // MAIN TEST
    // ============================================================

    integer master_idx;
    integer slave_idx;

    initial begin

        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        initialize_masters();

        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------

        rst = 1'b1;

        $display("");
        $display("================================================");
        $display(" AXI 3x15 INTERCONNECT VERIFICATION");
        $display("================================================");
        $display("");
        $display("Applying reset...");

        repeat (5)
            @(posedge clk);

        rst = 1'b0;

        $display("Reset released.");
        $display("");


        // --------------------------------------------------------
        // WRITE TESTS
        //
        // 3 masters × 15 slaves = 45 writes
        // --------------------------------------------------------

        $display("================================================");
        $display(" WRITE TESTS");
        $display("================================================");

        for (master_idx = 0;
             master_idx < NUM_MASTERS;
             master_idx = master_idx + 1) begin

            for (slave_idx = 0;
                 slave_idx < NUM_SLAVES;
                 slave_idx = slave_idx + 1) begin

                test_write(
                    master_idx,
                    slave_idx,
                    (master_idx * 8'h10) + slave_idx + 1
                );

                repeat (2)
                    @(posedge clk);

            end

        end


        // --------------------------------------------------------
        // READ TESTS
        //
        // 3 masters × 15 slaves = 45 reads
        // --------------------------------------------------------

        $display("");
        $display("================================================");
        $display(" READ TESTS");
        $display("================================================");

        for (master_idx = 0;
             master_idx < NUM_MASTERS;
             master_idx = master_idx + 1) begin

            for (slave_idx = 0;
                 slave_idx < NUM_SLAVES;
                 slave_idx = slave_idx + 1) begin

                test_read(
                    master_idx,
                    slave_idx,
                    8'h80 +
                    (master_idx * 8'h10) +
                    slave_idx
                );

                repeat (2)
                    @(posedge clk);

            end

        end


        // --------------------------------------------------------
        // FINAL RESULT
        // --------------------------------------------------------

        $display("");
        $display("================================================");
        $display(" FINAL RESULT");
        $display("================================================");

        $display("Total tests : %0d", total_tests);
        $display("Passed      : %0d", passed_tests);
        $display("Failed      : %0d", failed_tests);

        if (failed_tests == 0) begin

            $display("");
            $display("******** AXI 3x15 INTERCONNECT : PASS ********");
            $display("");

        end

        else begin

            $display("");
            $display("******** AXI 3x15 INTERCONNECT : FAIL ********");
            $display("");

        end

        #100;

        $finish;

    end 
	
initial begin
    $fsdbDumpfile("axi_intcnt.fsdb");  // Record the waveform, waveform name testname.fsdb
    $fsdbDumpvars("+all");    // + all parameters, Struct structures in Dump SV
    $fsdbDumpSVA();      // Present the result of Assertion in FSDB
    $fsdbDumpMDA(); 
  end

endmodule
