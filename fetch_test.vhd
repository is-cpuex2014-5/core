-- Fetch.vhd
-- Read code from SRAM (Not yet)
-- send back to core.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fetch is
  Port (
    clk : in std_logic;
    load_signal : in std_logic := '0';
    pc : in std_logic_vector(31 downto 0);
    inst_sram_request : out std_logic;
    inst_sram_addr : out std_logic_vector(19 downto 0);
    inst_sram_getvalue : in std_logic_vector(31 downto 0);
    inst_sram_request_finished : in std_logic;
    inst_fetched : in std_logic;
    inst : out std_logic_vector(31 downto 0);
    waitwrite : in std_logic_vector(19 downto 0)
  );
end fetch;

architecture fetch_test of fetch is
begin
  fetch_main: process(clk)
  begin
    if rising_edge(clk) then
      if load_signal = '1' then
        if waitwrite = 0 then
--if pc = 0 then
--    inst <= x"02800009";
--	inst <= x"820004E8";
--end if;
--if pc = 4 then
--    inst <= x"58280000";
--	inst <= x"00000000";
--end if;
--if pc = 8 then
--    inst <= x"8001E000";
--	inst <= x"3F800000";
--end if;
--if pc = 12 then
--    inst <= x"8001E000";
--	inst <= x"3FC00000";
--end if;
if pc = 0 then
	inst <= x"02217545";
end if;
if pc = 4 then
	inst <= x"0220525D";
end if;
if pc = 8 then
	inst <= x"02417545";
end if;
if pc = 12 then
	inst <= x"0240525D";
end if;
if pc = 16 then
	inst <= x"886200E0";
end if;
if pc = 20 then
	inst <= x"80640008";
end if;
if pc = 24 then
	inst <= x"8001E000";
end if;
if pc = 28 then
	inst <= x"02217545";
end if;
if pc = 32 then
	inst <= x"0220525D";
end if;
if pc = 36 then
	inst <= x"0241BAA2";
end if;
if pc = 40 then
	inst <= x"0240A92E";
end if;
if pc = 44 then
	inst <= x"886201E0";
end if;
if pc = 48 then
	inst <= x"80640008";
end if;
if pc = 52 then
	inst <= x"8001E000";
end if;
if pc = 56 then
	inst <= x"02217545";
end if;
if pc = 60 then
	inst <= x"0220525D";
end if;
if pc = 64 then
	inst <= x"02415D51";
end if;
if pc = 68 then
	inst <= x"02405497";
end if;
if pc = 72 then
	inst <= x"886202E0";
end if;
if pc = 76 then
	inst <= x"80640008";
end if;
if pc = 80 then
	inst <= x"8001E000";
end if;
if pc = 84 then
	inst <= x"02217545";
end if;
if pc = 88 then
	inst <= x"0220525D";
end if;
if pc = 92 then
	inst <= x"0241AEA8";
end if;
if pc = 96 then
	inst <= x"0240AA4B";
end if;
if pc = 100 then
	inst <= x"886203E0";
end if;
if pc = 104 then
	inst <= x"80640008";
end if;
if pc = 108 then
	inst <= x"8001E000";
end if;
if pc = 112 then
	inst <= x"02217545";
end if;
if pc = 116 then
	inst <= x"0220525D";
end if;
if pc = 120 then
	inst <= x"0241D754";
end if;
if pc = 124 then
	inst <= x"02405525";
end if;
if pc = 128 then
	inst <= x"886204E0";
end if;
if pc = 132 then
	inst <= x"80640008";
end if;
if pc = 136 then
	inst <= x"8001E000";
end if;
if pc = 140 then
	inst <= x"02217545";
end if;
if pc = 144 then
	inst <= x"0220525D";
end if;
if pc = 148 then
	inst <= x"0241EBAA";
end if;
if pc = 152 then
	inst <= x"02402A92";
end if;
if pc = 156 then
	inst <= x"886205E0";
