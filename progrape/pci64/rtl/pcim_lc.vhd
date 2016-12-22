--------------------------------------------------------------------------
--
--  File:   pcim_lc.vhd
--  Rev:    3.0.0
--
--  This is a lower-level VHDL module which serves as a wrapper
--  for the PCI interface.  This module makes use of Unified Library
--  Primitives.  Do not modify this file.
--
--  Copyright (c) 2005 Xilinx, Inc.  All rights reserved.
--
--------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- synthesis translate_off
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
-- synthesis translate_on


entity pcim_lc is
  port (
        AD_IO           : inout std_logic_vector( 63 downto 0);
        CBE_IO          : inout std_logic_vector(  7 downto 0);
        PAR_IO          : inout std_logic;
        PAR64_IO        : inout std_logic;
        FRAME_IO        : inout std_logic;
        REQ64_IO        : inout std_logic;
        TRDY_IO         : inout std_logic;
        IRDY_IO         : inout std_logic;
        STOP_IO         : inout std_logic;
        DEVSEL_IO       : inout std_logic;
        ACK64_IO        : inout std_logic;
        IDSEL_I         : in    std_logic;
        INTA_O          : out   std_logic;
        PERR_IO         : inout std_logic;
        SERR_IO         : inout std_logic;
        REQ_O           : out   std_logic;
        GNT_I           : in    std_logic;

        RST_I           : in    std_logic;
        PCLK            : in    std_logic;

        CFG             : in    std_logic_vector(255 downto 0);

        FRAMEQ_N        : out   std_logic;
        REQ64Q_N        : out   std_logic;
        TRDYQ_N         : out   std_logic;
        IRDYQ_N         : out   std_logic;
        STOPQ_N         : out   std_logic;
        DEVSELQ_N       : out   std_logic;
        ACK64Q_N        : out   std_logic;

        ADDR            : out   std_logic_vector( 31 downto 0);
        ADIO            : inout std_logic_vector( 63 downto 0);

        CFG_VLD         : out   std_logic;
        CFG_HIT         : out   std_logic;
        C_TERM          : in    std_logic;
        C_READY         : in    std_logic;
        ADDR_VLD        : out   std_logic;
        BASE_HIT        : out   std_logic_vector(  7 downto 0);
        S_CYCLE64       : out   std_logic;
        S_TERM          : in    std_logic;
        S_READY         : in    std_logic;
        S_ABORT         : in    std_logic;
        S_WRDN          : out   std_logic;
        S_SRC_EN        : out   std_logic;
        S_DATA_VLD      : out   std_logic;
        S_CBE           : out   std_logic_vector(  7 downto 0);
        PCI_CMD         : out   std_logic_vector( 15 downto 0);

        REQUEST         : in    std_logic;
        REQUEST64       : in    std_logic;
        REQUESTHOLD     : in    std_logic;
        COMPLETE        : in    std_logic;
        M_WRDN          : in    std_logic;
        M_READY         : in    std_logic;
        M_SRC_EN        : out   std_logic;
        M_DATA_VLD      : out   std_logic;
        M_CBE           : in    std_logic_vector(  7 downto 0);
        TIME_OUT        : out   std_logic;
        M_FAIL64        : out   std_logic;
        CFG_SELF        : in    std_logic;

        M_DATA          : out   std_logic;
        DR_BUS          : out   std_logic;
        I_IDLE          : out   std_logic;
        M_ADDR_N        : out   std_logic;

        IDLE            : out   std_logic;
        B_BUSY          : out   std_logic;
        S_DATA          : out   std_logic;
        BACKOFF         : out   std_logic;

        SLOT64          : in    std_logic;
        INTR_N          : in    std_logic;
        PERRQ_N         : out   std_logic;
        SERRQ_N         : out   std_logic;
        KEEPOUT         : in    std_logic;
        CSR             : out   std_logic_vector( 39 downto 0);
        SUB_DATA        : in    std_logic_vector( 31 downto 0);

        RST             : inout std_logic;
        CLK             : inout std_logic
  );
end pcim_lc;


