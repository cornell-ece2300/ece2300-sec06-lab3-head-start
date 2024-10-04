//========================================================================
// DLatch_1b_GL-test
//========================================================================

`include "ece2300-test.v"
`include "DLatch_GL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  // verilator lint_off UNUSED
  logic clk;
  logic reset;
  // verilator lint_on UNUSED

  ece2300_TestUtils t( .* );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic dut_clk;
  logic dut_d;
  logic dut_q;

  DLatch_GL dlatch
  (
    .clk (dut_clk),
    .d   (dut_d),
    .q   (dut_q)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // All tasks start at #1 after the rising edge of the clock. So we
  // write the inputs #1 after the rising edge, and check the outputs #1
  // before the next rising edge.

  task check
  (
    input logic _clk,
    input logic d,
    input logic q
  );
    if ( !t.failed ) begin

      dut_clk = _clk;
      dut_d   = d;

      #8;

      if ( t.n != 0 ) begin
        $display( "%3d: %b %b > %b", t.cycles,
                  dut_clk, dut_d, dut_q );
      end

      `ECE2300_CHECK_EQ( dut_q, q );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //    clk d  q
    check( 0, 0, 1'bx ); // q is unknown
    check( 1, 0, 0 );
    check( 0, 0, 0 );
    check( 1, 0, 0 );

  endtask

  //----------------------------------------------------------------------
  // test_case_2_exhaustive
  //----------------------------------------------------------------------

  task test_case_2_exhaustive();
    t.test_case_begin( "test_case_2_exhaustive" );

    //''' ACTIVITY '''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Add checks for exhaustive testing
    //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Check all possible inputs and states. Exhaustive testing for
    // sequential logic is more complicated than for combinational logic.
    // We need to treat the clock as another input, so we need four
    // checks to try all possible values of d when clk is high (i.e.,
    // latch is transparent) and when clk is low (i.e., latch is opaque).
    // We also need to do our checks when the D latch is opaque twice,
    // first when the D latch is storing a one and again when the D
    // latch is storing a zero. Then we need to do one final check to
    // make sure we can return to the original state.
    //
    // The following template will exhaustively test the D latch. You
    // just need to replace every ? with what the expected output is for
    // that check.

    //    clk d  q
    check( 0, 0, 1'bx );
    check( 1, 0, ? ); // d=0, latch is transparent
    check( 1, 1, ? ); // d=1, latch is transparent
    check( 0, 0, ? ); // d=0, latch is storing 1
    check( 0, 1, ? ); // d=1, latch is storing 1
    check( 1, 0, ? );
    check( 1, 0, ? );
    check( 0, 0, ? ); // d=0, latch is storing 0
    check( 0, 1, ? ); // d=1, latch is storing 0
    check( 1, 0, ? ); // return to original state

  endtask


  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin( `__FILE__ );

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_exhaustive();

    t.test_bench_end();
  end

endmodule