end if;
if pc = 160 then
	inst <= x"80640008";
end if;
if pc = 164 then
	inst <= x"8001E000";
end if;
if pc = 168 then
	inst <= x"02217545";
end if;
if pc = 172 then
	inst <= x"0220525D";
end if;
if pc = 176 then
	inst <= x"024175D5";
end if;
if pc = 180 then
	inst <= x"02401549";
end if;
if pc = 184 then
	inst <= x"886206E0";
end if;
if pc = 188 then
	inst <= x"80640008";
end if;
if pc = 192 then
	inst <= x"8001E000";
end if;
if pc = 196 then
	inst <= x"02217545";
end if;
if pc = 200 then
	inst <= x"0220525D";
end if;
if pc = 204 then
	inst <= x"0241BAEA";
end if;
if pc = 208 then
	inst <= x"02408AA4";
end if;
if pc = 212 then
	inst <= x"886207E0";
end if;
if pc = 216 then
	inst <= x"80640008";
end if;
if pc = 220 then
	inst <= x"8001E000";
end if;
if pc = 224 then
	inst <= x"02217545";
end if;
if pc = 228 then
	inst <= x"0220525D";
end if;
if pc = 232 then
	inst <= x"02415D75";
end if;
if pc = 236 then
	inst <= x"02404552";
end if;
if pc = 240 then
	inst <= x"886208E0";
end if;
if pc = 244 then
	inst <= x"80640008";
end if;
if pc = 248 then
	inst <= x"8001E000";
end if;
if pc = 252 then
	inst <= x"02217545";
end if;
if pc = 256 then
	inst <= x"0220525D";
end if;
if pc = 260 then
	inst <= x"02412EBA";
end if;
if pc = 264 then
	inst <= x"0240A2A9";
end if;
if pc = 268 then
	inst <= x"886209E0";
end if;
if pc = 272 then
	inst <= x"80640008";
end if;
if pc = 276 then
	inst <= x"8001E000";
end if;
if pc = 280 then
	inst <= x"02217545";
end if;
if pc = 284 then
	inst <= x"0220525D";
end if;
if pc = 288 then
	inst <= x"0241975D";
end if;
if pc = 292 then
	inst <= x"02405154";
end if;
if pc = 296 then
	inst <= x"88620AE0";
end if;
if pc = 300 then
	inst <= x"80640008";
end if;
if pc = 304 then
	inst <= x"8001E000";
end if;
if pc = 308 then
	inst <= x"02217545";
end if;
if pc = 312 then
	inst <= x"0220525D";
end if;
if pc = 316 then
	inst <= x"02414BAE";
end if;
if pc = 320 then
	inst <= x"0240A8AA";
end if;
if pc = 324 then
	inst <= x"88620BE0";
end if;
if pc = 328 then
	inst <= x"80640008";
end if;
if pc = 332 then
	inst <= x"8001E000";
end if;
if pc = 336 then
	inst <= x"02217545";
end if;
if pc = 340 then
	inst <= x"0220525D";
end if;
if pc = 344 then
	inst <= x"024125D7";
end if;
if pc = 348 then
	inst <= x"02405455";
end if;
if pc = 352 then
	inst <= x"88620CE0";
end if;
if pc = 356 then
	inst <= x"80640008";
end if;
if pc = 360 then
	inst <= x"8001E000";
end if;
if pc = 364 then
	inst <= x"02217545";
end if;
if pc = 368 then
	inst <= x"0220525D";
end if;
if pc = 372 then
	inst <= x"024192EB";
end if;
if pc = 376 then
	inst <= x"0240AA2A";
end if;
if pc = 380 then
	inst <= x"88620DE0";
end if;
if pc = 384 then
	inst <= x"80640008";
end if;
if pc = 388 then
	inst <= x"8001E000";
end if;
if pc = 392 then
	inst <= x"02217545";
end if;
if pc = 396 then
	inst <= x"0220525D";
end if;
if pc = 400 then
	inst <= x"02414975";
