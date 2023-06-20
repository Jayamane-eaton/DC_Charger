
clc;  close all;  
clear all;


folders = [ "DCChrgr_AFE_ert_rtw/" "slprj/ert/_sharedutils/" ];
for i = 1:numel(folders)
    if exist(char(extractBefore(folders(i),'/')), 'dir')
        rmdir(char(extractBefore(folders(i),'/')), 's');
    end
end
  
clear(  'folders', 'i');

%*************************GENERAL SETTINGS********************************%
PI = 22/7;

%*************************************************************************%


%*************************TIMMING SETTINGS********************************%
Swtch_Freq_AFE = 5000;%Swtch_Freq_AFE = 40000
Swtch_Rate_AFE= 1/Swtch_Freq_AFE;

% Cntrl_Freq_AFE= Swtch_Freq_AFE/4;
% Cntrl_Rate_AFE= 1/Cntrl_Freq_AFE;

Cntrl_Freq_AFE= 5000;
Cntrl_Rate_AFE= 1/Cntrl_Freq_AFE;

%************************************************************************%

%*************************FAULT DETECTION SETTINGS***********************%
Fault_detection_per_s = Swtch_Freq_AFE;
Fault_Counts_perms = Fault_detection_per_s/1000;

%************************************************************************%


%***********************GRID PARAMETERS SETTINGS*************************%

GRID_NORM_LL_VOLT = 415;
GRID_NORM_PH_VOLT = GRID_NORM_LL_VOLT/sqrt(3);
GRID_NORM_PH_VOLT_PEAK = GRID_NORM_PH_VOLT*sqrt(2);
GRID_NORM_FREQ = 50;
AFE_DC_INIT_VOLT = GRID_NORM_LL_VOLT*1.35;

%************************************************************************%

%***********************ADC MEASUREMENT SETTINGS*************************%
ADC_SAMPLE_RATE = Swtch_Rate_AFE/8;%Swtch_Rate_AFE/10
DC_VOLT_ADC_GAIN = 4095/3.3/2;
DC_VOLT_SNSR_GAIN= 3.3/1000;

DC_CURR_ADC_GAIN = 4095/3.3/2;
DC_CURR_SNSR_GAIN= 3.3/100;

GRID_VOLT_ADC_OFFSET = 2048;

ADC_MAX_COUNT=2^12-1;

GRID_VOLT_SNSR_GAIN= 3.3/240/1.414;     %VLN= 240 *1.414/3.3 
GRID_VOLT_ADC_GAIN=4095/3.3/2;

GRID_CURR_SNSR_GAIN=3.3/50/1.414;
GRID_CURR_ADC_GAIN=4096/3.3/2;

%************************************************************************%
%**************************PWM SETTINGS**********************************%
% CPU_CLOCK_FREQUENCY= 120e6;
% PWM_FREQUENCY = 100e3;

% PWM_COUNTER_MAX_VALUE = CPU_CLOCK_FREQUENCY/PWM_FREQUENCY;
% ANGLE_RAD_TO_PWM_COUNT_RATIO = PWM_COUNTER_MAX_VALUE/(2*PI);
% ANGLE_DEG_TO_PWM_COUNT_RATIO = PWM_COUNTER_MAX_VALUE/(360);


% PWM_COUNT_UPPER_LIMIT = 200;
% PWM_COUNT_LOWER_LIMIT = 35;
%************************************************************************%
%***********************PWM DUTY SETTINGS**************************%
VDC_UPPER_LIM_SVPWM = 800;
VDC_LOWER_LIM_SVPWM = 400;
DUTY_COUNT_UPPER_LMIT = 1500;
DUTY_COUNT_LOWER_LMIT = 0;
HALF_DUTY_PERIOD = 750;
FULL_DUTY_PERIOD = 1500;
%*******************************************************************%

%****************************PLL SETTINGS********************************%
GRID_NORM_FREQ = 50;
PLL_PI_KP = 0.7861; %1.0
PLL_PI_KI = 31.8066; %0.01 %0.0039305
PLL_RATE = Swtch_Rate_AFE;
PLL_PI_INTGRL_RESET=1;
PLL_PI_UPPER_LIMIT =2*PI*GRID_NORM_FREQ;
PLL_PI_LOWER_LIMIT =-2*PI*GRID_NORM_FREQ;

