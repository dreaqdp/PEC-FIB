
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

--
-- Adaptacion a VHDL para la asignatura de PEC
--

---------------------------------------------------------------------------------------
--
-- Author: John Clayton
-- Date  : April 30, 2001
-- Update: 4/30/01 copied this file from lcd_2.v (pared down).
-- Update: 5/24/01 changed the first module from "ps2_keyboard_receiver"
--                 to "ps2_keyboard_interface"
-- Update: 5/29/01 Added input synchronizing flip-flops.  Changed state
--                 encoding (m1) for good operation after part config.
-- Update: 5/31/01 Added low drive strength and slow transitions to ps2_clk
--                 and ps2_data in the constraints file.  Added the signal
--                 "tx_shifting_done" as distinguished from "rx_shifting_done."
--                 Debugged the transmitter portion in the lab.
-- Update: 6/01/01 Added horizontal tab to the ascii output.
-- Update: 6/01/01 Added parameter TRAP_SHIFT_KEYS.
-- Update: 6/05/01 Debugged the "debounce" timer functionality.
--                 Used 60usec timer as a "watchdog" timeout during
--                 receive from the keyboard.  This means that a keyboard
--                 can now be "hot plugged" into the interface, without
--                 messing up the bit_count, since the bit_count is reset
--                 to zero during periods of inactivity anyway.  This was
--                 difficult to debug.  I ended up using the logic analyzer,
--                 and had to scratch my head quite a bit.
-- Update: 6/06/01 Removed extra comments before the input synchronizing
--                 flip-flops.  Used the correct parameter to size the
--                 5usec_timer_count.  Changed the name of this file from
--                 ps2.v to ps2_keyboard.v
-- Update: 6/06/01 Removed "&& q[7:0]" in output_strobe logic.  Removed extra
--                 commented out "else" condition in the shift register and
--                 bit counter.
-- Update: 6/07/01 Changed default values for 60usec timer parameters so that
--                 they correspond to 60usec for a 49.152MHz clock.
--
--
--
--
--
-- Description
---------------------------------------------------------------------------------------
-- This is a state-machine driven serial-to-parallel and parallel-to-serial
-- interface to the ps2 style keyboard interface.  The details of the operation
-- of the keyboard interface were obtained from the following website:
--
--   http://www.beyondlogic.org/keyboard/keybrd.htm
--
-- Some aspects of the keyboard interface are not implemented (e.g, parity
-- checking for the receive side, and recognition of the various commands
-- which the keyboard sends out, such as "power on selt test passed," "Error"
-- and "Resend.")  However, if the user wishes to recognize these reply
-- messages, the scan code output can always be used to extend functionality
-- as desired.
--
-- Note that the "Extended" (0xE0) and "Released" (0xF0) codes are recognized.
-- The rx interface provides separate indicator flags for these two conditions
-- with every valid character scan code which it provides.  The shift keys are
-- also trapped by the interface, in order to provide correct uppercase ASCII
-- characters at the ascii output, although the scan codes for the shift keys
-- are still provided at the scan code output.  So, the left/right ALT keys
-- can be differentiated by the presence of the rx_entended signal, while the
-- left/right shift keys are differentiable by the different scan codes
-- received.
--
-- The interface to the ps2 keyboard uses ps2_clk clock rates of
-- 30-40 kHz, dependent upon the keyboard itself.  The rate at which the state
-- machine runs should be at least twice the rate of the ps2_clk, so that the
-- states can accurately follow the clock signal itself.  Four times
-- oversampling is better.  Say 200kHz at least.  The upper limit for clocking
-- the state machine will undoubtedly be determined by delays in the logic
-- which decodes the scan codes into ASCII equivalents.  The maximum speed
-- will be most likely many megahertz, depending upon target technology.
-- In order to run the state machine extremely fast, synchronizing flip-flops
-- have been added to the ps2_clk and ps2_data inputs of the state machine.
-- This avoids poor performance related to slow transitions of the inputs.
--
-- Because this is a bi-directional interface, while reading from the keyboard
-- the ps2_clk and ps2_data lines are used as inputs.  While writing to the
-- keyboard, however (which may be done at any time.  If writing interrupts a
-- read from the keyboard, the keyboard will buffer up its data, and send
-- it later) both the ps2_clk and ps2_data lines are occasionally pulled low,
-- and pullup resistors are used to bring the lines high again, by setting
-- the drivers to high impedance state.
--
-- The tx interface, for writing to the keyboard, does not provide any special
-- pre-processing.  It simply transmits the 8-bit command value to the
-- keyboard.
--
-- Pullups MUST BE USED on the ps2_clk and ps2_data lines for this design,
-- whether they be internal to an FPGA I/O pad, or externally placed.
-- If internal pullups are used, they may be fairly weak, causing bounces
-- due to crosstalk, etc.  There is a "debounce timer" implemented in order
-- to eliminate erroneous state transitions which would occur based on bounce.
--
-- Parameters are provided in order to configure and appropriately size the
-- counter of a 60 microsecond timer used in the transmitter, depending on
-- the clock frequency used.  The 60 microsecond period is guaranteed to be
-- more than one period of the ps2_clk_s signal.
--
-- Also, a smaller 5 microsecond timer has been included for "debounce".
-- This is used because, with internal pullups on the ps2_clk and ps2_data
-- lines, there is some bouncing around which occurs
--
-- A parameter TRAP_SHIFT_KEYS allows the user to eliminate shift keypresses
-- from producing scan codes (along with their "undefined" ASCII equivalents)
-- at the output of the interface.  If TRAP_SHIFT_KEYS is non-zero, the shift
-- key status will only be reported by rx_shift_key_on.  No ascii or scan
-- codes will be reported for the shift keys.  This is useful for those who
-- wish to use the ASCII data stream, and who don't want to have to "filter
-- out" the shift key codes.
--
---------------------------------------------------------------------------------------