end if;
if pc = 404 then
	inst <= x"0240D515";
end if;
if pc = 408 then
	inst <= x"88620EE0";
end if;
if pc = 412 then
	inst <= x"80640008";
end if;
if pc = 416 then
	inst <= x"8001E000";
end if;
if pc = 420 then
	inst <= x"02217545";
end if;
if pc = 424 then
	inst <= x"0220525D";
end if;
if pc = 428 then
	inst <= x"0241A4BA";
end if;
if pc = 432 then
	inst <= x"0240EA8A";
end if;
if pc = 436 then
	inst <= x"88620FE0";
end if;
if pc = 440 then
	inst <= x"80640008";
end if;
if pc = 444 then
	inst <= x"8001E000";
end if;
if pc = 448 then
	inst <= x"02217545";
end if;
if pc = 452 then
	inst <= x"0220525D";
end if;
if pc = 456 then
	inst <= x"0241525D";
end if;
if pc = 460 then
	inst <= x"02407545";
end if;
if pc = 464 then
	inst <= x"886210E0";
end if;
if pc = 468 then
	inst <= x"80640008";
end if;
if pc = 472 then
	inst <= x"8001E000";
end if;
if pc = 476 then
	inst <= x"02217545";
end if;
if pc = 480 then
	inst <= x"0220525D";
end if;
if pc = 484 then
	inst <= x"0241A92E";
end if;
if pc = 488 then
	inst <= x"0240BAA2";
end if;
if pc = 492 then
	inst <= x"886211E0";
end if;
if pc = 496 then
	inst <= x"80640008";
end if;
if pc = 500 then
	inst <= x"8001E000";
end if;
if pc = 504 then
	inst <= x"02217545";
end if;
if pc = 508 then
	inst <= x"0220525D";
end if;
if pc = 512 then
	inst <= x"02415497";
end if;
if pc = 516 then
	inst <= x"02405D51";
end if;
if pc = 520 then
	inst <= x"886212E0";
end if;
if pc = 524 then
	inst <= x"80640008";
end if;
if pc = 528 then
	inst <= x"8001E000";
end if;
if pc = 532 then
	inst <= x"02217545";
end if;
if pc = 536 then
	inst <= x"0220525D";
end if;
if pc = 540 then
	inst <= x"0241AA4B";
end if;
if pc = 544 then
	inst <= x"0240AEA8";
end if;
if pc = 548 then
	inst <= x"886213E0";
end if;
if pc = 552 then
	inst <= x"80640008";
end if;
if pc = 556 then
	inst <= x"8001E000";
end if;
if pc = 560 then
	inst <= x"02217545";
end if;
if pc = 564 then
	inst <= x"0220525D";
end if;
if pc = 568 then
	inst <= x"02415525";
end if;
if pc = 572 then
	inst <= x"0240D754";
end if;
if pc = 576 then
	inst <= x"886214E0";
end if;
if pc = 580 then
	inst <= x"80640008";
end if;
if pc = 584 then
	inst <= x"8001E000";
end if;
if pc = 588 then
	inst <= x"02217545";
end if;
if pc = 592 then
	inst <= x"0220525D";
end if;
if pc = 596 then
	inst <= x"02412A92";
end if;
if pc = 600 then
	inst <= x"0240EBAA";
end if;
if pc = 604 then
	inst <= x"886215E0";
end if;
if pc = 608 then
	inst <= x"80640008";
end if;
if pc = 612 then
	inst <= x"8001E000";
end if;
if pc = 616 then
	inst <= x"02217545";
end if;
if pc = 620 then
	inst <= x"0220525D";
end if;
if pc = 624 then
	inst <= x"02411549";
end if;
if pc = 628 then
	inst <= x"024075D5";
end if;
if pc = 632 then
	inst <= x"886216E0";
end if;
if pc = 636 then
	inst <= x"80640008";
end if;
if pc = 640 then
	inst <= x"8001E000";
