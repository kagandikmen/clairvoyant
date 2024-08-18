# See LICENSE for license details.

#*****************************************************************************
# sru_instrs.S
#-----------------------------------------------------------------------------
#
# Test custom SRU instructions (enh, lf0, lf1, lf2, lf3).
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

  TEST_SRU( 2, 0x00007ffe, 0x00fe00fe, 0xff00ff00, tdatset2 );

  # test overleap logic
  TEST_SRU( 3, 0x7f007ffe, 0x00fe00fe, 0x0000ff00, tdatset3 );

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

tdatset1:
tdat1:  .word 0x00fe00fe
tdat2:  .word 0xff00ff00
tdat3:  .word 0x0ff00ff0
tdat4:  .word 0xf00ff00f

tdatset2:
tdat5:  .word 0xba5eba11
tdat6:  .word 0xf01dab1e
tdat7:  .word 0xdeadbeef
tdat8:  .word 0xdecade20

tdatset3:
tdat9:  .word 0xba5eba11
tdat10: .word 0xf01dab1e
tdat11: .word 0xdeadbeef
tdat12: .word 0xdecade20

RVTEST_DATA_END