ENTITY ps2_keyboard_interface IS
   GENERIC (
      -- rx_read_o
      -- rx_read_ack_i
      -- Parameters
      -- The timer value can be up to (2^bits) inclusive.
      TIMER_60USEC_VALUE_PP        : INTEGER := 2950;    -- Number of sys_clks for 60usec.
      TIMER_60USEC_BITS_PP         : INTEGER := 12;      -- Number of bits needed for timer
      TIMER_5USEC_VALUE_PP         : INTEGER := 186;     -- Number of sys_clks for debounce
      TIMER_5USEC_BITS_PP          : INTEGER := 8;       -- Number of bits needed for timer
      TRAP_SHIFT_KEYS_PP           : INTEGER := 0       -- Default: No shift key trap.
   );
   PORT (

      clk                          : IN STD_LOGIC;
      reset                        : IN STD_LOGIC;
      ps2_clk                      : INOUT STD_LOGIC;
      ps2_data                     : INOUT STD_LOGIC;
      rx_extended                  : OUT STD_LOGIC;
      rx_released                  : OUT STD_LOGIC;
      rx_shift_key_on              : OUT STD_LOGIC;
      rx_scan_code                 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      rx_ascii                     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      rx_data_ready                : OUT STD_LOGIC;
      rx_read                      : IN STD_LOGIC;
      tx_data                      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      tx_write                     : IN STD_LOGIC;
      tx_write_ack_o               : OUT STD_LOGIC;
      tx_error_no_keyboard_ack     : OUT STD_LOGIC
   );
END ENTITY ps2_keyboard_interface;