end if;
if pc = 644 then
	inst <= x"02217545";
end if;
if pc = 648 then
	inst <= x"0220525D";
end if;
if pc = 652 then
	inst <= x"02418AA4";
end if;
if pc = 656 then
	inst <= x"0240BAEA";
end if;
if pc = 660 then
	inst <= x"886217E0";
end if;
if pc = 664 then
	inst <= x"80640008";
end if;
if pc = 668 then
	inst <= x"8001E000";
end if;
if pc = 672 then
	inst <= x"02217545";
end if;
if pc = 676 then
	inst <= x"0220525D";
end if;
if pc = 680 then
	inst <= x"02414552";
end if;
if pc = 684 then
	inst <= x"02405D75";
end if;
if pc = 688 then
	inst <= x"886218E0";
end if;
if pc = 692 then
	inst <= x"80640008";
end if;
if pc = 696 then
	inst <= x"8001E000";
end if;
if pc = 700 then
	inst <= x"02217545";
end if;
if pc = 704 then
	inst <= x"0220525D";
end if;
if pc = 708 then
	inst <= x"0241A2A9";
end if;
if pc = 712 then
	inst <= x"02402EBA";
end if;
if pc = 716 then
	inst <= x"886219E0";
end if;
if pc = 720 then
	inst <= x"80640008";
end if;
if pc = 724 then
	inst <= x"8001E000";
end if;
if pc = 728 then
	inst <= x"02217545";
end if;
if pc = 732 then
	inst <= x"0220525D";
end if;
if pc = 736 then
	inst <= x"02415154";
end if;
if pc = 740 then
	inst <= x"0240975D";
end if;
if pc = 744 then
	inst <= x"88621AE0";
end if;
if pc = 748 then
	inst <= x"80640008";
end if;
if pc = 752 then
	inst <= x"8001E000";
end if;
if pc = 756 then
	inst <= x"02217545";
end if;
if pc = 760 then
	inst <= x"0220525D";
end if;
if pc = 764 then
	inst <= x"0241A8AA";
end if;
if pc = 768 then
	inst <= x"02404BAE";
end if;
if pc = 772 then
	inst <= x"88621BE0";
end if;
if pc = 776 then
	inst <= x"80640008";
end if;
if pc = 780 then
	inst <= x"8001E000";
end if;
if pc = 784 then
	inst <= x"02217545";
end if;
if pc = 788 then
	inst <= x"0220525D";
end if;
if pc = 792 then
	inst <= x"02415455";
end if;
if pc = 796 then
	inst <= x"024025D7";
end if;
if pc = 800 then
	inst <= x"88621CE0";
end if;
if pc = 804 then
	inst <= x"80640008";
end if;
if pc = 808 then
	inst <= x"8001E000";
end if;
if pc = 812 then
	inst <= x"02217545";
end if;
if pc = 816 then
	inst <= x"0220525D";
end if;
if pc = 820 then
	inst <= x"0241AA2A";
end if;
if pc = 824 then
	inst <= x"024092EB";
end if;
if pc = 828 then
	inst <= x"88621DE0";
end if;
if pc = 832 then
	inst <= x"80640008";
end if;
if pc = 836 then
	inst <= x"8001E000";
end if;
if pc = 840 then
	inst <= x"02217545";
end if;
if pc = 844 then
	inst <= x"0220525D";
end if;
if pc = 848 then
	inst <= x"0241D515";
end if;
if pc = 852 then
	inst <= x"02404975";
end if;
if pc = 856 then
	inst <= x"88621EE0";
end if;
if pc = 860 then
	inst <= x"80640008";
end if;
if pc = 864 then
	inst <= x"8001E000";
end if;
if pc = 868 then
	inst <= x"02217545";
end if;
if pc = 872 then
	inst <= x"0220525D";
end if;
if pc = 876 then
	inst <= x"0241EA8A";
end if;
if pc = 880 then
	inst <= x"0240A4BA";