PLL_FREQ_UPP_LIMIT= (GRID_NORM_FREQ + (GRID_NORM_FREQ*5/100))*2*PI;
PLL_FREQ_LOW_LIMIT= (GRID_NORM_FREQ - (GRID_NORM_FREQ*5/100))*2*PI;

%Added for PLL_lock detection
PLL_VQ_ESTIMETED = 0;
PLL_VD_ESTIMETED = -(GRID_NORM_PH_VOLT_PEAK*3/2); %( 3/2 * Vm )
PLL_VD_ERROR_LIMIT = abs(PLL_VD_ESTIMETED)*10/100; 
%40;% if 10% error limit = abs(PLL_VD_ESTIMETED)*10/100
PLL_VQ_ERROR_LIMIT = PLL_VQ_ESTIMETED + 20; 
% (+ or - 10% error calculation in q)

%************************************************************************%


%****************************DCV PI CTRL SETTINGS************************%

DCV_CTRL_PI_KP = 1.0;
DCV_CTRL_PI_KI = 0.01;
DCV_CTRL_RATE = Cntrl_Rate_AFE;
DCV_CTRL_PI_INTGRL_RESET=1;
DCV_CTRL_PI_UPPER_LIMIT =PI;
DCV_CTRL_PI_LOWER_LIMIT =1;

%************************************************************************%

%****************************ID PI CTRL SETTINGS************************%

% ID_CTRL_PI_KP = 1.0;
% ID_CTRL_PI_KI = 0.01;
ID_CTRL_PI_KP = 4.272;
ID_CTRL_PI_KI = 10.053;
ID_CTRL_RATE = Cntrl_Rate_AFE;
ID_CTRL_PI_INTGRL_RESET=1;
% ID_CTRL_PI_UPPER_LIMIT =PI;
% ID_CTRL_PI_LOWER_LIMIT =1;
ID_CTRL_PI_UPPER_LIMIT =50;
ID_CTRL_PI_LOWER_LIMIT =-50;

%************************************************************************%
%****************************IQ PI CTRL SETTINGS************************%

% IQ_CTRL_PI_KP = 1.0;
% IQ_CTRL_PI_KI = 0.01;
IQ_CTRL_PI_KP = 4.272;
IQ_CTRL_PI_KI = 10.053;
IQ_CTRL_RATE = Cntrl_Rate_AFE;
IQ_CTRL_PI_INTGRL_RESET=1;
% IQ_CTRL_PI_UPPER_LIMIT =PI;
% IQ_CTRL_PI_LOWER_LIMIT =1;
IQ_CTRL_PI_UPPER_LIMIT =40;
IQ_CTRL_PI_LOWER_LIMIT =-40;

%************************************************************************%
%****************************OPERATING MODES*****************************%

MAX_POWER = 30000;
AFE_EFFICIENCY = 0.97;
MAX_CHARGER_CURRENT = 60.0;
MAX_BATT_VOLTAGE = 1000.0;
MIN_BATT_VOLTAGE = 400.0;

CC_MODE = 1;
CV_MODE = 2;

G2V = 1;
V2X = 2;

OPEN_LOOP_CONTROL = 0;
CLOSED_LOOP_CONTROL = 1;

OPEN_LOOP_DEFAULT_DUTY_VALUE = 1.0;

%************************************************************************%

%***********************ELECTRICAL PARAM FOR SIM*************************%
% Targets for the simulation model
RecPlimit =2*30e3;
RecVdc = 750;
Vdc_tgt = 690;


Vbatt = 420;
Rsbatt = 0.01;

% Vbatt_tgt = 580;
Cbus = 48e-3;
L_battconv = 17.2e-6;
C_battconv = 400e-6;


UseThreeWireControl =1;

INDUCTANCE = 0.01e-3; %Henary

DCV_REF =750;


Rc = 0.01E-3;
Lc = 120E-6;
Lg = 120E-6;
Rd = 1;
Cf = 2E-6;
Cf1 = 10E-6;
GV = 0.1;
BWL = 6280*0.8;
Vp = 240*1;
Vph = 240*0.1;
Id_lim = 80;
Td = 500E-9;
fs = 20000;
M = 0.94;
Vdc_ref = 700;
Po = 25000;
Rl = Vdc_ref*Vdc_ref/Po;
Cdc = 1000E-6;
Ki_dc = 1/(Rl*Cdc);
BW_dc = 80;
G_dc = 2*3.14*BW_dc*Cdc;
Ub = 10/100;

%************************************************************************%