architecture WRAPPER of pcim_lc is

  attribute syn_edif_bit_format : string;
  attribute syn_edif_scalar_format : string;
  attribute syn_noclockbuf : boolean;
  attribute syn_hier : string;
  attribute syn_edif_bit_format of WRAPPER : architecture is "%u<%i>";
  attribute syn_edif_scalar_format of WRAPPER : architecture is "%u";
  attribute syn_noclockbuf of WRAPPER : architecture is true;
  attribute syn_hier of WRAPPER : architecture is "hard";

  component IOBUF_PCI66_3
    port(O: out STD_LOGIC;
         IO: inout STD_LOGIC;
         I: in STD_LOGIC;
         T: in STD_LOGIC
    );
  end component;

  component IBUF_PCI66_3
    port(O: out STD_LOGIC;
         I: in STD_LOGIC
    );
  end component; 

  component OBUFT_PCI66_3
    port(O: out STD_LOGIC;
         I: in STD_LOGIC;
         T: in STD_LOGIC
    );
  end component; 

  component IBUFG_PCI66_3
    port(O: out STD_LOGIC; 
         I: in STD_LOGIC
    ); 
  end component;  

  component BUFG
    port(O: out STD_LOGIC; 
         I: in STD_LOGIC
    ); 
  end component;  

  component FDPE
    port(Q: out STD_LOGIC;
         D: in STD_LOGIC;
         C: in STD_LOGIC;
         CE: in STD_LOGIC;
         PRE: in STD_LOGIC
    );
  end component;

  component PCI_LC_I
    port (
      OE_ADO_T64 : out STD_LOGIC; 
      OE_ADO_T : out STD_LOGIC; 
      OE_ADO_LT64 : out STD_LOGIC; 
      OE_ADO_LT : out STD_LOGIC; 
      OE_ADO_LB64 : out STD_LOGIC; 
      OE_ADO_LB : out STD_LOGIC; 
      OE_ADO_B64 : out STD_LOGIC; 
      OE_ADO_B : out STD_LOGIC; 
      AD63 : in STD_LOGIC; 
      AD62 : in STD_LOGIC; 
      AD61 : in STD_LOGIC; 
      AD60 : in STD_LOGIC; 
      AD59 : in STD_LOGIC; 
      AD58 : in STD_LOGIC; 
      AD57 : in STD_LOGIC; 
      AD56 : in STD_LOGIC; 
      AD55 : in STD_LOGIC; 
      AD54 : in STD_LOGIC; 
      AD53 : in STD_LOGIC; 
      AD52 : in STD_LOGIC; 
      AD51 : in STD_LOGIC; 
      AD50 : in STD_LOGIC; 
      AD49 : in STD_LOGIC; 
      AD48 : in STD_LOGIC; 
      AD47 : in STD_LOGIC; 
      AD46 : in STD_LOGIC; 
      AD45 : in STD_LOGIC; 
      AD44 : in STD_LOGIC; 
      AD43 : in STD_LOGIC; 
      AD42 : in STD_LOGIC; 
      AD41 : in STD_LOGIC; 
      AD40 : in STD_LOGIC; 
      AD39 : in STD_LOGIC; 
      AD38 : in STD_LOGIC; 
      AD37 : in STD_LOGIC; 
      AD36 : in STD_LOGIC; 
      AD35 : in STD_LOGIC; 
      AD34 : in STD_LOGIC; 
      AD33 : in STD_LOGIC; 
      AD32 : in STD_LOGIC; 
      AD31 : in STD_LOGIC; 
      AD30 : in STD_LOGIC; 
      AD29 : in STD_LOGIC; 
      AD28 : in STD_LOGIC; 
      AD27 : in STD_LOGIC; 
      AD26 : in STD_LOGIC; 
      AD25 : in STD_LOGIC; 
      AD24 : in STD_LOGIC; 
      AD23 : in STD_LOGIC; 
      AD22 : in STD_LOGIC; 
      AD21 : in STD_LOGIC; 
      AD20 : in STD_LOGIC; 
      AD19 : in STD_LOGIC; 
      AD18 : in STD_LOGIC; 
      AD17 : in STD_LOGIC; 
      AD16 : in STD_LOGIC; 
      AD15 : in STD_LOGIC; 
      AD14 : in STD_LOGIC; 
      AD13 : in STD_LOGIC; 
      AD12 : in STD_LOGIC; 
      AD11 : in STD_LOGIC; 
      AD10 : in STD_LOGIC; 
      AD9 : in STD_LOGIC; 
      AD8 : in STD_LOGIC; 
      AD7 : in STD_LOGIC; 
      AD6 : in STD_LOGIC; 
      AD5 : in STD_LOGIC; 
      AD4 : in STD_LOGIC; 
      AD3 : in STD_LOGIC; 
      AD2 : in STD_LOGIC; 
      AD1 : in STD_LOGIC; 
      AD0 : in STD_LOGIC; 
      AD_O63 : out STD_LOGIC; 
      AD_O62 : out STD_LOGIC; 
      AD_O61 : out STD_LOGIC; 
      AD_O60 : out STD_LOGIC; 
      AD_O59 : out STD_LOGIC; 
      AD_O58 : out STD_LOGIC; 
      AD_O57 : out STD_LOGIC; 
      AD_O56 : out STD_LOGIC; 
      AD_O55 : out STD_LOGIC; 
      AD_O54 : out STD_LOGIC; 
      AD_O53 : out STD_LOGIC; 
      AD_O52 : out STD_LOGIC; 
      AD_O51 : out STD_LOGIC; 
      AD_O50 : out STD_LOGIC; 
      AD_O49 : out STD_LOGIC; 
      AD_O48 : out STD_LOGIC; 
      AD_O47 : out STD_LOGIC; 
      AD_O46 : out STD_LOGIC; 
      AD_O45 : out STD_LOGIC; 
      AD_O44 : out STD_LOGIC; 
      AD_O43 : out STD_LOGIC; 
      AD_O42 : out STD_LOGIC; 
      AD_O41 : out STD_LOGIC; 
      AD_O40 : out STD_LOGIC; 
      AD_O39 : out STD_LOGIC; 
      AD_O38 : out STD_LOGIC; 
      AD_O37 : out STD_LOGIC; 
      AD_O36 : out STD_LOGIC; 
      AD_O35 : out STD_LOGIC; 
      AD_O34 : out STD_LOGIC; 
      AD_O33 : out STD_LOGIC; 
      AD_O32 : out STD_LOGIC; 
      AD_O31 : out STD_LOGIC; 
      AD_O30 : out STD_LOGIC; 
      AD_O29 : out STD_LOGIC; 
      AD_O28 : out STD_LOGIC; 
      AD_O27 : out STD_LOGIC; 
      AD_O26 : out STD_LOGIC; 
      AD_O25 : out STD_LOGIC; 
      AD_O24 : out STD_LOGIC; 
      AD_O23 : out STD_LOGIC; 
      AD_O22 : out STD_LOGIC; 
      AD_O21 : out STD_LOGIC; 
      AD_O20 : out STD_LOGIC; 
      AD_O19 : out STD_LOGIC; 
      AD_O18 : out STD_LOGIC; 
      AD_O17 : out STD_LOGIC; 
      AD_O16 : out STD_LOGIC; 
      AD_O15 : out STD_LOGIC; 
      AD_O14 : out STD_LOGIC; 
      AD_O13 : out STD_LOGIC; 
      AD_O12 : out STD_LOGIC; 
      AD_O11 : out STD_LOGIC; 
      AD_O10 : out STD_LOGIC; 
      AD_O9 : out STD_LOGIC; 
      AD_O8 : out STD_LOGIC; 
      AD_O7 : out STD_LOGIC; 
      AD_O6 : out STD_LOGIC; 
      AD_O5 : out STD_LOGIC; 
      AD_O4 : out STD_LOGIC; 
      AD_O3 : out STD_LOGIC; 
      AD_O2 : out STD_LOGIC; 
      AD_O1 : out STD_LOGIC; 
      AD_O0 : out STD_LOGIC; 

      OE_CBE64 : out STD_LOGIC; 
      OE_CBE : out STD_LOGIC; 
      CBE_I7 : in STD_LOGIC; 
      CBE_I6 : in STD_LOGIC; 
      CBE_I5 : in STD_LOGIC; 
      CBE_I4 : in STD_LOGIC; 
      CBE_I3 : in STD_LOGIC; 
      CBE_I2 : in STD_LOGIC; 
      CBE_I1 : in STD_LOGIC; 
      CBE_I0 : in STD_LOGIC; 
      CBE_IN7 : in STD_LOGIC; 
      CBE_IN6 : in STD_LOGIC; 
      CBE_IN5 : in STD_LOGIC; 
      CBE_IN4 : in STD_LOGIC; 
      CBE_IN3 : in STD_LOGIC; 
      CBE_IN2 : in STD_LOGIC; 
      CBE_IN1 : in STD_LOGIC; 
      CBE_IN0 : in STD_LOGIC; 
      CBE_O7 : out STD_LOGIC; 
      CBE_O6 : out STD_LOGIC; 
      CBE_O5 : out STD_LOGIC; 
      CBE_O4 : out STD_LOGIC; 
      CBE_O3 : out STD_LOGIC; 
      CBE_O2 : out STD_LOGIC; 
      CBE_O1 : out STD_LOGIC; 
      CBE_O0 : out STD_LOGIC; 

      OE_PAR64 : out STD_LOGIC; 
      PAR64_I : in STD_LOGIC; 
      PAR64_O : out STD_LOGIC; 

      OE_PAR : out STD_LOGIC; 
      PAR_I : in STD_LOGIC; 
      PAR_O : out STD_LOGIC; 

      OE_FRAME : out STD_LOGIC; 
      FRAME_I : in STD_LOGIC; 
      FRAME_O : out STD_LOGIC; 

      OE_REQ64 : out STD_LOGIC; 
      REQ64_I : in STD_LOGIC; 
      REQ64_O : out STD_LOGIC; 

      OE_TRDY : out STD_LOGIC; 
      TRDY_I : in STD_LOGIC; 
      TRDY_O : out STD_LOGIC; 

      OE_IRDY : out STD_LOGIC; 
      IRDY_I : in STD_LOGIC; 
      IRDY_O : out STD_LOGIC; 

      OE_STOP : out STD_LOGIC; 
      STOP_I : in STD_LOGIC; 
      STOP_O : out STD_LOGIC; 

      OE_DEVSEL : out STD_LOGIC; 
      DEVSEL_I : in STD_LOGIC; 
      DEVSEL_O : out STD_LOGIC; 

      OE_ACK64 : out STD_LOGIC; 
      ACK64_I : in STD_LOGIC; 
      ACK64_O : out STD_LOGIC; 

      IDSEL_IN : in STD_LOGIC; 

      OE_INTA : out STD_LOGIC; 

      OE_PERR : out STD_LOGIC; 
      PERR_I : in STD_LOGIC; 
      PERR_O : out STD_LOGIC; 

      OE_SERR : out STD_LOGIC; 
      SERR_I : in STD_LOGIC; 

      OE_REQ : out STD_LOGIC; 
      REQ_OUT : out STD_LOGIC; 

      GNT_IN : in STD_LOGIC; 

      RST_N : in STD_LOGIC; 

      CFG255 : in STD_LOGIC; 
      CFG254 : in STD_LOGIC; 
      CFG253 : in STD_LOGIC; 
      CFG252 : in STD_LOGIC; 
      CFG251 : in STD_LOGIC; 
      CFG250 : in STD_LOGIC; 
      CFG249 : in STD_LOGIC; 
      CFG248 : in STD_LOGIC; 
      CFG247 : in STD_LOGIC; 
      CFG246 : in STD_LOGIC; 
      CFG245 : in STD_LOGIC; 
      CFG244 : in STD_LOGIC; 
      CFG243 : in STD_LOGIC; 
      CFG242 : in STD_LOGIC; 
      CFG241 : in STD_LOGIC; 
      CFG240 : in STD_LOGIC; 
      CFG239 : in STD_LOGIC; 
      CFG238 : in STD_LOGIC; 
      CFG237 : in STD_LOGIC; 
      CFG236 : in STD_LOGIC; 
      CFG235 : in STD_LOGIC; 
      CFG234 : in STD_LOGIC; 
      CFG233 : in STD_LOGIC; 
      CFG232 : in STD_LOGIC; 
      CFG231 : in STD_LOGIC; 
      CFG230 : in STD_LOGIC; 
      CFG229 : in STD_LOGIC; 
      CFG228 : in STD_LOGIC; 
      CFG227 : in STD_LOGIC; 
      CFG226 : in STD_LOGIC; 
      CFG225 : in STD_LOGIC; 
      CFG224 : in STD_LOGIC; 
      CFG223 : in STD_LOGIC; 
      CFG222 : in STD_LOGIC; 
      CFG221 : in STD_LOGIC; 
      CFG220 : in STD_LOGIC; 
      CFG219 : in STD_LOGIC; 
      CFG218 : in STD_LOGIC; 
      CFG217 : in STD_LOGIC; 
      CFG216 : in STD_LOGIC; 
      CFG215 : in STD_LOGIC; 
      CFG214 : in STD_LOGIC; 
      CFG213 : in STD_LOGIC; 
      CFG212 : in STD_LOGIC; 
      CFG211 : in STD_LOGIC; 
      CFG210 : in STD_LOGIC; 
      CFG209 : in STD_LOGIC; 
      CFG208 : in STD_LOGIC; 
      CFG207 : in STD_LOGIC; 
      CFG206 : in STD_LOGIC; 
      CFG205 : in STD_LOGIC; 
      CFG204 : in STD_LOGIC; 
      CFG203 : in STD_LOGIC; 
      CFG202 : in STD_LOGIC; 
      CFG201 : in STD_LOGIC; 
      CFG200 : in STD_LOGIC; 
      CFG199 : in STD_LOGIC; 
      CFG198 : in STD_LOGIC; 
      CFG197 : in STD_LOGIC; 
      CFG196 : in STD_LOGIC; 
      CFG195 : in STD_LOGIC; 
      CFG194 : in STD_LOGIC; 
      CFG193 : in STD_LOGIC; 
      CFG192 : in STD_LOGIC; 
      CFG191 : in STD_LOGIC; 
      CFG190 : in STD_LOGIC; 
      CFG189 : in STD_LOGIC; 
      CFG188 : in STD_LOGIC; 
      CFG187 : in STD_LOGIC; 
      CFG186 : in STD_LOGIC; 
      CFG185 : in STD_LOGIC; 
      CFG184 : in STD_LOGIC; 
      CFG183 : in STD_LOGIC; 
      CFG182 : in STD_LOGIC; 
      CFG181 : in STD_LOGIC; 
      CFG180 : in STD_LOGIC; 
      CFG179 : in STD_LOGIC; 
      CFG178 : in STD_LOGIC; 
      CFG177 : in STD_LOGIC; 
      CFG176 : in STD_LOGIC; 
      CFG175 : in STD_LOGIC; 
      CFG174 : in STD_LOGIC; 
      CFG173 : in STD_LOGIC; 
      CFG172 : in STD_LOGIC; 
      CFG171 : in STD_LOGIC; 
      CFG170 : in STD_LOGIC; 
      CFG169 : in STD_LOGIC; 
      CFG168 : in STD_LOGIC; 
      CFG167 : in STD_LOGIC; 
      CFG166 : in STD_LOGIC; 
      CFG165 : in STD_LOGIC; 
      CFG164 : in STD_LOGIC; 
      CFG163 : in STD_LOGIC; 
      CFG162 : in STD_LOGIC; 
      CFG161 : in STD_LOGIC; 
      CFG160 : in STD_LOGIC; 
      CFG159 : in STD_LOGIC; 
      CFG158 : in STD_LOGIC; 
      CFG157 : in STD_LOGIC; 
      CFG156 : in STD_LOGIC; 
      CFG155 : in STD_LOGIC; 
      CFG154 : in STD_LOGIC; 
      CFG153 : in STD_LOGIC; 
      CFG152 : in STD_LOGIC; 
      CFG151 : in STD_LOGIC; 
      CFG150 : in STD_LOGIC; 
      CFG149 : in STD_LOGIC; 
      CFG148 : in STD_LOGIC; 
      CFG147 : in STD_LOGIC; 
      CFG146 : in STD_LOGIC; 
      CFG145 : in STD_LOGIC; 
      CFG144 : in STD_LOGIC; 
      CFG143 : in STD_LOGIC; 
      CFG142 : in STD_LOGIC; 
      CFG141 : in STD_LOGIC; 
      CFG140 : in STD_LOGIC; 
      CFG139 : in STD_LOGIC; 
      CFG138 : in STD_LOGIC; 
      CFG137 : in STD_LOGIC; 
      CFG136 : in STD_LOGIC; 
      CFG135 : in STD_LOGIC; 
      CFG134 : in STD_LOGIC; 
      CFG133 : in STD_LOGIC; 
      CFG132 : in STD_LOGIC; 
      CFG131 : in STD_LOGIC; 
      CFG130 : in STD_LOGIC; 
      CFG129 : in STD_LOGIC; 
      CFG128 : in STD_LOGIC; 
      CFG127 : in STD_LOGIC; 
      CFG126 : in STD_LOGIC; 
      CFG125 : in STD_LOGIC; 
      CFG124 : in STD_LOGIC; 
      CFG123 : in STD_LOGIC; 
      CFG122 : in STD_LOGIC; 
      CFG121 : in STD_LOGIC; 
      CFG120 : in STD_LOGIC; 
      CFG119 : in STD_LOGIC; 
      CFG118 : in STD_LOGIC; 
      CFG117 : in STD_LOGIC; 
      CFG116 : in STD_LOGIC; 
      CFG115 : in STD_LOGIC; 
      CFG114 : in STD_LOGIC; 
      CFG113 : in STD_LOGIC; 
      CFG112 : in STD_LOGIC; 
      CFG111 : in STD_LOGIC; 
      CFG110 : in STD_LOGIC; 
      CFG109 : in STD_LOGIC; 
      CFG108 : in STD_LOGIC; 
      CFG107 : in STD_LOGIC; 
      CFG106 : in STD_LOGIC; 
      CFG105 : in STD_LOGIC; 
      CFG104 : in STD_LOGIC; 
      CFG103 : in STD_LOGIC; 
      CFG102 : in STD_LOGIC; 
      CFG101 : in STD_LOGIC; 
      CFG100 : in STD_LOGIC; 
      CFG99 : in STD_LOGIC; 
      CFG98 : in STD_LOGIC; 
      CFG97 : in STD_LOGIC; 
      CFG96 : in STD_LOGIC; 
      CFG95 : in STD_LOGIC; 
      CFG94 : in STD_LOGIC; 
      CFG93 : in STD_LOGIC; 
      CFG92 : in STD_LOGIC; 
      CFG91 : in STD_LOGIC; 
      CFG90 : in STD_LOGIC; 
      CFG89 : in STD_LOGIC; 
      CFG88 : in STD_LOGIC; 
      CFG87 : in STD_LOGIC; 
      CFG86 : in STD_LOGIC; 
      CFG85 : in STD_LOGIC; 
      CFG84 : in STD_LOGIC; 
      CFG83 : in STD_LOGIC; 
      CFG82 : in STD_LOGIC; 
      CFG81 : in STD_LOGIC; 
      CFG80 : in STD_LOGIC; 
      CFG79 : in STD_LOGIC; 
      CFG78 : in STD_LOGIC; 
      CFG77 : in STD_LOGIC; 
      CFG76 : in STD_LOGIC; 
      CFG75 : in STD_LOGIC; 
      CFG74 : in STD_LOGIC; 
      CFG73 : in STD_LOGIC; 
      CFG72 : in STD_LOGIC; 
      CFG71 : in STD_LOGIC; 
      CFG70 : in STD_LOGIC; 
      CFG69 : in STD_LOGIC; 
      CFG68 : in STD_LOGIC; 
      CFG67 : in STD_LOGIC; 
      CFG66 : in STD_LOGIC; 
      CFG65 : in STD_LOGIC; 
      CFG64 : in STD_LOGIC; 
      CFG63 : in STD_LOGIC; 
      CFG62 : in STD_LOGIC; 
      CFG61 : in STD_LOGIC; 
      CFG60 : in STD_LOGIC; 
      CFG59 : in STD_LOGIC; 
      CFG58 : in STD_LOGIC; 
      CFG57 : in STD_LOGIC; 
      CFG56 : in STD_LOGIC; 
      CFG55 : in STD_LOGIC; 
      CFG54 : in STD_LOGIC; 
      CFG53 : in STD_LOGIC; 
      CFG52 : in STD_LOGIC; 
      CFG51 : in STD_LOGIC; 
      CFG50 : in STD_LOGIC; 
      CFG49 : in STD_LOGIC; 
      CFG48 : in STD_LOGIC; 
      CFG47 : in STD_LOGIC; 
      CFG46 : in STD_LOGIC; 
      CFG45 : in STD_LOGIC; 
      CFG44 : in STD_LOGIC; 
      CFG43 : in STD_LOGIC; 
      CFG42 : in STD_LOGIC; 
      CFG41 : in STD_LOGIC; 
      CFG40 : in STD_LOGIC; 
      CFG39 : in STD_LOGIC; 
      CFG38 : in STD_LOGIC; 
      CFG37 : in STD_LOGIC; 
      CFG36 : in STD_LOGIC; 
      CFG35 : in STD_LOGIC; 
      CFG34 : in STD_LOGIC; 
      CFG33 : in STD_LOGIC; 
      CFG32 : in STD_LOGIC; 
      CFG31 : in STD_LOGIC; 
      CFG30 : in STD_LOGIC; 
      CFG29 : in STD_LOGIC; 
      CFG28 : in STD_LOGIC; 
      CFG27 : in STD_LOGIC; 
      CFG26 : in STD_LOGIC; 
      CFG25 : in STD_LOGIC; 
      CFG24 : in STD_LOGIC; 
      CFG23 : in STD_LOGIC; 
      CFG22 : in STD_LOGIC; 
      CFG21 : in STD_LOGIC; 
      CFG20 : in STD_LOGIC; 
      CFG19 : in STD_LOGIC; 
      CFG18 : in STD_LOGIC; 
      CFG17 : in STD_LOGIC; 
      CFG16 : in STD_LOGIC; 
      CFG15 : in STD_LOGIC; 
      CFG14 : in STD_LOGIC; 
      CFG13 : in STD_LOGIC; 
      CFG12 : in STD_LOGIC; 
      CFG11 : in STD_LOGIC; 
      CFG10 : in STD_LOGIC; 
      CFG9 : in STD_LOGIC; 
      CFG8 : in STD_LOGIC; 
      CFG7 : in STD_LOGIC; 
      CFG6 : in STD_LOGIC; 
      CFG5 : in STD_LOGIC; 
      CFG4 : in STD_LOGIC; 
      CFG3 : in STD_LOGIC; 
      CFG2 : in STD_LOGIC; 
      CFG1 : in STD_LOGIC; 
      CFG0 : in STD_LOGIC; 

      FRAMEQ_N : out STD_LOGIC; 
      REQ64Q_N : out STD_LOGIC; 
      TRDYQ_N : out STD_LOGIC; 
      IRDYQ_N : out STD_LOGIC; 
      STOPQ_N : out STD_LOGIC; 
      DEVSELQ_N : out STD_LOGIC; 
      ACK64Q_N : out STD_LOGIC;

      ADDR31 : out STD_LOGIC; 
      ADDR30 : out STD_LOGIC; 
      ADDR29 : out STD_LOGIC; 
      ADDR28 : out STD_LOGIC; 
      ADDR27 : out STD_LOGIC; 
      ADDR26 : out STD_LOGIC; 
      ADDR25 : out STD_LOGIC; 
      ADDR24 : out STD_LOGIC; 
      ADDR23 : out STD_LOGIC; 
      ADDR22 : out STD_LOGIC; 
      ADDR21 : out STD_LOGIC; 
      ADDR20 : out STD_LOGIC; 
      ADDR19 : out STD_LOGIC; 
      ADDR18 : out STD_LOGIC; 
      ADDR17 : out STD_LOGIC; 
      ADDR16 : out STD_LOGIC; 
      ADDR15 : out STD_LOGIC; 
      ADDR14 : out STD_LOGIC; 
      ADDR13 : out STD_LOGIC; 
      ADDR12 : out STD_LOGIC; 
      ADDR11 : out STD_LOGIC; 
      ADDR10 : out STD_LOGIC; 
      ADDR9 : out STD_LOGIC; 
      ADDR8 : out STD_LOGIC; 
      ADDR7 : out STD_LOGIC; 
      ADDR6 : out STD_LOGIC; 
      ADDR5 : out STD_LOGIC; 
      ADDR4 : out STD_LOGIC; 
      ADDR3 : out STD_LOGIC; 
      ADDR2 : out STD_LOGIC; 
      ADDR1 : out STD_LOGIC; 
      ADDR0 : out STD_LOGIC; 

      ADIO63 : inout STD_LOGIC; 
      ADIO62 : inout STD_LOGIC; 
      ADIO61 : inout STD_LOGIC; 
      ADIO60 : inout STD_LOGIC; 
      ADIO59 : inout STD_LOGIC; 
      ADIO58 : inout STD_LOGIC; 
      ADIO57 : inout STD_LOGIC; 
      ADIO56 : inout STD_LOGIC; 
      ADIO55 : inout STD_LOGIC; 
      ADIO54 : inout STD_LOGIC; 
      ADIO53 : inout STD_LOGIC; 
      ADIO52 : inout STD_LOGIC; 
      ADIO51 : inout STD_LOGIC; 
      ADIO50 : inout STD_LOGIC; 
      ADIO49 : inout STD_LOGIC; 
      ADIO48 : inout STD_LOGIC; 
      ADIO47 : inout STD_LOGIC; 
      ADIO46 : inout STD_LOGIC; 
      ADIO45 : inout STD_LOGIC; 
      ADIO44 : inout STD_LOGIC; 
      ADIO43 : inout STD_LOGIC; 
      ADIO42 : inout STD_LOGIC; 
      ADIO41 : inout STD_LOGIC; 
      ADIO40 : inout STD_LOGIC; 
      ADIO39 : inout STD_LOGIC; 
      ADIO38 : inout STD_LOGIC; 
      ADIO37 : inout STD_LOGIC; 
      ADIO36 : inout STD_LOGIC; 
      ADIO35 : inout STD_LOGIC; 
      ADIO34 : inout STD_LOGIC; 
      ADIO33 : inout STD_LOGIC; 
      ADIO32 : inout STD_LOGIC; 
      ADIO31 : inout STD_LOGIC; 
      ADIO30 : inout STD_LOGIC; 
      ADIO29 : inout STD_LOGIC; 
      ADIO28 : inout STD_LOGIC; 
      ADIO27 : inout STD_LOGIC; 
      ADIO26 : inout STD_LOGIC; 
      ADIO25 : inout STD_LOGIC; 
      ADIO24 : inout STD_LOGIC; 
      ADIO23 : inout STD_LOGIC; 
      ADIO22 : inout STD_LOGIC; 
      ADIO21 : inout STD_LOGIC; 
      ADIO20 : inout STD_LOGIC; 
      ADIO19 : inout STD_LOGIC; 
      ADIO18 : inout STD_LOGIC; 
      ADIO17 : inout STD_LOGIC; 
      ADIO16 : inout STD_LOGIC; 
      ADIO15 : inout STD_LOGIC; 
      ADIO14 : inout STD_LOGIC; 
      ADIO13 : inout STD_LOGIC; 
      ADIO12 : inout STD_LOGIC; 
      ADIO11 : inout STD_LOGIC; 
      ADIO10 : inout STD_LOGIC; 
      ADIO9 : inout STD_LOGIC; 
      ADIO8 : inout STD_LOGIC; 
      ADIO7 : inout STD_LOGIC; 
      ADIO6 : inout STD_LOGIC; 
      ADIO5 : inout STD_LOGIC; 
      ADIO4 : inout STD_LOGIC; 
      ADIO3 : inout STD_LOGIC; 
      ADIO2 : inout STD_LOGIC; 
      ADIO1 : inout STD_LOGIC; 
      ADIO0 : inout STD_LOGIC; 

      CFG_VLD : out STD_LOGIC; 
      CFG_HIT : out STD_LOGIC; 
      C_TERM : in STD_LOGIC; 
      C_READY : in STD_LOGIC; 
      ADDR_VLD : out STD_LOGIC; 
      BASE_HIT7 : out STD_LOGIC; 
      BASE_HIT6 : out STD_LOGIC; 
      BASE_HIT5 : out STD_LOGIC; 
      BASE_HIT4 : out STD_LOGIC; 
      BASE_HIT3 : out STD_LOGIC; 
      BASE_HIT2 : out STD_LOGIC; 
      BASE_HIT1 : out STD_LOGIC; 
      BASE_HIT0 : out STD_LOGIC; 
      S_CYCLE64 : out STD_LOGIC; 
      S_TERM : in STD_LOGIC; 
      S_READY : in STD_LOGIC; 
      S_ABORT : in STD_LOGIC; 
      S_WRDN : out STD_LOGIC; 
      S_SRC_EN : out STD_LOGIC; 
      S_DATA_VLD : out STD_LOGIC; 
      S_CBE7 : out STD_LOGIC; 
      S_CBE6 : out STD_LOGIC; 
      S_CBE5 : out STD_LOGIC; 
      S_CBE4 : out STD_LOGIC; 
      S_CBE3 : out STD_LOGIC; 
      S_CBE2 : out STD_LOGIC; 
      S_CBE1 : out STD_LOGIC; 
      S_CBE0 : out STD_LOGIC; 
      PCI_CMD15 : out STD_LOGIC; 
      PCI_CMD14 : out STD_LOGIC; 
      PCI_CMD13 : out STD_LOGIC; 
      PCI_CMD12 : out STD_LOGIC; 
      PCI_CMD11 : out STD_LOGIC; 
      PCI_CMD10 : out STD_LOGIC; 
      PCI_CMD9 : out STD_LOGIC; 
      PCI_CMD8 : out STD_LOGIC; 
      PCI_CMD7 : out STD_LOGIC; 
      PCI_CMD6 : out STD_LOGIC; 
      PCI_CMD5 : out STD_LOGIC; 
      PCI_CMD4 : out STD_LOGIC; 
      PCI_CMD3 : out STD_LOGIC; 
      PCI_CMD2 : out STD_LOGIC; 
      PCI_CMD1 : out STD_LOGIC; 
      PCI_CMD0 : out STD_LOGIC; 

      REQUEST : in STD_LOGIC; 
      REQUEST64 : in STD_LOGIC; 
      REQUESTHOLD : in STD_LOGIC; 
      COMPLETE : in STD_LOGIC; 

      M_WRDN : in STD_LOGIC; 
      M_READY : in STD_LOGIC; 
      M_SRC_EN : out STD_LOGIC; 
      M_DATA_VLD : out STD_LOGIC; 
      M_CBE7 : in STD_LOGIC; 
      M_CBE6 : in STD_LOGIC; 
      M_CBE5 : in STD_LOGIC; 
      M_CBE4 : in STD_LOGIC; 
      M_CBE3 : in STD_LOGIC; 
      M_CBE2 : in STD_LOGIC; 
      M_CBE1 : in STD_LOGIC; 
      M_CBE0 : in STD_LOGIC; 
      TIME_OUT : out STD_LOGIC; 
      M_FAIL64 : out STD_LOGIC; 
      CFG_SELF : in STD_LOGIC; 

      M_DATA : out STD_LOGIC; 
      DR_BUS : out STD_LOGIC; 
      I_IDLE : out STD_LOGIC; 
      M_ADDR_N : out STD_LOGIC; 
      IDLE : out STD_LOGIC; 
      B_BUSY : out STD_LOGIC; 
      S_DATA : out STD_LOGIC; 
      BACKOFF : out STD_LOGIC; 

      SLOT64 : in STD_LOGIC; 
      INTR_N : in STD_LOGIC; 
      PERRQ_N : out STD_LOGIC; 
      SERRQ_N : out STD_LOGIC; 
      KEEPOUT : in STD_LOGIC; 

      CSR39 : out STD_LOGIC; 
      CSR38 : out STD_LOGIC; 
      CSR37 : out STD_LOGIC; 
      CSR36 : out STD_LOGIC; 
      CSR35 : out STD_LOGIC; 
      CSR34 : out STD_LOGIC; 
      CSR33 : out STD_LOGIC; 
      CSR32 : out STD_LOGIC; 
      CSR31 : out STD_LOGIC; 
      CSR30 : out STD_LOGIC; 
      CSR29 : out STD_LOGIC; 
      CSR28 : out STD_LOGIC; 
      CSR27 : out STD_LOGIC; 
      CSR26 : out STD_LOGIC; 
      CSR25 : out STD_LOGIC; 
      CSR24 : out STD_LOGIC; 
      CSR23 : out STD_LOGIC; 
      CSR22 : out STD_LOGIC; 
      CSR21 : out STD_LOGIC; 
      CSR20 : out STD_LOGIC; 
      CSR19 : out STD_LOGIC; 
      CSR18 : out STD_LOGIC; 
      CSR17 : out STD_LOGIC; 
      CSR16 : out STD_LOGIC; 
      CSR15 : out STD_LOGIC; 
      CSR14 : out STD_LOGIC; 
      CSR13 : out STD_LOGIC; 
      CSR12 : out STD_LOGIC; 
      CSR11 : out STD_LOGIC; 
      CSR10 : out STD_LOGIC; 
      CSR9 : out STD_LOGIC; 
      CSR8 : out STD_LOGIC; 
      CSR7 : out STD_LOGIC; 
      CSR6 : out STD_LOGIC; 
      CSR5 : out STD_LOGIC; 
      CSR4 : out STD_LOGIC; 
      CSR3 : out STD_LOGIC; 
      CSR2 : out STD_LOGIC; 
      CSR1 : out STD_LOGIC; 
      CSR0 : out STD_LOGIC; 
      SUB_DATA31 : in STD_LOGIC; 
      SUB_DATA30 : in STD_LOGIC; 
      SUB_DATA29 : in STD_LOGIC;
      SUB_DATA28 : in STD_LOGIC;
      SUB_DATA27 : in STD_LOGIC;
      SUB_DATA26 : in STD_LOGIC;
      SUB_DATA25 : in STD_LOGIC;
      SUB_DATA24 : in STD_LOGIC;
      SUB_DATA23 : in STD_LOGIC;
      SUB_DATA22 : in STD_LOGIC;
      SUB_DATA21 : in STD_LOGIC;
      SUB_DATA20 : in STD_LOGIC;
      SUB_DATA19 : in STD_LOGIC;
      SUB_DATA18 : in STD_LOGIC;
      SUB_DATA17 : in STD_LOGIC;
      SUB_DATA16 : in STD_LOGIC;
      SUB_DATA15 : in STD_LOGIC;
      SUB_DATA14 : in STD_LOGIC;
      SUB_DATA13 : in STD_LOGIC;
      SUB_DATA12 : in STD_LOGIC;
      SUB_DATA11 : in STD_LOGIC;
      SUB_DATA10 : in STD_LOGIC;
      SUB_DATA9 : in STD_LOGIC;
      SUB_DATA8 : in STD_LOGIC;
      SUB_DATA7 : in STD_LOGIC;
      SUB_DATA6 : in STD_LOGIC;
      SUB_DATA5 : in STD_LOGIC;
      SUB_DATA4 : in STD_LOGIC;
      SUB_DATA3 : in STD_LOGIC;
      SUB_DATA2 : in STD_LOGIC;
      SUB_DATA1 : in STD_LOGIC;
      SUB_DATA0 : in STD_LOGIC;
      CLK : in STD_LOGIC;
      CLKX : in STD_LOGIC;
      RST : out STD_LOGIC
    );
  end component;


  signal LO: std_logic;
  signal HI: std_logic;

  signal OE_ADO_T64: std_logic;
  signal OE_ADO_LT64: std_logic;
  signal OE_ADO_LB64: std_logic;
  signal OE_ADO_B64: std_logic;

  signal OE_ADO_T: std_logic;
  signal OE_ADO_LT: std_logic;
  signal OE_ADO_LB: std_logic;
  signal OE_ADO_B: std_logic;

  signal OE_CBE64: std_logic;
  signal OE_CBE: std_logic;

  signal OE_PAR64: std_logic;
  signal PAR64_I: std_logic;
  signal PAR64_O: std_logic;

  signal OE_PAR: std_logic;
  signal PAR_I: std_logic;
  signal PAR_O: std_logic;

  signal OE_FRAME: std_logic;
  signal FRAME_I: std_logic;
  signal FRAME_O: std_logic;

  signal OE_REQ64: std_logic;
  signal REQ64_I: std_logic;
  signal REQ64_O: std_logic;

  signal OE_TRDY: std_logic;
  signal TRDY_I: std_logic;
  signal TRDY_O: std_logic;

  signal OE_IRDY: std_logic;
  signal IRDY_I: std_logic;
  signal IRDY_O: std_logic;

  signal OE_STOP: std_logic;
  signal STOP_I: std_logic;
  signal STOP_O: std_logic;

  signal OE_DEVSEL: std_logic;
  signal DEVSEL_I: std_logic;
  signal DEVSEL_O: std_logic;

  signal OE_ACK64: std_logic;
  signal ACK64_I: std_logic;
  signal ACK64_O: std_logic;

  signal OE_PERR: std_logic;
  signal PERR_I: std_logic;
  signal PERR_O: std_logic;

  signal OE_SERR: std_logic;
  signal SERR_I: std_logic;

  signal OE_REQ: std_logic;
  signal REQ_OUT: std_logic;

  signal OE_INTA: std_logic;

  signal IDSEL_IN: std_logic;

  signal GNT_IN: std_logic;

  signal NUB: std_logic;
  signal CLKX: std_logic;

  signal RST_N: std_logic;

  signal AD63: std_logic; 
  signal AD62: std_logic; 
  signal AD61: std_logic; 
  signal AD60: std_logic; 
  signal AD59: std_logic; 
  signal AD58: std_logic; 
  signal AD57: std_logic; 
  signal AD56: std_logic; 
  signal AD55: std_logic; 
  signal AD54: std_logic; 
  signal AD53: std_logic; 
  signal AD52: std_logic; 
  signal AD51: std_logic; 
  signal AD50: std_logic; 
  signal AD49: std_logic; 
  signal AD48: std_logic; 
  signal AD47: std_logic; 
  signal AD46: std_logic; 
  signal AD45: std_logic; 
  signal AD44: std_logic; 
  signal AD43: std_logic; 
  signal AD42: std_logic; 
  signal AD41: std_logic; 
  signal AD40: std_logic; 
  signal AD39: std_logic; 
  signal AD38: std_logic; 
  signal AD37: std_logic; 
  signal AD36: std_logic; 
  signal AD35: std_logic; 
  signal AD34: std_logic; 
  signal AD33: std_logic; 
  signal AD32: std_logic; 
  signal AD31: std_logic; 
  signal AD30: std_logic; 
  signal AD29: std_logic; 
  signal AD28: std_logic; 
  signal AD27: std_logic; 
  signal AD26: std_logic; 
  signal AD25: std_logic; 
  signal AD24: std_logic; 
  signal AD23: std_logic; 
  signal AD22: std_logic; 
  signal AD21: std_logic; 
  signal AD20: std_logic; 
  signal AD19: std_logic; 
  signal AD18: std_logic; 
  signal AD17: std_logic; 
  signal AD16: std_logic; 
  signal AD15: std_logic; 
  signal AD14: std_logic; 
  signal AD13: std_logic; 
  signal AD12: std_logic; 
  signal AD11: std_logic; 
  signal AD10: std_logic; 
  signal AD9: std_logic; 
  signal AD8: std_logic; 
  signal AD7: std_logic; 
  signal AD6: std_logic; 
  signal AD5: std_logic; 
  signal AD4: std_logic; 
  signal AD3: std_logic; 
  signal AD2: std_logic; 
  signal AD1: std_logic; 
  signal AD0: std_logic; 

  signal AD_I63: std_logic; 
  signal AD_I62: std_logic; 
  signal AD_I61: std_logic; 
  signal AD_I60: std_logic; 
  signal AD_I59: std_logic; 
  signal AD_I58: std_logic; 
  signal AD_I57: std_logic; 
  signal AD_I56: std_logic; 
  signal AD_I55: std_logic; 
  signal AD_I54: std_logic; 
  signal AD_I53: std_logic; 
  signal AD_I52: std_logic; 
  signal AD_I51: std_logic; 
  signal AD_I50: std_logic; 
  signal AD_I49: std_logic; 
  signal AD_I48: std_logic; 
  signal AD_I47: std_logic; 
  signal AD_I46: std_logic; 
  signal AD_I45: std_logic; 
  signal AD_I44: std_logic; 
  signal AD_I43: std_logic; 
  signal AD_I42: std_logic; 
  signal AD_I41: std_logic; 
  signal AD_I40: std_logic; 
  signal AD_I39: std_logic; 
  signal AD_I38: std_logic; 
  signal AD_I37: std_logic; 
  signal AD_I36: std_logic; 
  signal AD_I35: std_logic; 
  signal AD_I34: std_logic; 
  signal AD_I33: std_logic; 
  signal AD_I32: std_logic; 
  signal AD_I31: std_logic; 
  signal AD_I30: std_logic; 
  signal AD_I29: std_logic; 
  signal AD_I28: std_logic; 
  signal AD_I27: std_logic; 
  signal AD_I26: std_logic; 
  signal AD_I25: std_logic; 
  signal AD_I24: std_logic; 
  signal AD_I23: std_logic; 
  signal AD_I22: std_logic; 
  signal AD_I21: std_logic; 
  signal AD_I20: std_logic; 
  signal AD_I19: std_logic; 
  signal AD_I18: std_logic; 
  signal AD_I17: std_logic; 
  signal AD_I16: std_logic; 
  signal AD_I15: std_logic; 
  signal AD_I14: std_logic; 
  signal AD_I13: std_logic; 
  signal AD_I12: std_logic; 
  signal AD_I11: std_logic; 
  signal AD_I10: std_logic; 
  signal AD_I9: std_logic; 
  signal AD_I8: std_logic; 
  signal AD_I7: std_logic; 
  signal AD_I6: std_logic; 
  signal AD_I5: std_logic; 
  signal AD_I4: std_logic; 
  signal AD_I3: std_logic; 
  signal AD_I2: std_logic; 
  signal AD_I1: std_logic; 
  signal AD_I0: std_logic; 

  signal AD_O63: std_logic; 
  signal AD_O62: std_logic; 
  signal AD_O61: std_logic; 
  signal AD_O60: std_logic; 
  signal AD_O59: std_logic; 
  signal AD_O58: std_logic; 
  signal AD_O57: std_logic; 
  signal AD_O56: std_logic; 
  signal AD_O55: std_logic; 
  signal AD_O54: std_logic; 
  signal AD_O53: std_logic; 
  signal AD_O52: std_logic; 
  signal AD_O51: std_logic; 
  signal AD_O50: std_logic; 
  signal AD_O49: std_logic; 
  signal AD_O48: std_logic; 
  signal AD_O47: std_logic; 
  signal AD_O46: std_logic; 
  signal AD_O45: std_logic; 
  signal AD_O44: std_logic; 
  signal AD_O43: std_logic; 
  signal AD_O42: std_logic; 
  signal AD_O41: std_logic; 
  signal AD_O40: std_logic; 
  signal AD_O39: std_logic; 
  signal AD_O38: std_logic; 
  signal AD_O37: std_logic; 
  signal AD_O36: std_logic; 
  signal AD_O35: std_logic; 
  signal AD_O34: std_logic; 
  signal AD_O33: std_logic; 
  signal AD_O32: std_logic; 
  signal AD_O31: std_logic; 
  signal AD_O30: std_logic; 
  signal AD_O29: std_logic; 
  signal AD_O28: std_logic; 
  signal AD_O27: std_logic; 
  signal AD_O26: std_logic; 
  signal AD_O25: std_logic; 
  signal AD_O24: std_logic; 
  signal AD_O23: std_logic; 
  signal AD_O22: std_logic; 
  signal AD_O21: std_logic; 
  signal AD_O20: std_logic; 
  signal AD_O19: std_logic; 
  signal AD_O18: std_logic; 
  signal AD_O17: std_logic; 
  signal AD_O16: std_logic; 
  signal AD_O15: std_logic; 
  signal AD_O14: std_logic; 
  signal AD_O13: std_logic; 
  signal AD_O12: std_logic; 
  signal AD_O11: std_logic; 
  signal AD_O10: std_logic; 
  signal AD_O9: std_logic; 
  signal AD_O8: std_logic; 
  signal AD_O7: std_logic; 
  signal AD_O6: std_logic; 
  signal AD_O5: std_logic; 
  signal AD_O4: std_logic; 
  signal AD_O3: std_logic; 
  signal AD_O2: std_logic; 
  signal AD_O1: std_logic; 
  signal AD_O0: std_logic; 

  signal CBE_IN7: std_logic; 
  signal CBE_IN6: std_logic; 
  signal CBE_IN5: std_logic; 
  signal CBE_IN4: std_logic; 
  signal CBE_IN3: std_logic; 
  signal CBE_IN2: std_logic; 
  signal CBE_IN1: std_logic; 
  signal CBE_IN0: std_logic; 

  signal CBE_I7: std_logic; 
  signal CBE_I6: std_logic; 
  signal CBE_I5: std_logic; 
  signal CBE_I4: std_logic; 
  signal CBE_I3: std_logic; 
  signal CBE_I2: std_logic; 
  signal CBE_I1: std_logic; 
  signal CBE_I0: std_logic; 

  signal CBE_O7: std_logic; 
  signal CBE_O6: std_logic; 
  signal CBE_O5: std_logic; 
  signal CBE_O4: std_logic; 
  signal CBE_O3: std_logic; 
  signal CBE_O2: std_logic; 
  signal CBE_O1: std_logic; 
  signal CBE_O0: std_logic; 