end if;
if pc = 884 then
	inst <= x"88621FE0";
end if;
if pc = 888 then
	inst <= x"80640008";
end if;
if pc = 892 then
	inst <= x"8001E000";
end if;
if pc = 896 then
	inst <= x"02217545";
end if;
if pc = 900 then
	inst <= x"0220525D";
end if;
if pc = 904 then
	inst <= x"02417545";
end if;
if pc = 908 then
	inst <= x"0240525D";
end if;
if pc = 912 then
	inst <= x"88620060";
end if;
if pc = 916 then
	inst <= x"80640008";
end if;
if pc = 920 then
	inst <= x"8001E000";
end if;
if pc = 924 then
	inst <= x"02217545";
end if;
if pc = 928 then
	inst <= x"0220525D";
end if;
if pc = 932 then
	inst <= x"0241EA8A";
end if;
if pc = 936 then
	inst <= x"0240A4BA";
end if;
if pc = 940 then
	inst <= x"88620160";
end if;
if pc = 944 then
	inst <= x"80640008";
end if;
if pc = 948 then
	inst <= x"8001E000";
end if;
if pc = 952 then
	inst <= x"02217545";
end if;
if pc = 956 then
	inst <= x"0220525D";
end if;
if pc = 960 then
	inst <= x"0241D515";
end if;
if pc = 964 then
	inst <= x"02404975";
end if;
if pc = 968 then
	inst <= x"88620260";
end if;
if pc = 972 then
	inst <= x"80640008";
end if;
if pc = 976 then
	inst <= x"8001E000";
end if;
if pc = 980 then
	inst <= x"02217545";
end if;
if pc = 984 then
	inst <= x"0220525D";
end if;
if pc = 988 then
	inst <= x"0241AA2A";
end if;
if pc = 992 then
	inst <= x"024092EB";
end if;
if pc = 996 then
	inst <= x"88620360";
end if;
if pc = 1000 then
	inst <= x"80640008";
end if;
if pc = 1004 then
	inst <= x"8001E000";
end if;
if pc = 1008 then
	inst <= x"02217545";
end if;
if pc = 1012 then
	inst <= x"0220525D";
end if;
if pc = 1016 then
	inst <= x"02415455";
end if;
if pc = 1020 then
	inst <= x"024025D7";
end if;
if pc = 1024 then
	inst <= x"88620460";
end if;
if pc = 1028 then
	inst <= x"80640008";
end if;
if pc = 1032 then
	inst <= x"8001E000";
end if;
if pc = 1036 then
	inst <= x"02217545";
end if;
if pc = 1040 then
	inst <= x"0220525D";
end if;
if pc = 1044 then
	inst <= x"0241A8AA";
end if;
if pc = 1048 then
	inst <= x"02404BAE";
end if;
if pc = 1052 then
	inst <= x"88620560";
end if;
if pc = 1056 then
	inst <= x"80640008";
end if;
if pc = 1060 then
	inst <= x"8001E000";
end if;
if pc = 1064 then
	inst <= x"02217545";
end if;
if pc = 1068 then
	inst <= x"0220525D";
end if;
if pc = 1072 then
	inst <= x"02415154";
end if;
if pc = 1076 then
	inst <= x"0240975D";
end if;
if pc = 1080 then
	inst <= x"88620660";
end if;
if pc = 1084 then
	inst <= x"80640008";
end if;
if pc = 1088 then
	inst <= x"8001E000";
end if;
if pc = 1092 then
	inst <= x"02217545";
end if;
if pc = 1096 then
	inst <= x"0220525D";
end if;
if pc = 1100 then
	inst <= x"0241A2A9";
end if;
if pc = 1104 then
	inst <= x"02402EBA";
end if;
if pc = 1108 then
	inst <= x"88620760";
end if;
if pc = 1112 then
	inst <= x"80640008";
end if;
if pc = 1116 then
	inst <= x"8001E000";
end if;
if pc = 1120 then
	inst <= x"02217545";