ARCHITECTURE trans OF ps2_keyboard_interface IS

   FUNCTION to_stdlogic (
      val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;


   FUNCTION xnor_br (
      val : std_logic_vector) RETURN std_logic IS

      VARIABLE rtn : std_logic := '0';
   BEGIN
      FOR index IN val'RANGE LOOP
         rtn := rtn XOR val(index);
      END LOOP;
      RETURN(NOT rtn);
   END xnor_br;


    TYPE tipo_estado_m1 IS (m1_rx_clk_h, m1_rx_clk_l, m1_rx_falling_edge_marker, m1_rx_rising_edge_marker,
                            m1_tx_force_clk_l, m1_tx_first_wait_clk_h, m1_tx_first_wait_clk_l, m1_tx_reset_timer,
                            m1_tx_wait_clk_h, m1_tx_clk_h, m1_tx_clk_l, m1_tx_wait_keyboard_ack, m1_tx_done_recovery,
                            m1_tx_error_no_keyboard_ack, m1_tx_rising_edge_marker);
    SIGNAL m1_state : tipo_estado_m1;
    SIGNAL m1_next_state : tipo_estado_m1;


    TYPE tipo_estado_m2 IS (m2_rx_data_ready, m2_rx_data_ready_ack);
    SIGNAL m2_state : tipo_estado_m2;
    SIGNAL m2_next_state : tipo_estado_m2;


   -- Internal signal declarations
   SIGNAL timer_60usec_done     : STD_LOGIC;
   SIGNAL timer_5usec_done      : STD_LOGIC;
   SIGNAL extended              : STD_LOGIC;
   SIGNAL released              : STD_LOGIC;
   SIGNAL shift_key_on          : STD_LOGIC;

   -- NOTE: These two signals used to be one.  They
   --       were split into two signals because of
   --       shift key trapping.  With shift key
   --       trapping, no event is generated externally,
   --       but the "hold" data must still be cleared
   --       anyway regardless, in preparation for the
   --       next scan codes.
   SIGNAL rx_output_event       : STD_LOGIC;        -- Used only to clear: hold_released, hold_extended
   SIGNAL rx_output_strobe      : STD_LOGIC;        -- Used to produce the actual output.

   SIGNAL tx_parity_bit         : STD_LOGIC;
   SIGNAL rx_shifting_done      : STD_LOGIC;
   SIGNAL tx_shifting_done      : STD_LOGIC;
   SIGNAL shift_key_plus_code   : STD_LOGIC_VECTOR(11 DOWNTO 0);

   SIGNAL q                     : STD_LOGIC_VECTOR(11 - 1 DOWNTO 0);
   SIGNAL bit_count             : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL enable_timer_60usec   : STD_LOGIC;
   SIGNAL enable_timer_5usec    : STD_LOGIC;
   SIGNAL timer_60usec_count    : STD_LOGIC_VECTOR(TIMER_60USEC_BITS_PP - 1 DOWNTO 0);
   SIGNAL timer_5usec_count     : STD_LOGIC_VECTOR(TIMER_5USEC_BITS_PP - 1 DOWNTO 0);
      SIGNAL ascii                 : STD_LOGIC_VECTOR(7 DOWNTO 0);        -- "REG" type only because a case statement is used.
   SIGNAL left_shift_key        : STD_LOGIC;
   SIGNAL right_shift_key       : STD_LOGIC;
   SIGNAL hold_extended         : STD_LOGIC;        -- Holds prior value, cleared at rx_output_strobe
   SIGNAL hold_released         : STD_LOGIC;        -- Holds prior value, cleared at rx_output_strobe
   SIGNAL ps2_clk_s             : STD_LOGIC;        -- Synchronous version of this input
   SIGNAL ps2_data_s            : STD_LOGIC;        -- Synchronous version of this input
   SIGNAL ps2_clk_hi_z          : STD_LOGIC;        -- Without keyboard, high Z equals 1 due to pullups.
   SIGNAL ps2_data_hi_z         : STD_LOGIC;        -- Without keyboard, high Z equals 1 due to pullups.

   -- Declare intermediate signals for referenced outputs
   SIGNAL rx_shift_key_on_xhdl0 : STD_LOGIC;
   SIGNAL tx_write_ack_o_xhdl1  : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   rx_shift_key_on <= rx_shift_key_on_xhdl0;
   tx_write_ack_o <= tx_write_ack_o_xhdl1;

   ----------------------------------------------------------------------------
   -- Module code

   ps2_clk <= 'Z' WHEN (ps2_clk_hi_z = '1') ELSE
              '0';
   ps2_data <= 'Z' WHEN (ps2_data_hi_z = '1') ELSE
               '0';

   -- Input "synchronizing" logic -- synchronizes the inputs to the state
   -- machine clock, thus avoiding errors related to
   -- spurious state machine transitions.
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         ps2_clk_s <= ps2_clk;
         ps2_data_s <= ps2_data;
      END IF;
   END PROCESS;


   -- State register
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset = '1') THEN
            m1_state <= m1_rx_clk_h;
         ELSE
            m1_state <= m1_next_state;
         END IF;
      END IF;
   END PROCESS;


   -- State transition logic
   PROCESS (m1_state, q, tx_shifting_done, tx_write, ps2_clk_s, ps2_data_s, timer_60usec_done, timer_5usec_done)
   BEGIN

      -- Output signals default to this value, unless changed in a state condition.
      ps2_clk_hi_z <= '1';
      ps2_data_hi_z <= '1';
      tx_error_no_keyboard_ack <= '0';
      enable_timer_60usec <= '0';

      enable_timer_5usec <= '0';

      CASE m1_state IS

         WHEN m1_rx_clk_h =>
            enable_timer_60usec <= '1';
            IF (tx_write = '1') THEN
               m1_next_state <= m1_tx_reset_timer;
            ELSIF ((NOT(ps2_clk_s)) = '1') THEN
               m1_next_state <= m1_rx_falling_edge_marker;
            ELSE
               m1_next_state <= m1_rx_clk_h;
            END IF;

         WHEN m1_rx_falling_edge_marker =>
            enable_timer_60usec <= '0';
            m1_next_state <= m1_rx_clk_l;

         WHEN m1_rx_rising_edge_marker =>
            enable_timer_60usec <= '0';
            m1_next_state <= m1_rx_clk_h;

         WHEN m1_rx_clk_l =>
            enable_timer_60usec <= '1';
            IF (tx_write = '1') THEN
               m1_next_state <= m1_tx_reset_timer;
            ELSIF (ps2_clk_s = '1') THEN
               m1_next_state <= m1_rx_rising_edge_marker;
            ELSE
               m1_next_state <= m1_rx_clk_l;
            END IF;

         WHEN m1_tx_reset_timer =>
            enable_timer_60usec <= '0';
            m1_next_state <= m1_tx_force_clk_l;
         -- Force the ps2_clk line low.

         WHEN m1_tx_force_clk_l =>
            enable_timer_60usec <= '1';
            ps2_clk_hi_z <= '0';
            IF (timer_60usec_done = '1') THEN
               m1_next_state <= m1_tx_first_wait_clk_h;
            ELSE
               m1_next_state <= m1_tx_force_clk_l;
            END IF;
         -- Start bit.

         -- This state must be included because the device might possibly
         -- delay for up to 10 milliseconds before beginning its clock pulses.
         -- During that waiting time, we cannot drive the data (q[0]) because it
         -- is possibly 1, which would cause the keyboard to abort its receive
         -- and the expected clocks would then never be generated.
         WHEN m1_tx_first_wait_clk_h =>
            enable_timer_5usec <= '1';
            ps2_data_hi_z <= '0';
            IF (ps2_clk_s='0' AND timer_5usec_done='1') THEN
               m1_next_state <= m1_tx_clk_l;
            ELSE
               m1_next_state <= m1_tx_first_wait_clk_h;
            END IF;

         WHEN m1_tx_first_wait_clk_l =>
            ps2_data_hi_z <= '0';
            IF (ps2_clk_s = '0') THEN
               m1_next_state <= m1_tx_clk_l;
            ELSE
               m1_next_state <= m1_tx_first_wait_clk_l;
            END IF;

         WHEN m1_tx_wait_clk_h =>
            enable_timer_5usec <= '1';
            ps2_data_hi_z <= q(0);
            IF (ps2_clk_s='1' AND timer_5usec_done='1') THEN
               m1_next_state <= m1_tx_rising_edge_marker;
            ELSE
               m1_next_state <= m1_tx_wait_clk_h;
            END IF;

         WHEN m1_tx_rising_edge_marker =>
            ps2_data_hi_z <= q(0);
            m1_next_state <= m1_tx_clk_h;

         WHEN m1_tx_clk_h =>
            ps2_data_hi_z <= q(0);
            IF (tx_shifting_done = '1') THEN
               m1_next_state <= m1_tx_wait_keyboard_ack;
            ELSIF ((NOT(ps2_clk_s)) = '1') THEN
               m1_next_state <= m1_tx_clk_l;
            ELSE
               m1_next_state <= m1_tx_clk_h;
            END IF;

         WHEN m1_tx_clk_l =>
            ps2_data_hi_z <= q(0);
            IF (ps2_clk_s = '1') THEN
               m1_next_state <= m1_tx_wait_clk_h;
            ELSE
               m1_next_state <= m1_tx_clk_l;
            END IF;

         WHEN m1_tx_wait_keyboard_ack =>
            IF (ps2_clk_s='0' AND ps2_data_s='1') THEN
               m1_next_state <= m1_tx_error_no_keyboard_ack;
            ELSIF (ps2_clk_s='0' AND ps2_data_s='0') THEN
               m1_next_state <= m1_tx_done_recovery;
            ELSE
               m1_next_state <= m1_tx_wait_keyboard_ack;
            END IF;

         WHEN m1_tx_done_recovery =>
            IF (ps2_clk_s='1' AND ps2_data_s='1') THEN
               m1_next_state <= m1_rx_clk_h;
            ELSE
               m1_next_state <= m1_tx_done_recovery;
            END IF;

         WHEN m1_tx_error_no_keyboard_ack =>
            tx_error_no_keyboard_ack <= '1';
            IF (ps2_clk_s='1' AND ps2_data_s='1') THEN
               m1_next_state <= m1_rx_clk_h;
            ELSE
               m1_next_state <= m1_tx_error_no_keyboard_ack;
            END IF;
         WHEN OTHERS =>
            m1_next_state <= m1_rx_clk_h;
      END CASE;
   END PROCESS;


   -- State register
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset = '1') THEN
            m2_state <= m2_rx_data_ready_ack;
         ELSE
            m2_state <= m2_next_state;
         END IF;
      END IF;
   END PROCESS;


   -- State transition logic
   PROCESS (m2_state, rx_output_strobe, rx_read)
   BEGIN
      CASE m2_state IS
         WHEN m2_rx_data_ready_ack =>
            rx_data_ready <= '0';
            IF (rx_output_strobe = '1') THEN
               m2_next_state <= m2_rx_data_ready;
            ELSE
               m2_next_state <= m2_rx_data_ready_ack;
            END IF;
         WHEN m2_rx_data_ready =>
            rx_data_ready <= '1';
            IF (rx_read = '1') THEN
               m2_next_state <= m2_rx_data_ready_ack;
            ELSE
               m2_next_state <= m2_rx_data_ready;
            END IF;
         WHEN OTHERS =>
            m2_next_state <= m2_rx_data_ready_ack;
      END CASE;
   END PROCESS;


   -- This is the bit counter
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset='1' OR rx_shifting_done='1' OR (m1_state = m1_tx_wait_keyboard_ack)) THEN        -- After tx is done.
            bit_count <= "0000";
         ELSIF (timer_60usec_done = '1' AND (m1_state = m1_rx_clk_h) AND ((ps2_clk_s)) = '1') THEN        -- rx watchdog timer reset
            bit_count <= "0000";
         ELSIF ((m1_state = m1_rx_falling_edge_marker) OR (m1_state = m1_tx_rising_edge_marker)) THEN        -- increment for tx
            bit_count <= bit_count + "0001";
         END IF;
      END IF;
   END PROCESS;

   -- This signal is high for one clock at the end of the timer count.
   rx_shifting_done <= to_stdlogic((bit_count = "1011"));
   tx_shifting_done <= to_stdlogic((bit_count = "1010"));

   -- This is the signal which enables loading of the shift register.
   -- It also indicates "ack" to the device writing to the transmitter.
   tx_write_ack_o_xhdl1 <= to_stdlogic(((tx_write = '1' AND (m1_state = m1_rx_clk_h)) OR (tx_write = '1' AND (m1_state = m1_rx_clk_l))));

   -- This is the ODD parity bit for the transmitted word.
   tx_parity_bit <= XNOR_BR(tx_data);

   -- This is the shift register
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset = '1') THEN
            q <= "00000000000";
         ELSIF (tx_write_ack_o_xhdl1 = '1') THEN
            q <= ('1' & tx_parity_bit & tx_data & '0');
         ELSIF ((m1_state = m1_rx_falling_edge_marker) OR (m1_state = m1_tx_rising_edge_marker)) THEN
            q <= (ps2_data_s & q(11 - 1 DOWNTO 1));
         END IF;
      END IF;
   END PROCESS;


   -- This is the 60usec timer counter
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF ((NOT(enable_timer_60usec)) = '1') THEN
            timer_60usec_count <= "000000000000";
         ELSIF ((NOT(timer_60usec_done)) = '1') THEN
            timer_60usec_count <= timer_60usec_count + "000000000001";
         END IF;
      END IF;
   END PROCESS;

   timer_60usec_done <= to_stdlogic(timer_60usec_count = (TIMER_60USEC_VALUE_PP - 1));

   -- This is the 5usec timer counter
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF ((NOT(enable_timer_5usec)) = '1') THEN
            timer_5usec_count <= "00000000";
         ELSIF ((NOT(timer_5usec_done)) = '1') THEN
            timer_5usec_count <= timer_5usec_count + "00000001";
         END IF;
      END IF;
   END PROCESS;

   timer_5usec_done <= to_stdlogic(timer_5usec_count = (TIMER_5USEC_VALUE_PP - 1));

   -- Create the signals which indicate special scan codes received.
   -- These are the "unlatched versions."
   extended <= to_stdlogic((("00000000" & q(8 DOWNTO 1)) = "0000000011100000") AND rx_shifting_done = '1');
   released <= to_stdlogic((("00000000" & q(8 DOWNTO 1)) = "0000000011110000") AND rx_shifting_done = '1');

   -- Store the special scan code status bits
   -- Not the final output, but an intermediate storage place,
   -- until the entire set of output data can be assembled.
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset='1' OR rx_output_event='1') THEN
            hold_extended <= '0';
            hold_released <= '0';
         ELSE
            IF (rx_shifting_done='1' AND extended='1') THEN
               hold_extended <= '1';
            END IF;
            IF (rx_shifting_done='1' AND released='1') THEN
               hold_released <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;


   -- These bits contain the status of the two shift keys
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset = '1') THEN
            left_shift_key <= '0';
         ELSIF ((("00000000" & q(8 DOWNTO 1)) = "0000000000010010") AND rx_shifting_done = '1' AND (NOT(hold_released)) = '1') THEN
            left_shift_key <= '1';
         ELSIF ((("00000000" & q(8 DOWNTO 1)) = "0000000000010010") AND rx_shifting_done = '1' AND hold_released = '1') THEN
            left_shift_key <= '0';
         END IF;
      END IF;
   END PROCESS;


   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset = '1') THEN
            right_shift_key <= '0';
         ELSIF ((("00000000" & q(8 DOWNTO 1)) = "0000000001011001") AND rx_shifting_done = '1' AND (NOT(hold_released)) = '1') THEN
            right_shift_key <= '1';
         ELSIF ((("00000000" & q(8 DOWNTO 1)) = "0000000001011001") AND rx_shifting_done = '1' AND hold_released = '1') THEN
            right_shift_key <= '0';
         END IF;
      END IF;
   END PROCESS;


   rx_shift_key_on_xhdl0 <= to_stdlogic(left_shift_key='1' OR right_shift_key='1');

   -- Output the special scan code flags, the scan code and the ascii
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (reset = '1') THEN
            rx_extended <= '0';
            rx_released <= '0';
            rx_scan_code <= "00000000";
            rx_ascii <= "00000000";
         ELSIF (rx_output_strobe = '1') THEN
            rx_extended <= hold_extended;
            rx_released <= hold_released;
            rx_scan_code <= q(8 DOWNTO 1);
            rx_ascii <= ascii;
         END IF;
      END IF;
   END PROCESS;


   -- Store the final rx output data only when all extend and release codes
   -- are received and the next (actual key) scan code is also ready.
   -- (the presence of rx_extended or rx_released refers to the
   -- the current latest scan code received, not the previously latched flags.)
   rx_output_event <= to_stdlogic((rx_shifting_done='1' AND extended='0' AND released='0'));

   rx_output_strobe <= to_stdlogic((rx_shifting_done='1' AND extended='0' AND released='0' AND ((TRAP_SHIFT_KEYS_PP = 0) OR ((("00000000" & q(8 DOWNTO 1)) /= "0000000001011001") AND (("00000000" & q(8 DOWNTO 1)) /= "0000000000010010")))));

   -- This part translates the scan code into an ASCII value...
   -- Only the ASCII codes which I considered important have been included.
   -- if you want more, just add the appropriate case statement lines...
   -- (You will need to know the keyboard scan codes you wish to assign.)
   -- The entries are listed in ascending order of ASCII value.
   shift_key_plus_code <= ("000" & rx_shift_key_on_xhdl0 & q(8 DOWNTO 1));
   PROCESS (shift_key_plus_code)
   BEGIN
      CASE shift_key_plus_code IS
         WHEN x"066" => ascii <= x"08";  -- Backspace ("backspace" key)
         WHEN x"00d" => ascii <= x"09";  -- Horizontal Tab
         WHEN x"05a" => ascii <= x"0d";  -- Carriage return ("enter" key)
         WHEN x"076" => ascii <= x"1b";  -- Escape ("esc" key)
         WHEN x"029" => ascii <= x"20";  -- Space
         WHEN x"116" => ascii <= x"21";  -- !
         WHEN x"152" => ascii <= x"22";  -- "
         WHEN x"126" => ascii <= x"23";  -- #
         WHEN x"125" => ascii <= x"24";  -- $
         WHEN x"12e" => ascii <= x"25";  -- %
         WHEN x"13d" => ascii <= x"26";  -- &
         WHEN x"052" => ascii <= x"27";  -- '
         WHEN x"146" => ascii <= x"28";  -- (
         WHEN x"145" => ascii <= x"29";  -- )
         WHEN x"13e" => ascii <= x"2a";  -- *
         WHEN x"155" => ascii <= x"2b";  -- +
         WHEN x"041" => ascii <= x"2c";  -- ,
         WHEN x"04e" => ascii <= x"2d";  -- -
         WHEN x"049" => ascii <= x"2e";  -- .
         WHEN x"04a" => ascii <= x"2f";  -- /
         WHEN x"045" => ascii <= x"30";  -- 0
         WHEN x"016" => ascii <= x"31";  -- 1
         WHEN x"01e" => ascii <= x"32";  -- 2
         WHEN x"026" => ascii <= x"33";  -- 3
         WHEN x"025" => ascii <= x"34";  -- 4
         WHEN x"02e" => ascii <= x"35";  -- 5
         WHEN x"036" => ascii <= x"36";  -- 6
         WHEN x"03d" => ascii <= x"37";  -- 7
         WHEN x"03e" => ascii <= x"38";  -- 8
         WHEN x"046" => ascii <= x"39";  -- 9
         WHEN x"14c" => ascii <= x"3a";  -- :
         WHEN x"04c" => ascii <= x"3b";  -- ;
         WHEN x"141" => ascii <= x"3c";  -- <
         WHEN x"055" => ascii <= x"3d";  -- =
         WHEN x"149" => ascii <= x"3e";  -- >
         WHEN x"14a" => ascii <= x"3f";  -- ?
         WHEN x"11e" => ascii <= x"40";  -- @
         WHEN x"11c" => ascii <= x"41";  -- A
         WHEN x"132" => ascii <= x"42";  -- B
         WHEN x"121" => ascii <= x"43";  -- C
         WHEN x"123" => ascii <= x"44";  -- D
         WHEN x"124" => ascii <= x"45";  -- E
         WHEN x"12b" => ascii <= x"46";  -- F
         WHEN x"134" => ascii <= x"47";  -- G
         WHEN x"133" => ascii <= x"48";  -- H
         WHEN x"143" => ascii <= x"49";  -- I
         WHEN x"13b" => ascii <= x"4a";  -- J
         WHEN x"142" => ascii <= x"4b";  -- K
         WHEN x"14b" => ascii <= x"4c";  -- L
         WHEN x"13a" => ascii <= x"4d";  -- M
         WHEN x"131" => ascii <= x"4e";  -- N
         WHEN x"144" => ascii <= x"4f";  -- O
         WHEN x"14d" => ascii <= x"50";  -- P
         WHEN x"115" => ascii <= x"51";  -- Q
         WHEN x"12d" => ascii <= x"52";  -- R
         WHEN x"11b" => ascii <= x"53";  -- S
         WHEN x"12c" => ascii <= x"54";  -- T
         WHEN x"13c" => ascii <= x"55";  -- U
         WHEN x"12a" => ascii <= x"56";  -- V
         WHEN x"11d" => ascii <= x"57";  -- W
         WHEN x"122" => ascii <= x"58";  -- X
         WHEN x"135" => ascii <= x"59";  -- Y
         WHEN x"11a" => ascii <= x"5a";  -- Z
         WHEN x"054" => ascii <= x"5b";  -- [
         WHEN x"05d" => ascii <= x"5c";  -- \
         WHEN x"05b" => ascii <= x"5d";  -- ]
         WHEN x"136" => ascii <= x"5e";  -- ^
         WHEN x"14e" => ascii <= x"5f";  -- _
         WHEN x"00e" => ascii <= x"60";  -- `
         WHEN x"01c" => ascii <= x"61";  -- a
         WHEN x"032" => ascii <= x"62";  -- b
         WHEN x"021" => ascii <= x"63";  -- c
         WHEN x"023" => ascii <= x"64";  -- d
         WHEN x"024" => ascii <= x"65";  -- e
         WHEN x"02b" => ascii <= x"66";  -- f
         WHEN x"034" => ascii <= x"67";  -- g
         WHEN x"033" => ascii <= x"68";  -- h
         WHEN x"043" => ascii <= x"69";  -- i
         WHEN x"03b" => ascii <= x"6a";  -- j
         WHEN x"042" => ascii <= x"6b";  -- k
         WHEN x"04b" => ascii <= x"6c";  -- l
         WHEN x"03a" => ascii <= x"6d";  -- m
         WHEN x"031" => ascii <= x"6e";  -- n
         WHEN x"044" => ascii <= x"6f";  -- o
         WHEN x"04d" => ascii <= x"70";  -- p
         WHEN x"015" => ascii <= x"71";  -- q
         WHEN x"02d" => ascii <= x"72";  -- r
         WHEN x"01b" => ascii <= x"73";  -- s
         WHEN x"02c" => ascii <= x"74";  -- t
         WHEN x"03c" => ascii <= x"75";  -- u
         WHEN x"02a" => ascii <= x"76";  -- v
         WHEN x"01d" => ascii <= x"77";  -- w
         WHEN x"022" => ascii <= x"78";  -- x
         WHEN x"035" => ascii <= x"79";  -- y
         WHEN x"01a" => ascii <= x"7a";  -- z
         WHEN x"154" => ascii <= x"7b";  -- {
         WHEN x"15d" => ascii <= x"7c";  -- |
         WHEN x"15b" => ascii <= x"7d";  -- }
         WHEN x"10e" => ascii <= x"7e";  -- ~
         WHEN x"071" => ascii <= x"7f";  -- (Delete OR DEL on numeric keypad)
            --extras
         WHEN x"005" => ascii <= x"81";  -- f1
         WHEN x"006" => ascii <= x"82";  -- f2
         WHEN x"004" => ascii <= x"83";  -- f3
         WHEN x"00c" => ascii <= x"84";  -- f4
         WHEN x"003" => ascii <= x"85";  -- f5
         WHEN x"00b" => ascii <= x"86";  -- f6
         WHEN x"083" => ascii <= x"87";  -- f7
         WHEN x"00a" => ascii <= x"88";  -- f8
         WHEN x"001" => ascii <= x"89";  -- f9
         WHEN x"009" => ascii <= x"8a";  -- f10
         WHEN x"078" => ascii <= x"8b";  -- f11
         WHEN x"007" => ascii <= x"8c";  -- f12

         WHEN x"075" => ascii <= x"90";  -- KP UP
         WHEN x"072" => ascii <= x"91";  -- KP DOWN
         WHEN x"06B" => ascii <= x"92";  -- KP LEFT
         WHEN x"074" => ascii <= x"93";  -- KP RIGHT

         WHEN OTHERS => ascii <= "00000000";
      END CASE;
   END PROCESS;


END ARCHITECTURE trans;