begin

  LO <= '0';
  HI <= '1';

  XPCI_ADB63: IOBUF_PCI66_3 port map
              ( O => AD_I63, IO => AD_IO(63), I => AD_O63, T => OE_ADO_T64 );
  XPCI_ADB62: IOBUF_PCI66_3 port map
              ( O => AD_I62, IO => AD_IO(62), I => AD_O62, T => OE_ADO_T64 );
  XPCI_ADB61: IOBUF_PCI66_3 port map
              ( O => AD_I61, IO => AD_IO(61), I => AD_O61, T => OE_ADO_T64 );
  XPCI_ADB60: IOBUF_PCI66_3 port map
              ( O => AD_I60, IO => AD_IO(60), I => AD_O60, T => OE_ADO_T64 );
  XPCI_ADB59: IOBUF_PCI66_3 port map
              ( O => AD_I59, IO => AD_IO(59), I => AD_O59, T => OE_ADO_T64 );
  XPCI_ADB58: IOBUF_PCI66_3 port map
              ( O => AD_I58, IO => AD_IO(58), I => AD_O58, T => OE_ADO_T64 );
  XPCI_ADB57: IOBUF_PCI66_3 port map
              ( O => AD_I57, IO => AD_IO(57), I => AD_O57, T => OE_ADO_T64 );
  XPCI_ADB56: IOBUF_PCI66_3 port map
              ( O => AD_I56, IO => AD_IO(56), I => AD_O56, T => OE_ADO_T64 );

  XPCI_ADB55: IOBUF_PCI66_3 port map
              ( O => AD_I55, IO => AD_IO(55), I => AD_O55, T => OE_ADO_LT64);
  XPCI_ADB54: IOBUF_PCI66_3 port map
              ( O => AD_I54, IO => AD_IO(54), I => AD_O54, T => OE_ADO_LT64);
  XPCI_ADB53: IOBUF_PCI66_3 port map
              ( O => AD_I53, IO => AD_IO(53), I => AD_O53, T => OE_ADO_LT64);
  XPCI_ADB52: IOBUF_PCI66_3 port map
              ( O => AD_I52, IO => AD_IO(52), I => AD_O52, T => OE_ADO_LT64);
  XPCI_ADB51: IOBUF_PCI66_3 port map
              ( O => AD_I51, IO => AD_IO(51), I => AD_O51, T => OE_ADO_LT64);
  XPCI_ADB50: IOBUF_PCI66_3 port map
              ( O => AD_I50, IO => AD_IO(50), I => AD_O50, T => OE_ADO_LT64);
  XPCI_ADB49: IOBUF_PCI66_3 port map
              ( O => AD_I49, IO => AD_IO(49), I => AD_O49, T => OE_ADO_LT64);
  XPCI_ADB48: IOBUF_PCI66_3 port map
              ( O => AD_I48, IO => AD_IO(48), I => AD_O48, T => OE_ADO_LT64);

  XPCI_ADB47: IOBUF_PCI66_3 port map
              ( O => AD_I47, IO => AD_IO(47), I => AD_O47, T => OE_ADO_LB64);
  XPCI_ADB46: IOBUF_PCI66_3 port map
              ( O => AD_I46, IO => AD_IO(46), I => AD_O46, T => OE_ADO_LB64);
  XPCI_ADB45: IOBUF_PCI66_3 port map
              ( O => AD_I45, IO => AD_IO(45), I => AD_O45, T => OE_ADO_LB64);
  XPCI_ADB44: IOBUF_PCI66_3 port map
              ( O => AD_I44, IO => AD_IO(44), I => AD_O44, T => OE_ADO_LB64);
  XPCI_ADB43: IOBUF_PCI66_3 port map
              ( O => AD_I43, IO => AD_IO(43), I => AD_O43, T => OE_ADO_LB64);
  XPCI_ADB42: IOBUF_PCI66_3 port map
              ( O => AD_I42, IO => AD_IO(42), I => AD_O42, T => OE_ADO_LB64);
  XPCI_ADB41: IOBUF_PCI66_3 port map
              ( O => AD_I41, IO => AD_IO(41), I => AD_O41, T => OE_ADO_LB64);
  XPCI_ADB40: IOBUF_PCI66_3 port map
              ( O => AD_I40, IO => AD_IO(40), I => AD_O40, T => OE_ADO_LB64);

  XPCI_ADB39: IOBUF_PCI66_3 port map
              ( O => AD_I39, IO => AD_IO(39), I => AD_O39, T => OE_ADO_B64 );
  XPCI_ADB38: IOBUF_PCI66_3 port map
              ( O => AD_I38, IO => AD_IO(38), I => AD_O38, T => OE_ADO_B64 );
  XPCI_ADB37: IOBUF_PCI66_3 port map
              ( O => AD_I37, IO => AD_IO(37), I => AD_O37, T => OE_ADO_B64 );
  XPCI_ADB36: IOBUF_PCI66_3 port map
              ( O => AD_I36, IO => AD_IO(36), I => AD_O36, T => OE_ADO_B64 );
  XPCI_ADB35: IOBUF_PCI66_3 port map
              ( O => AD_I35, IO => AD_IO(35), I => AD_O35, T => OE_ADO_B64 );
  XPCI_ADB34: IOBUF_PCI66_3 port map
              ( O => AD_I34, IO => AD_IO(34), I => AD_O34, T => OE_ADO_B64 );
  XPCI_ADB33: IOBUF_PCI66_3 port map
              ( O => AD_I33, IO => AD_IO(33), I => AD_O33, T => OE_ADO_B64 );
  XPCI_ADB32: IOBUF_PCI66_3 port map
              ( O => AD_I32, IO => AD_IO(32), I => AD_O32, T => OE_ADO_B64 );

  XPCI_ADB31: IOBUF_PCI66_3 port map
              ( O => AD_I31, IO => AD_IO(31), I => AD_O31, T => OE_ADO_T   );
  XPCI_ADB30: IOBUF_PCI66_3 port map
              ( O => AD_I30, IO => AD_IO(30), I => AD_O30, T => OE_ADO_T   );
  XPCI_ADB29: IOBUF_PCI66_3 port map
              ( O => AD_I29, IO => AD_IO(29), I => AD_O29, T => OE_ADO_T   );
  XPCI_ADB28: IOBUF_PCI66_3 port map
              ( O => AD_I28, IO => AD_IO(28), I => AD_O28, T => OE_ADO_T   );
  XPCI_ADB27: IOBUF_PCI66_3 port map
              ( O => AD_I27, IO => AD_IO(27), I => AD_O27, T => OE_ADO_T   );
  XPCI_ADB26: IOBUF_PCI66_3 port map
              ( O => AD_I26, IO => AD_IO(26), I => AD_O26, T => OE_ADO_T   );
  XPCI_ADB25: IOBUF_PCI66_3 port map
              ( O => AD_I25, IO => AD_IO(25), I => AD_O25, T => OE_ADO_T   );
  XPCI_ADB24: IOBUF_PCI66_3 port map
              ( O => AD_I24, IO => AD_IO(24), I => AD_O24, T => OE_ADO_T   );

  XPCI_ADB23: IOBUF_PCI66_3 port map
              ( O => AD_I23, IO => AD_IO(23), I => AD_O23, T => OE_ADO_LT  );
  XPCI_ADB22: IOBUF_PCI66_3 port map
              ( O => AD_I22, IO => AD_IO(22), I => AD_O22, T => OE_ADO_LT  );
  XPCI_ADB21: IOBUF_PCI66_3 port map
              ( O => AD_I21, IO => AD_IO(21), I => AD_O21, T => OE_ADO_LT  );
  XPCI_ADB20: IOBUF_PCI66_3 port map
              ( O => AD_I20, IO => AD_IO(20), I => AD_O20, T => OE_ADO_LT  );
  XPCI_ADB19: IOBUF_PCI66_3 port map
              ( O => AD_I19, IO => AD_IO(19), I => AD_O19, T => OE_ADO_LT  );
  XPCI_ADB18: IOBUF_PCI66_3 port map
              ( O => AD_I18, IO => AD_IO(18), I => AD_O18, T => OE_ADO_LT  );
  XPCI_ADB17: IOBUF_PCI66_3 port map
              ( O => AD_I17, IO => AD_IO(17), I => AD_O17, T => OE_ADO_LT  );
  XPCI_ADB16: IOBUF_PCI66_3 port map
              ( O => AD_I16, IO => AD_IO(16), I => AD_O16, T => OE_ADO_LT  );

  XPCI_ADB15: IOBUF_PCI66_3 port map
              ( O => AD_I15, IO => AD_IO(15), I => AD_O15, T => OE_ADO_LB  );
  XPCI_ADB14: IOBUF_PCI66_3 port map
              ( O => AD_I14, IO => AD_IO(14), I => AD_O14, T => OE_ADO_LB  );
  XPCI_ADB13: IOBUF_PCI66_3 port map
              ( O => AD_I13, IO => AD_IO(13), I => AD_O13, T => OE_ADO_LB  );
  XPCI_ADB12: IOBUF_PCI66_3 port map
              ( O => AD_I12, IO => AD_IO(12), I => AD_O12, T => OE_ADO_LB  );
  XPCI_ADB11: IOBUF_PCI66_3 port map
              ( O => AD_I11, IO => AD_IO(11), I => AD_O11, T => OE_ADO_LB  );
  XPCI_ADB10: IOBUF_PCI66_3 port map
              ( O => AD_I10, IO => AD_IO(10), I => AD_O10, T => OE_ADO_LB  );
  XPCI_ADB9 : IOBUF_PCI66_3 port map
              ( O => AD_I9 , IO => AD_IO( 9), I => AD_O9 , T => OE_ADO_LB  );
  XPCI_ADB8 : IOBUF_PCI66_3 port map
              ( O => AD_I8 , IO => AD_IO( 8), I => AD_O8 , T => OE_ADO_LB  );

  XPCI_ADB7 : IOBUF_PCI66_3 port map
              ( O => AD_I7 , IO => AD_IO( 7), I => AD_O7 , T => OE_ADO_B   );
  XPCI_ADB6 : IOBUF_PCI66_3 port map
              ( O => AD_I6 , IO => AD_IO( 6), I => AD_O6 , T => OE_ADO_B   );
  XPCI_ADB5 : IOBUF_PCI66_3 port map
              ( O => AD_I5 , IO => AD_IO( 5), I => AD_O5 , T => OE_ADO_B   );
  XPCI_ADB4 : IOBUF_PCI66_3 port map
              ( O => AD_I4 , IO => AD_IO( 4), I => AD_O4 , T => OE_ADO_B   );
  XPCI_ADB3 : IOBUF_PCI66_3 port map
              ( O => AD_I3 , IO => AD_IO( 3), I => AD_O3 , T => OE_ADO_B   );
  XPCI_ADB2 : IOBUF_PCI66_3 port map
              ( O => AD_I2 , IO => AD_IO( 2), I => AD_O2 , T => OE_ADO_B   );
  XPCI_ADB1 : IOBUF_PCI66_3 port map
              ( O => AD_I1 , IO => AD_IO( 1), I => AD_O1 , T => OE_ADO_B   );
  XPCI_ADB0 : IOBUF_PCI66_3 port map
              ( O => AD_I0 , IO => AD_IO( 0), I => AD_O0 , T => OE_ADO_B   );

  XPCI_ADQ63: FDPE port map
              ( Q => AD63, D => AD_I63, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ62: FDPE port map
              ( Q => AD62, D => AD_I62, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ61: FDPE port map
              ( Q => AD61, D => AD_I61, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ60: FDPE port map
              ( Q => AD60, D => AD_I60, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ59: FDPE port map
              ( Q => AD59, D => AD_I59, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ58: FDPE port map
              ( Q => AD58, D => AD_I58, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ57: FDPE port map
              ( Q => AD57, D => AD_I57, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ56: FDPE port map
              ( Q => AD56, D => AD_I56, C => CLKX, CE => HI, PRE => RST );

  XPCI_ADQ55: FDPE port map
              ( Q => AD55, D => AD_I55, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ54: FDPE port map
              ( Q => AD54, D => AD_I54, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ53: FDPE port map
              ( Q => AD53, D => AD_I53, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ52: FDPE port map
              ( Q => AD52, D => AD_I52, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ51: FDPE port map
              ( Q => AD51, D => AD_I51, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ50: FDPE port map
              ( Q => AD50, D => AD_I50, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ49: FDPE port map
              ( Q => AD49, D => AD_I49, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ48: FDPE port map
              ( Q => AD48, D => AD_I48, C => CLKX, CE => HI, PRE => RST );

  XPCI_ADQ47: FDPE port map
              ( Q => AD47, D => AD_I47, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ46: FDPE port map
              ( Q => AD46, D => AD_I46, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ45: FDPE port map
              ( Q => AD45, D => AD_I45, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ44: FDPE port map
              ( Q => AD44, D => AD_I44, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ43: FDPE port map
              ( Q => AD43, D => AD_I43, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ42: FDPE port map
              ( Q => AD42, D => AD_I42, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ41: FDPE port map
              ( Q => AD41, D => AD_I41, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ40: FDPE port map
              ( Q => AD40, D => AD_I40, C => CLKX, CE => HI, PRE => RST );

  XPCI_ADQ39: FDPE port map
              ( Q => AD39, D => AD_I39, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ38: FDPE port map
              ( Q => AD38, D => AD_I38, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ37: FDPE port map
              ( Q => AD37, D => AD_I37, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ36: FDPE port map
              ( Q => AD36, D => AD_I36, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ35: FDPE port map
              ( Q => AD35, D => AD_I35, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ34: FDPE port map
              ( Q => AD34, D => AD_I34, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ33: FDPE port map
              ( Q => AD33, D => AD_I33, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ32: FDPE port map
              ( Q => AD32, D => AD_I32, C => CLKX, CE => HI, PRE => RST );

  XPCI_ADQ31: FDPE port map
              ( Q => AD31, D => AD_I31, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ30: FDPE port map
              ( Q => AD30, D => AD_I30, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ29: FDPE port map
              ( Q => AD29, D => AD_I29, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ28: FDPE port map
              ( Q => AD28, D => AD_I28, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ27: FDPE port map
              ( Q => AD27, D => AD_I27, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ26: FDPE port map
              ( Q => AD26, D => AD_I26, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ25: FDPE port map
              ( Q => AD25, D => AD_I25, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ24: FDPE port map
              ( Q => AD24, D => AD_I24, C => CLKX, CE => HI, PRE => RST );

  XPCI_ADQ23: FDPE port map
              ( Q => AD23, D => AD_I23, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ22: FDPE port map
              ( Q => AD22, D => AD_I22, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ21: FDPE port map
              ( Q => AD21, D => AD_I21, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ20: FDPE port map
              ( Q => AD20, D => AD_I20, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ19: FDPE port map
              ( Q => AD19, D => AD_I19, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ18: FDPE port map
              ( Q => AD18, D => AD_I18, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ17: FDPE port map
              ( Q => AD17, D => AD_I17, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ16: FDPE port map
              ( Q => AD16, D => AD_I16, C => CLKX, CE => HI, PRE => RST );

  XPCI_ADQ15: FDPE port map
              ( Q => AD15, D => AD_I15, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ14: FDPE port map
              ( Q => AD14, D => AD_I14, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ13: FDPE port map
              ( Q => AD13, D => AD_I13, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ12: FDPE port map
              ( Q => AD12, D => AD_I12, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ11: FDPE port map
              ( Q => AD11, D => AD_I11, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ10: FDPE port map
              ( Q => AD10, D => AD_I10, C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ9 : FDPE port map
              ( Q => AD9 , D => AD_I9 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ8 : FDPE port map
              ( Q => AD8 , D => AD_I8 , C => CLKX, CE => HI, PRE => RST );

  XPCI_ADQ7 : FDPE port map
              ( Q => AD7 , D => AD_I7 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ6 : FDPE port map
              ( Q => AD6 , D => AD_I6 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ5 : FDPE port map
              ( Q => AD5 , D => AD_I5 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ4 : FDPE port map
              ( Q => AD4 , D => AD_I4 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ3 : FDPE port map
              ( Q => AD3 , D => AD_I3 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ2 : FDPE port map
              ( Q => AD2 , D => AD_I2 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ1 : FDPE port map
              ( Q => AD1 , D => AD_I1 , C => CLKX, CE => HI, PRE => RST );
  XPCI_ADQ0 : FDPE port map
              ( Q => AD0 , D => AD_I0 , C => CLKX, CE => HI, PRE => RST );

  XPCI_CBB7 : IOBUF_PCI66_3 port map
              ( O => CBE_I7 , IO => CBE_IO(7), I => CBE_O7 , T => OE_CBE64 );
  XPCI_CBB6 : IOBUF_PCI66_3 port map  
              ( O => CBE_I6 , IO => CBE_IO(6), I => CBE_O6 , T => OE_CBE64 );
  XPCI_CBB5 : IOBUF_PCI66_3 port map  
              ( O => CBE_I5 , IO => CBE_IO(5), I => CBE_O5 , T => OE_CBE64 );
  XPCI_CBB4 : IOBUF_PCI66_3 port map  
              ( O => CBE_I4 , IO => CBE_IO(4), I => CBE_O4 , T => OE_CBE64 );
  XPCI_CBB3 : IOBUF_PCI66_3 port map  
              ( O => CBE_I3 , IO => CBE_IO(3), I => CBE_O3 , T => OE_CBE   );
  XPCI_CBB2 : IOBUF_PCI66_3 port map  
              ( O => CBE_I2 , IO => CBE_IO(2), I => CBE_O2 , T => OE_CBE   );
  XPCI_CBB1 : IOBUF_PCI66_3 port map  
              ( O => CBE_I1 , IO => CBE_IO(1), I => CBE_O1 , T => OE_CBE   );
  XPCI_CBB0 : IOBUF_PCI66_3 port map  
              ( O => CBE_I0 , IO => CBE_IO(0), I => CBE_O0 , T => OE_CBE   );
 
  XPCI_CBQ7 : FDPE port map
              ( Q => CBE_IN7 , D => CBE_I7 , C => CLKX, CE => HI, PRE => RST );
  XPCI_CBQ6 : FDPE port map
              ( Q => CBE_IN6 , D => CBE_I6 , C => CLKX, CE => HI, PRE => RST );
  XPCI_CBQ5 : FDPE port map
              ( Q => CBE_IN5 , D => CBE_I5 , C => CLKX, CE => HI, PRE => RST );
  XPCI_CBQ4 : FDPE port map
              ( Q => CBE_IN4 , D => CBE_I4 , C => CLKX, CE => HI, PRE => RST );
  XPCI_CBQ3 : FDPE port map
              ( Q => CBE_IN3 , D => CBE_I3 , C => CLKX, CE => HI, PRE => RST );
  XPCI_CBQ2 : FDPE port map
              ( Q => CBE_IN2 , D => CBE_I2 , C => CLKX, CE => HI, PRE => RST );
  XPCI_CBQ1 : FDPE port map
              ( Q => CBE_IN1 , D => CBE_I1 , C => CLKX, CE => HI, PRE => RST );
  XPCI_CBQ0 : FDPE port map
              ( Q => CBE_IN0 , D => CBE_I0 , C => CLKX, CE => HI, PRE => RST );

  XPCI_PAR64 : IOBUF_PCI66_3 port map
              ( O => PAR64_I, IO => PAR64_IO, I => PAR64_O, T => OE_PAR64 );
 
  XPCI_PAR : IOBUF_PCI66_3 port map
              ( O => PAR_I, IO => PAR_IO, I => PAR_O, T => OE_PAR );

  XPCI_FRAME : IOBUF_PCI66_3 port map
              ( O => FRAME_I, IO => FRAME_IO, I => FRAME_O, T => OE_FRAME );

  XPCI_REQ64 : IOBUF_PCI66_3 port map
              ( O => REQ64_I, IO => REQ64_IO, I => REQ64_O, T => OE_REQ64 );

  XPCI_TRDY : IOBUF_PCI66_3 port map
              ( O => TRDY_I, IO => TRDY_IO, I => TRDY_O, T => OE_TRDY );

  XPCI_IRDY : IOBUF_PCI66_3 port map
              ( O => IRDY_I, IO => IRDY_IO, I => IRDY_O, T => OE_IRDY );

  XPCI_STOP : IOBUF_PCI66_3 port map
              ( O => STOP_I, IO => STOP_IO, I => STOP_O, T => OE_STOP );

  XPCI_DEVSEL : IOBUF_PCI66_3 port map
              ( O => DEVSEL_I, IO => DEVSEL_IO, I => DEVSEL_O, T => OE_DEVSEL );

  XPCI_ACK64 : IOBUF_PCI66_3 port map
              ( O => ACK64_I, IO => ACK64_IO, I => ACK64_O, T => OE_ACK64 );

  XPCI_PERR : IOBUF_PCI66_3 port map
              ( O => PERR_I, IO => PERR_IO, I => PERR_O, T => OE_PERR );

  XPCI_SERR : IOBUF_PCI66_3 port map
              ( O => SERR_I, IO => SERR_IO, I => LO, T => OE_SERR );

  XPCI_REQ : OBUFT_PCI66_3 port map
              ( O => REQ_O, I => REQ_OUT, T => OE_REQ );

  XPCI_INTA : OBUFT_PCI66_3 port map
              ( O => INTA_O, I => LO, T => OE_INTA );

  XPCI_IDSEL : IBUF_PCI66_3 port map
              ( O => IDSEL_IN, I => IDSEL_I );

  XPCI_GNT : IBUF_PCI66_3 port map
              ( O => GNT_IN, I => GNT_I );

  XPCI_RST : IBUF_PCI66_3 port map
              ( O => RST_N, I => RST_I );

  XPCI_CKI : IBUFG_PCI66_3 port map
              ( O => NUB, I => PCLK );

  XPCI_CKA : BUFG port map
              ( O => CLK, I => NUB );

  XPCI_CKB : BUFG port map
              ( O => CLKX, I => NUB );

  PCI_LC : PCI_LC_I port map (
    OE_ADO_T64          => OE_ADO_T64,
    OE_ADO_T            => OE_ADO_T,
    OE_ADO_LT64         => OE_ADO_LT64,
    OE_ADO_LT           => OE_ADO_LT,
    OE_ADO_LB64         => OE_ADO_LB64,
    OE_ADO_LB           => OE_ADO_LB,
    OE_ADO_B64          => OE_ADO_B64,
    OE_ADO_B            => OE_ADO_B,
    AD63                => AD63,
    AD62                => AD62,
    AD61                => AD61,
    AD60                => AD60,
    AD59                => AD59,
    AD58                => AD58,
    AD57                => AD57,
    AD56                => AD56,
    AD55                => AD55,
    AD54                => AD54,
    AD53                => AD53,
    AD52                => AD52,
    AD51                => AD51,
    AD50                => AD50,
    AD49                => AD49,
    AD48                => AD48,
    AD47                => AD47,
    AD46                => AD46,
    AD45                => AD45,
    AD44                => AD44,
    AD43                => AD43,
    AD42                => AD42,
    AD41                => AD41,
    AD40                => AD40,
    AD39                => AD39,
    AD38                => AD38,
    AD37                => AD37,
    AD36                => AD36,
    AD35                => AD35,
    AD34                => AD34,
    AD33                => AD33,
    AD32                => AD32,
    AD31                => AD31,
    AD30                => AD30,
    AD29                => AD29,
    AD28                => AD28,
    AD27                => AD27,
    AD26                => AD26,
    AD25                => AD25,
    AD24                => AD24,
    AD23                => AD23,
    AD22                => AD22,
    AD21                => AD21,
    AD20                => AD20,
    AD19                => AD19,
    AD18                => AD18,
    AD17                => AD17,
    AD16                => AD16,
    AD15                => AD15,
    AD14                => AD14,
    AD13                => AD13,
    AD12                => AD12,
    AD11                => AD11,
    AD10                => AD10,
    AD9                 => AD9,
    AD8                 => AD8,
    AD7                 => AD7,
    AD6                 => AD6,
    AD5                 => AD5,
    AD4                 => AD4,
    AD3                 => AD3,
    AD2                 => AD2,
    AD1                 => AD1,
    AD0                 => AD0,
    AD_O63              => AD_O63,
    AD_O62              => AD_O62,
    AD_O61              => AD_O61,
    AD_O60              => AD_O60,
    AD_O59              => AD_O59,
    AD_O58              => AD_O58,
    AD_O57              => AD_O57,
    AD_O56              => AD_O56,
    AD_O55              => AD_O55,
    AD_O54              => AD_O54,
    AD_O53              => AD_O53,
    AD_O52              => AD_O52,
    AD_O51              => AD_O51,
    AD_O50              => AD_O50,
    AD_O49              => AD_O49,
    AD_O48              => AD_O48,
    AD_O47              => AD_O47,
    AD_O46              => AD_O46,
    AD_O45              => AD_O45,
    AD_O44              => AD_O44,
    AD_O43              => AD_O43,
    AD_O42              => AD_O42,
    AD_O41              => AD_O41,
    AD_O40              => AD_O40,
    AD_O39              => AD_O39,
    AD_O38              => AD_O38,
    AD_O37              => AD_O37,
    AD_O36              => AD_O36,
    AD_O35              => AD_O35,
    AD_O34              => AD_O34,
    AD_O33              => AD_O33,
    AD_O32              => AD_O32,
    AD_O31              => AD_O31,
    AD_O30              => AD_O30,
    AD_O29              => AD_O29,
    AD_O28              => AD_O28,
    AD_O27              => AD_O27,
    AD_O26              => AD_O26,
    AD_O25              => AD_O25,
    AD_O24              => AD_O24,
    AD_O23              => AD_O23,
    AD_O22              => AD_O22,
    AD_O21              => AD_O21,
    AD_O20              => AD_O20,
    AD_O19              => AD_O19,
    AD_O18              => AD_O18,
    AD_O17              => AD_O17,
    AD_O16              => AD_O16,
    AD_O15              => AD_O15,
    AD_O14              => AD_O14,
    AD_O13              => AD_O13,
    AD_O12              => AD_O12,
    AD_O11              => AD_O11,
    AD_O10              => AD_O10,
    AD_O9               => AD_O9,
    AD_O8               => AD_O8,
    AD_O7               => AD_O7,
    AD_O6               => AD_O6,
    AD_O5               => AD_O5,
    AD_O4               => AD_O4,
    AD_O3               => AD_O3,
    AD_O2               => AD_O2,
    AD_O1               => AD_O1,
    AD_O0               => AD_O0,

    OE_CBE64            => OE_CBE64,
    OE_CBE              => OE_CBE,
    CBE_I7              => CBE_I7,
    CBE_I6              => CBE_I6,
    CBE_I5              => CBE_I5,
    CBE_I4              => CBE_I4,
    CBE_I3              => CBE_I3,
    CBE_I2              => CBE_I2,
    CBE_I1              => CBE_I1,
    CBE_I0              => CBE_I0,
    CBE_IN7             => CBE_IN7,
    CBE_IN6             => CBE_IN6,
    CBE_IN5             => CBE_IN5,
    CBE_IN4             => CBE_IN4,
    CBE_IN3             => CBE_IN3,
    CBE_IN2             => CBE_IN2,
    CBE_IN1             => CBE_IN1,
    CBE_IN0             => CBE_IN0,
    CBE_O7              => CBE_O7,
    CBE_O6              => CBE_O6,
    CBE_O5              => CBE_O5,
    CBE_O4              => CBE_O4,
    CBE_O3              => CBE_O3,
    CBE_O2              => CBE_O2,
    CBE_O1              => CBE_O1,
    CBE_O0              => CBE_O0,

    OE_PAR64            => OE_PAR64,
    PAR64_I             => PAR64_I,
    PAR64_O             => PAR64_O,

    OE_PAR              => OE_PAR,
    PAR_I               => PAR_I,
    PAR_O               => PAR_O,

    OE_FRAME            => OE_FRAME,
    FRAME_I             => FRAME_I,
    FRAME_O             => FRAME_O,

    OE_REQ64            => OE_REQ64,
    REQ64_I             => REQ64_I,
    REQ64_O             => REQ64_O,

    OE_TRDY             => OE_TRDY,
    TRDY_I              => TRDY_I,
    TRDY_O              => TRDY_O,

    OE_IRDY             => OE_IRDY,
    IRDY_I              => IRDY_I,
    IRDY_O              => IRDY_O,

    OE_STOP             => OE_STOP,
    STOP_I              => STOP_I,
    STOP_O              => STOP_O,

    OE_DEVSEL           => OE_DEVSEL,
    DEVSEL_I            => DEVSEL_I,
    DEVSEL_O            => DEVSEL_O,

    OE_ACK64            => OE_ACK64,
    ACK64_I             => ACK64_I,
    ACK64_O             => ACK64_O,

    IDSEL_IN            => IDSEL_IN,

    OE_INTA             => OE_INTA,

    OE_PERR             => OE_PERR,
    PERR_I              => PERR_I,
    PERR_O              => PERR_O,

    OE_SERR             => OE_SERR,
    SERR_I              => SERR_I,

    OE_REQ              => OE_REQ,
    REQ_OUT             => REQ_OUT,

    GNT_IN              => GNT_IN,

    RST_N               => RST_N,

    CFG255              => CFG(255),
    CFG254              => CFG(254),
    CFG253              => CFG(253),
    CFG252              => CFG(252),
    CFG251              => CFG(251),
    CFG250              => CFG(250),
    CFG249              => CFG(249),
    CFG248              => CFG(248),
    CFG247              => CFG(247),
    CFG246              => CFG(246),
    CFG245              => CFG(245),
    CFG244              => CFG(244),
    CFG243              => CFG(243),
    CFG242              => CFG(242),
    CFG241              => CFG(241),
    CFG240              => CFG(240),
    CFG239              => CFG(239),
    CFG238              => CFG(238),
    CFG237              => CFG(237),
    CFG236              => CFG(236),
    CFG235              => CFG(235),
    CFG234              => CFG(234),
    CFG233              => CFG(233),
    CFG232              => CFG(232),
    CFG231              => CFG(231),
    CFG230              => CFG(230),
    CFG229              => CFG(229),
    CFG228              => CFG(228),
    CFG227              => CFG(227),
    CFG226              => CFG(226),
    CFG225              => CFG(225),
    CFG224              => CFG(224),
    CFG223              => CFG(223),
    CFG222              => CFG(222),
    CFG221              => CFG(221),
    CFG220              => CFG(220),
    CFG219              => CFG(219),
    CFG218              => CFG(218),
    CFG217              => CFG(217),
    CFG216              => CFG(216),
    CFG215              => CFG(215),
    CFG214              => CFG(214),
    CFG213              => CFG(213),
    CFG212              => CFG(212),
    CFG211              => CFG(211),
    CFG210              => CFG(210),
    CFG209              => CFG(209),
    CFG208              => CFG(208),
    CFG207              => CFG(207),
    CFG206              => CFG(206),
    CFG205              => CFG(205),
    CFG204              => CFG(204),
    CFG203              => CFG(203),
    CFG202              => CFG(202),
    CFG201              => CFG(201),
    CFG200              => CFG(200),
    CFG199              => CFG(199),
    CFG198              => CFG(198),
    CFG197              => CFG(197),
    CFG196              => CFG(196),
    CFG195              => CFG(195),
    CFG194              => CFG(194),
    CFG193              => CFG(193),
    CFG192              => CFG(192),
    CFG191              => CFG(191),
    CFG190              => CFG(190),
    CFG189              => CFG(189),
    CFG188              => CFG(188),
    CFG187              => CFG(187),
    CFG186              => CFG(186),
    CFG185              => CFG(185),
    CFG184              => CFG(184),
    CFG183              => CFG(183),
    CFG182              => CFG(182),
    CFG181              => CFG(181),
    CFG180              => CFG(180),
    CFG179              => CFG(179),
    CFG178              => CFG(178),
    CFG177              => CFG(177),
    CFG176              => CFG(176),
    CFG175              => CFG(175),
    CFG174              => CFG(174),
    CFG173              => CFG(173),
    CFG172              => CFG(172),
    CFG171              => CFG(171),
    CFG170              => CFG(170),
    CFG169              => CFG(169),
    CFG168              => CFG(168),
    CFG167              => CFG(167),
    CFG166              => CFG(166),
    CFG165              => CFG(165),
    CFG164              => CFG(164),
    CFG163              => CFG(163),
    CFG162              => CFG(162),
    CFG161              => CFG(161),
    CFG160              => CFG(160),
    CFG159              => CFG(159),
    CFG158              => CFG(158),
    CFG157              => CFG(157),
    CFG156              => CFG(156),
    CFG155              => CFG(155),
    CFG154              => CFG(154),
    CFG153              => CFG(153),
    CFG152              => CFG(152),
    CFG151              => CFG(151),
    CFG150              => CFG(150),
    CFG149              => CFG(149),
    CFG148              => CFG(148),
    CFG147              => CFG(147),
    CFG146              => CFG(146),
    CFG145              => CFG(145),
    CFG144              => CFG(144),
    CFG143              => CFG(143),
    CFG142              => CFG(142),
    CFG141              => CFG(141),
    CFG140              => CFG(140),
    CFG139              => CFG(139),
    CFG138              => CFG(138),
    CFG137              => CFG(137),
    CFG136              => CFG(136),
    CFG135              => CFG(135),
    CFG134              => CFG(134),
    CFG133              => CFG(133),
    CFG132              => CFG(132),
    CFG131              => CFG(131),
    CFG130              => CFG(130),
    CFG129              => CFG(129),
    CFG128              => CFG(128),
    CFG127              => CFG(127),
    CFG126              => CFG(126),
    CFG125              => CFG(125),
    CFG124              => CFG(124),
    CFG123              => CFG(123),
    CFG122              => CFG(122),
    CFG121              => CFG(121),
    CFG120              => CFG(120),
    CFG119              => CFG(119),
    CFG118              => CFG(118),
    CFG117              => CFG(117),
    CFG116              => CFG(116),
    CFG115              => CFG(115),
    CFG114              => CFG(114),
    CFG113              => CFG(113),
    CFG112              => CFG(112),
    CFG111              => CFG(111),
    CFG110              => CFG(110),
    CFG109              => CFG(109),
    CFG108              => CFG(108),
    CFG107              => CFG(107),
    CFG106              => CFG(106),
    CFG105              => CFG(105),
    CFG104              => CFG(104),
    CFG103              => CFG(103),
    CFG102              => CFG(102),
    CFG101              => CFG(101),
    CFG100              => CFG(100),
    CFG99               => CFG(99),
    CFG98               => CFG(98),
    CFG97               => CFG(97),
    CFG96               => CFG(96),
    CFG95               => CFG(95),
    CFG94               => CFG(94),
    CFG93               => CFG(93),
    CFG92               => CFG(92),
    CFG91               => CFG(91),
    CFG90               => CFG(90),
    CFG89               => CFG(89),
    CFG88               => CFG(88),
    CFG87               => CFG(87),
    CFG86               => CFG(86),
    CFG85               => CFG(85),
    CFG84               => CFG(84),
    CFG83               => CFG(83),
    CFG82               => CFG(82),
    CFG81               => CFG(81),
    CFG80               => CFG(80),
    CFG79               => CFG(79),
    CFG78               => CFG(78),
    CFG77               => CFG(77),
    CFG76               => CFG(76),
    CFG75               => CFG(75),
    CFG74               => CFG(74),
    CFG73               => CFG(73),
    CFG72               => CFG(72),
    CFG71               => CFG(71),
    CFG70               => CFG(70),
    CFG69               => CFG(69),
    CFG68               => CFG(68),
    CFG67               => CFG(67),
    CFG66               => CFG(66),
    CFG65               => CFG(65),
    CFG64               => CFG(64),
    CFG63               => CFG(63),
    CFG62               => CFG(62),
    CFG61               => CFG(61),
    CFG60               => CFG(60),
    CFG59               => CFG(59),
    CFG58               => CFG(58),
    CFG57               => CFG(57),
    CFG56               => CFG(56),
    CFG55               => CFG(55),
    CFG54               => CFG(54),
    CFG53               => CFG(53),
    CFG52               => CFG(52),
    CFG51               => CFG(51),
    CFG50               => CFG(50),
    CFG49               => CFG(49),
    CFG48               => CFG(48),
    CFG47               => CFG(47),
    CFG46               => CFG(46),
    CFG45               => CFG(45),
    CFG44               => CFG(44),
    CFG43               => CFG(43),
    CFG42               => CFG(42),
    CFG41               => CFG(41),
    CFG40               => CFG(40),
    CFG39               => CFG(39),
    CFG38               => CFG(38),
    CFG37               => CFG(37),
    CFG36               => CFG(36),
    CFG35               => CFG(35),
    CFG34               => CFG(34),
    CFG33               => CFG(33),
    CFG32               => CFG(32),
    CFG31               => CFG(31),
    CFG30               => CFG(30),
    CFG29               => CFG(29),
    CFG28               => CFG(28),
    CFG27               => CFG(27),
    CFG26               => CFG(26),
    CFG25               => CFG(25),
    CFG24               => CFG(24),
    CFG23               => CFG(23),
    CFG22               => CFG(22),
    CFG21               => CFG(21),
    CFG20               => CFG(20),
    CFG19               => CFG(19),
    CFG18               => CFG(18),
    CFG17               => CFG(17),
    CFG16               => CFG(16),
    CFG15               => CFG(15),
    CFG14               => CFG(14),
    CFG13               => CFG(13),
    CFG12               => CFG(12),
    CFG11               => CFG(11),
    CFG10               => CFG(10),
    CFG9                => CFG(9),
    CFG8                => CFG(8),
    CFG7                => CFG(7),
    CFG6                => CFG(6),
    CFG5                => CFG(5),
    CFG4                => CFG(4),
    CFG3                => CFG(3),
    CFG2                => CFG(2),
    CFG1                => CFG(1),
    CFG0                => CFG(0),

    FRAMEQ_N            => FRAMEQ_N,
    REQ64Q_N            => REQ64Q_N,
    TRDYQ_N             => TRDYQ_N,
    IRDYQ_N             => IRDYQ_N,
    STOPQ_N             => STOPQ_N,
    DEVSELQ_N           => DEVSELQ_N,
    ACK64Q_N            => ACK64Q_N,

    ADDR31              => ADDR(31),
    ADDR30              => ADDR(30),
    ADDR29              => ADDR(29),
    ADDR28              => ADDR(28),
    ADDR27              => ADDR(27),
    ADDR26              => ADDR(26),
    ADDR25              => ADDR(25),
    ADDR24              => ADDR(24),
    ADDR23              => ADDR(23),
    ADDR22              => ADDR(22),
    ADDR21              => ADDR(21),
    ADDR20              => ADDR(20),
    ADDR19              => ADDR(19),
    ADDR18              => ADDR(18),
    ADDR17              => ADDR(17),
    ADDR16              => ADDR(16),
    ADDR15              => ADDR(15),
    ADDR14              => ADDR(14),
    ADDR13              => ADDR(13),
    ADDR12              => ADDR(12),
    ADDR11              => ADDR(11),
    ADDR10              => ADDR(10),
    ADDR9               => ADDR(9),
    ADDR8               => ADDR(8),
    ADDR7               => ADDR(7),
    ADDR6               => ADDR(6),
    ADDR5               => ADDR(5),
    ADDR4               => ADDR(4),
    ADDR3               => ADDR(3),
    ADDR2               => ADDR(2),
    ADDR1               => ADDR(1),
    ADDR0               => ADDR(0),

    ADIO63              => ADIO(63),
    ADIO62              => ADIO(62),
    ADIO61              => ADIO(61),
    ADIO60              => ADIO(60),
    ADIO59              => ADIO(59),
    ADIO58              => ADIO(58),
    ADIO57              => ADIO(57),
    ADIO56              => ADIO(56),
    ADIO55              => ADIO(55),
    ADIO54              => ADIO(54),
    ADIO53              => ADIO(53),
    ADIO52              => ADIO(52),
    ADIO51              => ADIO(51),
    ADIO50              => ADIO(50),
    ADIO49              => ADIO(49),
    ADIO48              => ADIO(48),
    ADIO47              => ADIO(47),
    ADIO46              => ADIO(46),
    ADIO45              => ADIO(45),
    ADIO44              => ADIO(44),
    ADIO43              => ADIO(43),
    ADIO42              => ADIO(42),
    ADIO41              => ADIO(41),
    ADIO40              => ADIO(40),
    ADIO39              => ADIO(39),
    ADIO38              => ADIO(38),
    ADIO37              => ADIO(37),
    ADIO36              => ADIO(36),
    ADIO35              => ADIO(35),
    ADIO34              => ADIO(34),
    ADIO33              => ADIO(33),
    ADIO32              => ADIO(32),
    ADIO31              => ADIO(31),
    ADIO30              => ADIO(30),
    ADIO29              => ADIO(29),
    ADIO28              => ADIO(28),
    ADIO27              => ADIO(27),
    ADIO26              => ADIO(26),
    ADIO25              => ADIO(25),
    ADIO24              => ADIO(24),
    ADIO23              => ADIO(23),
    ADIO22              => ADIO(22),
    ADIO21              => ADIO(21),
    ADIO20              => ADIO(20),
    ADIO19              => ADIO(19),
    ADIO18              => ADIO(18),
    ADIO17              => ADIO(17),
    ADIO16              => ADIO(16),
    ADIO15              => ADIO(15),
    ADIO14              => ADIO(14),
    ADIO13              => ADIO(13),
    ADIO12              => ADIO(12),
    ADIO11              => ADIO(11),
    ADIO10              => ADIO(10),
    ADIO9               => ADIO(9),
    ADIO8               => ADIO(8),
    ADIO7               => ADIO(7),
    ADIO6               => ADIO(6),
    ADIO5               => ADIO(5),
    ADIO4               => ADIO(4),
    ADIO3               => ADIO(3),
    ADIO2               => ADIO(2),
    ADIO1               => ADIO(1),
    ADIO0               => ADIO(0),

    CFG_VLD             => CFG_VLD,
    CFG_HIT             => CFG_HIT,
    C_TERM              => C_TERM,
    C_READY             => C_READY,
    ADDR_VLD            => ADDR_VLD,
    BASE_HIT7           => BASE_HIT(7),
    BASE_HIT6           => BASE_HIT(6),
    BASE_HIT5           => BASE_HIT(5),
    BASE_HIT4           => BASE_HIT(4),
    BASE_HIT3           => BASE_HIT(3),
    BASE_HIT2           => BASE_HIT(2),
    BASE_HIT1           => BASE_HIT(1),
    BASE_HIT0           => BASE_HIT(0),
    S_CYCLE64           => S_CYCLE64,
    S_TERM              => S_TERM,
    S_READY             => S_READY,
    S_ABORT             => S_ABORT,
    S_WRDN              => S_WRDN,
    S_SRC_EN            => S_SRC_EN,
    S_DATA_VLD          => S_DATA_VLD,
    S_CBE7              => S_CBE(7),
    S_CBE6              => S_CBE(6),
    S_CBE5              => S_CBE(5),
    S_CBE4              => S_CBE(4),
    S_CBE3              => S_CBE(3),
    S_CBE2              => S_CBE(2),
    S_CBE1              => S_CBE(1),
    S_CBE0              => S_CBE(0),
    PCI_CMD15           => PCI_CMD(15),
    PCI_CMD14           => PCI_CMD(14),
    PCI_CMD13           => PCI_CMD(13),
    PCI_CMD12           => PCI_CMD(12),
    PCI_CMD11           => PCI_CMD(11),
    PCI_CMD10           => PCI_CMD(10),
    PCI_CMD9            => PCI_CMD(9),
    PCI_CMD8            => PCI_CMD(8),
    PCI_CMD7            => PCI_CMD(7),
    PCI_CMD6            => PCI_CMD(6),
    PCI_CMD5            => PCI_CMD(5),
    PCI_CMD4            => PCI_CMD(4),
    PCI_CMD3            => PCI_CMD(3),
    PCI_CMD2            => PCI_CMD(2),
    PCI_CMD1            => PCI_CMD(1),
    PCI_CMD0            => PCI_CMD(0),

    REQUEST             => REQUEST,
    REQUEST64           => REQUEST64,
    REQUESTHOLD         => REQUESTHOLD,
    COMPLETE            => COMPLETE,

    M_WRDN              => M_WRDN,
    M_READY             => M_READY,
    M_SRC_EN            => M_SRC_EN,
    M_DATA_VLD          => M_DATA_VLD,
    M_CBE7              => M_CBE(7),
    M_CBE6              => M_CBE(6),
    M_CBE5              => M_CBE(5),
    M_CBE4              => M_CBE(4),
    M_CBE3              => M_CBE(3),
    M_CBE2              => M_CBE(2),
    M_CBE1              => M_CBE(1),
    M_CBE0              => M_CBE(0),
    TIME_OUT            => TIME_OUT,
    M_FAIL64            => M_FAIL64,
    CFG_SELF            => CFG_SELF,

    M_DATA              => M_DATA,
    DR_BUS              => DR_BUS,
    I_IDLE              => I_IDLE,
    M_ADDR_N            => M_ADDR_N,
    IDLE                => IDLE,
    B_BUSY              => B_BUSY,
    S_DATA              => S_DATA,
    BACKOFF             => BACKOFF,

    SLOT64              => SLOT64,
    INTR_N              => INTR_N,
    PERRQ_N             => PERRQ_N,
    SERRQ_N             => SERRQ_N,
    KEEPOUT             => KEEPOUT,

    CSR39               => CSR(39),
    CSR38               => CSR(38),
    CSR37               => CSR(37),
    CSR36               => CSR(36),
    CSR35               => CSR(35),
    CSR34               => CSR(34),
    CSR33               => CSR(33),
    CSR32               => CSR(32),
    CSR31               => CSR(31),
    CSR30               => CSR(30),
    CSR29               => CSR(29),
    CSR28               => CSR(28),
    CSR27               => CSR(27),
    CSR26               => CSR(26),
    CSR25               => CSR(25),
    CSR24               => CSR(24),
    CSR23               => CSR(23),
    CSR22               => CSR(22),
    CSR21               => CSR(21),
    CSR20               => CSR(20),
    CSR19               => CSR(19),
    CSR18               => CSR(18),
    CSR17               => CSR(17),
    CSR16               => CSR(16),
    CSR15               => CSR(15),
    CSR14               => CSR(14),
    CSR13               => CSR(13),
    CSR12               => CSR(12),
    CSR11               => CSR(11),
    CSR10               => CSR(10),
    CSR9                => CSR(9),
    CSR8                => CSR(8),
    CSR7                => CSR(7),
    CSR6                => CSR(6),
    CSR5                => CSR(5),
    CSR4                => CSR(4),
    CSR3                => CSR(3),
    CSR2                => CSR(2),
    CSR1                => CSR(1),
    CSR0                => CSR(0),
    SUB_DATA31          => SUB_DATA(31),
    SUB_DATA30          => SUB_DATA(30),
    SUB_DATA29          => SUB_DATA(29),
    SUB_DATA28          => SUB_DATA(28),
    SUB_DATA27          => SUB_DATA(27),
    SUB_DATA26          => SUB_DATA(26),
    SUB_DATA25          => SUB_DATA(25),
    SUB_DATA24          => SUB_DATA(24),
    SUB_DATA23          => SUB_DATA(23),
    SUB_DATA22          => SUB_DATA(22),
    SUB_DATA21          => SUB_DATA(21),
    SUB_DATA20          => SUB_DATA(20),
    SUB_DATA19          => SUB_DATA(19),
    SUB_DATA18          => SUB_DATA(18),
    SUB_DATA17          => SUB_DATA(17),
    SUB_DATA16          => SUB_DATA(16),
    SUB_DATA15          => SUB_DATA(15),
    SUB_DATA14          => SUB_DATA(14),
    SUB_DATA13          => SUB_DATA(13),
    SUB_DATA12          => SUB_DATA(12),
    SUB_DATA11          => SUB_DATA(11),
    SUB_DATA10          => SUB_DATA(10),
    SUB_DATA9           => SUB_DATA(9),
    SUB_DATA8           => SUB_DATA(8),
    SUB_DATA7           => SUB_DATA(7),
    SUB_DATA6           => SUB_DATA(6),
    SUB_DATA5           => SUB_DATA(5),
    SUB_DATA4           => SUB_DATA(4),
    SUB_DATA3           => SUB_DATA(3),
    SUB_DATA2           => SUB_DATA(2),
    SUB_DATA1           => SUB_DATA(1),
    SUB_DATA0           => SUB_DATA(0),
    CLK                 => CLK,
    CLKX                => CLKX,
    RST                 => RST
  );


end WRAPPER;