end if;
if pc = 1124 then
	inst <= x"0220525D";
end if;
if pc = 1128 then
	inst <= x"02414552";
end if;
if pc = 1132 then
	inst <= x"02405D75";
end if;
if pc = 1136 then
	inst <= x"88620860";
end if;
if pc = 1140 then
	inst <= x"80640008";
end if;
if pc = 1144 then
	inst <= x"8001E000";
end if;
if pc = 1148 then
	inst <= x"02217545";
end if;
if pc = 1152 then
	inst <= x"0220525D";
end if;
if pc = 1156 then
	inst <= x"02418AA4";
end if;
if pc = 1160 then
	inst <= x"0240BAEA";
end if;
if pc = 1164 then
	inst <= x"88620960";
end if;
if pc = 1168 then
	inst <= x"80640008";
end if;
if pc = 1172 then
	inst <= x"8001E000";
end if;
if pc = 1176 then
	inst <= x"02217545";
end if;
if pc = 1180 then
	inst <= x"0220525D";
end if;
if pc = 1184 then
	inst <= x"02411549";
end if;
if pc = 1188 then
	inst <= x"024075D5";
end if;
if pc = 1192 then
	inst <= x"88620A60";
end if;
if pc = 1196 then
	inst <= x"80640008";
end if;
if pc = 1200 then
	inst <= x"8001E000";
end if;
if pc = 1204 then
	inst <= x"02217545";
end if;
if pc = 1208 then
	inst <= x"0220525D";
end if;
if pc = 1212 then
	inst <= x"02412A92";
end if;
if pc = 1216 then
	inst <= x"0240EBAA";
end if;
if pc = 1220 then
	inst <= x"88620B60";
end if;
if pc = 1224 then
	inst <= x"80640008";
end if;
if pc = 1228 then
	inst <= x"8001E000";
end if;
if pc = 1232 then
	inst <= x"02217545";
end if;
if pc = 1236 then
	inst <= x"0220525D";
end if;
if pc = 1240 then
	inst <= x"02415525";
end if;
if pc = 1244 then
	inst <= x"0240D754";
end if;
if pc = 1248 then
	inst <= x"88620C60";
end if;
if pc = 1252 then
	inst <= x"80640008";
end if;
if pc = 1256 then
	inst <= x"8001E000";
end if;
if pc = 1260 then
	inst <= x"02217545";
end if;
if pc = 1264 then
	inst <= x"0220525D";
end if;
if pc = 1268 then
	inst <= x"0241AA4B";
end if;
if pc = 1272 then
	inst <= x"0240AEA8";
end if;
if pc = 1276 then
	inst <= x"88620D60";
end if;
if pc = 1280 then
	inst <= x"80640008";
end if;
if pc = 1284 then
	inst <= x"8001E000";
end if;
if pc = 1288 then
	inst <= x"02217545";
end if;
if pc = 1292 then
	inst <= x"0220525D";
end if;
if pc = 1296 then
	inst <= x"02415497";
end if;
if pc = 1300 then
	inst <= x"02405D51";
end if;
if pc = 1304 then
	inst <= x"88620E60";
end if;
if pc = 1308 then
	inst <= x"80640008";
end if;
if pc = 1312 then
	inst <= x"8001E000";
end if;
if pc = 1316 then
	inst <= x"02217545";
end if;
if pc = 1320 then
	inst <= x"0220525D";
end if;
if pc = 1324 then
	inst <= x"0241A92E";
end if;
if pc = 1328 then
	inst <= x"0240BAA2";
end if;
if pc = 1332 then
	inst <= x"88620F60";
end if;
if pc = 1336 then
	inst <= x"80640008";
end if;
if pc = 1340 then
	inst <= x"8001E000";
end if;
if pc = 1344 then
	inst <= x"02217545";
end if;
if pc = 1348 then
	inst <= x"0220525D";
end if;
if pc = 1352 then
	inst <= x"0241525D";
