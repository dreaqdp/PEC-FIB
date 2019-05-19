library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity keyboard_controller is
    Port (clk        : in    STD_LOGIC;
          reset      : in    STD_LOGIC;
          ps2_clk    : inout STD_LOGIC;
          ps2_data   : inout STD_LOGIC;
          read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
          clear_char : in    STD_LOGIC;
          data_ready : out   STD_LOGIC);
end keyboard_controller;

architecture Behavioral of keyboard_controller is

component ps2_keyboard_interface is
    port (clk             : in  STD_LOGIC;
          reset           : in  STD_LOGIC;
          ps2_clk         : inout  STD_LOGIC;
          ps2_data        : inout  STD_LOGIC;
          rx_extended     : out  STD_LOGIC; -- a extended key has been pressed
          rx_released     : out  STD_LOGIC; -- a key has been released
          rx_shift_key_on : out  STD_LOGIC; --the shift key is pressed
          rx_scan_code    : out  STD_LOGIC_VECTOR (7 downto 0); --scan code of the last pressed/released key
          rx_ascii        : out  STD_LOGIC_VECTOR (7 downto 0); -- ascii code of the last pressed/released key
          rx_data_ready   : out  STD_LOGIC;       -- there is a new key pressed (guess it can be used as interrupt signal)
          rx_read         : in  STD_LOGIC;        -- ack of data_ready. The data has been read (clear the rx_data_ready signal)
          tx_data         : in  STD_LOGIC_VECTOR (7 downto 0); --data to the keyboard
          tx_write        : in  STD_LOGIC;                     -- write the data to the keyboard
          tx_write_ack_o  : out  STD_LOGIC;
          tx_error_no_keyboard_ack : out  STD_LOGIC);
end component;

	--commands to keyboard list: http://www.win.tue.nl/~aeb/linux/kbd/scancodes-12.html#kced

    signal rx_extended : STD_LOGIC;
    signal rx_released : STD_LOGIC;
    signal rx_shift_key_on : STD_LOGIC;
    signal rx_data_ready : STD_LOGIC;
    signal rx_read : STD_LOGIC;
    signal tx_write_ack_o : STD_LOGIC;
    signal tx_error_no_keyboard_ack : STD_LOGIC;

    signal rx_scan_code : STD_LOGIC_VECTOR (7 downto 0);
    signal rx_ascii : STD_LOGIC_VECTOR (7 downto 0);
    signal data_ready_we : STD_LOGIC;
    signal data_available : STD_LOGIC;

    type state_type is (idle, clearing);
    signal state   : state_type;

begin

    k0 : ps2_keyboard_interface port map(
                clk => clk,
                reset => reset,
                ps2_clk => ps2_clk,
                ps2_data => ps2_data,
                rx_extended => rx_extended,
                rx_released => rx_released,
                rx_shift_key_on => rx_shift_key_on,
                rx_scan_code => rx_scan_code,
                rx_ascii => rx_ascii,
                rx_data_ready => rx_data_ready,
                rx_read => rx_read, ---
                tx_data => "00000000",
                tx_write => '0',
                tx_write_ack_o => tx_write_ack_o,
                tx_error_no_keyboard_ack => tx_error_no_keyboard_ack
       );


    process (clk) begin
        if (clk'event and clk = '1') then
            if (reset = '1') then
                state <= idle;
            else
                case state is
                    when idle =>
                        if (clear_char = '1') then
                            state <= clearing;
                        end if;
                    when clearing =>
                        if (rx_data_ready = '0') then
                            state <= idle;
                        end if;
                end case;

            end if;
        end if;
    end process;

    process (state) begin
        data_ready_we <= '0';
        case state is
            when idle =>
                if (rx_data_ready = '1' and rx_released = '0') then
                    if (rx_shift_key_on /= '1' or rx_ascii /= "00000000") then
                        data_available <= '1';
                        data_ready_we <= '1';
                    end if;
                end if;
                rx_read <= '0';
            when clearing =>
                rx_read <= '1';
                data_available <= '0';
                data_ready_we <= '1';
        end case;
    end process;

    process (clk) begin
        if (clk'event and clk = '1') then
            data_ready <= '0';
            if (data_ready_we = '1') then
                data_ready <= data_available;
                if (data_available = '1') then
                    read_char <= rx_ascii;
                end if;
            end if;
        end if;
    end process;


end Behavioral;