end if;
if pc = 1356 then
	inst <= x"02407545";
end if;
if pc = 1360 then
	inst <= x"88621060";
end if;
if pc = 1364 then
	inst <= x"80640008";
end if;
if pc = 1368 then
	inst <= x"8001E000";
end if;
if pc = 1372 then
	inst <= x"02217545";
end if;
if pc = 1376 then
	inst <= x"0220525D";
end if;
if pc = 1380 then
	inst <= x"0241A4BA";
end if;
if pc = 1384 then
	inst <= x"0240EA8A";
end if;
if pc = 1388 then
	inst <= x"88621160";
end if;
if pc = 1392 then
	inst <= x"80640008";
end if;
if pc = 1396 then
	inst <= x"8001E000";
end if;
if pc = 1400 then
	inst <= x"02217545";
end if;
if pc = 1404 then
	inst <= x"0220525D";
end if;
if pc = 1408 then
	inst <= x"02414975";
end if;
if pc = 1412 then
	inst <= x"0240D515";
end if;
if pc = 1416 then
	inst <= x"88621260";
end if;
if pc = 1420 then
	inst <= x"80640008";
end if;
if pc = 1424 then
	inst <= x"8001E000";
end if;
if pc = 1428 then
	inst <= x"02217545";
end if;
if pc = 1432 then
	inst <= x"0220525D";
end if;
if pc = 1436 then
	inst <= x"024192EB";
end if;
if pc = 1440 then
	inst <= x"0240AA2A";
end if;
if pc = 1444 then
	inst <= x"88621360";
end if;
if pc = 1448 then
	inst <= x"80640008";
end if;
if pc = 1452 then
	inst <= x"8001E000";
end if;
if pc = 1456 then
	inst <= x"02217545";
end if;
if pc = 1460 then
	inst <= x"0220525D";
end if;
if pc = 1464 then
	inst <= x"024125D7";
end if;
if pc = 1468 then
	inst <= x"02405455";
end if;
if pc = 1472 then
	inst <= x"88621460";
end if;
if pc = 1476 then
	inst <= x"80640008";
end if;
if pc = 1480 then
	inst <= x"8001E000";
end if;
if pc = 1484 then
	inst <= x"02217545";
end if;
if pc = 1488 then
	inst <= x"0220525D";
end if;
if pc = 1492 then
	inst <= x"02414BAE";
end if;
if pc = 1496 then
	inst <= x"0240A8AA";
end if;
if pc = 1500 then
	inst <= x"88621560";
end if;
if pc = 1504 then
	inst <= x"80640008";
end if;
if pc = 1508 then
	inst <= x"8001E000";
end if;
if pc = 1512 then
	inst <= x"02217545";
end if;
if pc = 1516 then
	inst <= x"0220525D";
end if;
if pc = 1520 then
	inst <= x"0241975D";
end if;
if pc = 1524 then
	inst <= x"02405154";
end if;
if pc = 1528 then
	inst <= x"88621660";
end if;
if pc = 1532 then
	inst <= x"80640008";
end if;
if pc = 1536 then
	inst <= x"8001E000";
end if;
if pc = 1540 then
	inst <= x"02217545";
end if;
if pc = 1544 then
	inst <= x"0220525D";
end if;
if pc = 1548 then
	inst <= x"02412EBA";
end if;
if pc = 1552 then
	inst <= x"0240A2A9";
end if;
if pc = 1556 then
	inst <= x"88621760";
end if;
if pc = 1560 then
	inst <= x"80640008";
end if;
if pc = 1564 then
	inst <= x"8001E000";
end if;
if pc = 1568 then
	inst <= x"02217545";
end if;
if pc = 1572 then
	inst <= x"0220525D";
end if;
if pc = 1576 then
	inst <= x"02415D75";
end if;
if pc = 1580 then
	inst <= x"02404552";
end if;
if pc = 1584 then
	inst <= x"88621860";
end if;
if pc = 1588 then
	inst <= x"80640008";
end if;
if pc = 1592 then
	inst <= x"8001E000";
end if;
if pc = 1596 then
	inst <= x"02217545";
end if;
if pc = 1600 then
	inst <= x"0220525D";
end if;
if pc = 1604 then
	inst <= x"0241BAEA";
end if;
if pc = 1608 then
	inst <= x"02408AA4";
end if;
if pc = 1612 then
	inst <= x"88621960";
end if;
if pc = 1616 then
	inst <= x"80640008";
end if;
if pc = 1620 then
	inst <= x"8001E000";
end if;
if pc = 1624 then
	inst <= x"02217545";
end if;
if pc = 1628 then
	inst <= x"0220525D";
end if;
if pc = 1632 then
	inst <= x"024175D5";
end if;
if pc = 1636 then
	inst <= x"02401549";
end if;
if pc = 1640 then
	inst <= x"88621A60";
end if;
if pc = 1644 then
	inst <= x"80640008";
end if;
if pc = 1648 then
	inst <= x"8001E000";
end if;
if pc = 1652 then
	inst <= x"02217545";
end if;
if pc = 1656 then
	inst <= x"0220525D";
end if;
if pc = 1660 then
	inst <= x"0241EBAA";
end if;
if pc = 1664 then
	inst <= x"02402A92";
end if;
if pc = 1668 then
	inst <= x"88621B60";
end if;
if pc = 1672 then
	inst <= x"80640008";
end if;
if pc = 1676 then
	inst <= x"8001E000";
end if;
if pc = 1680 then
	inst <= x"02217545";
end if;
if pc = 1684 then
	inst <= x"0220525D";
end if;
if pc = 1688 then
	inst <= x"0241D754";
end if;
if pc = 1692 then
	inst <= x"02405525";
end if;
if pc = 1696 then
	inst <= x"88621C60";
end if;
if pc = 1700 then
	inst <= x"80640008";
end if;
if pc = 1704 then
	inst <= x"8001E000";
end if;
if pc = 1708 then
	inst <= x"02217545";
end if;
if pc = 1712 then
	inst <= x"0220525D";
end if;
if pc = 1716 then
	inst <= x"0241AEA8";
end if;
if pc = 1720 then
	inst <= x"0240AA4B";
end if;
if pc = 1724 then
	inst <= x"88621D60";
end if;
if pc = 1728 then
	inst <= x"80640008";
end if;
if pc = 1732 then
	inst <= x"8001E000";
end if;
if pc = 1736 then
	inst <= x"02217545";
end if;
if pc = 1740 then
	inst <= x"0220525D";
end if;
if pc = 1744 then
	inst <= x"02415D51";
end if;
if pc = 1748 then
	inst <= x"02405497";
end if;
if pc = 1752 then
	inst <= x"88621E60";
end if;
if pc = 1756 then
	inst <= x"80640008";
end if;
if pc = 1760 then
	inst <= x"8001E000";
end if;
if pc = 1764 then
	inst <= x"02217545";
end if;
if pc = 1768 then
	inst <= x"0220525D";
end if;
if pc = 1772 then
	inst <= x"0241BAA2";
end if;
if pc = 1776 then
	inst <= x"0240A92E";
end if;
if pc = 1780 then
	inst <= x"88621F60";
end if;
if pc = 1784 then
	inst <= x"80640008";
end if;
if pc = 1788 then
	inst <= x"8001E000";
end if;
if pc = 1792 then
	inst <= x"8001E000";
end if;
--if pc = 0 then
--	inst <= x"44624000";
--end if;
--if pc > 0 then
--	inst <= x"FFFFFFFF";
--end if;
--if pc = 0 then
--	inst <= x"40246000";
--end if;
--if pc > 0 then
--	inst <= x"FFFFFFFF";
--end if;
        else
          inst <= x"FFFFFFFF";
        end if;
      end if;
    end if;
  end process;
end fetch_test;

