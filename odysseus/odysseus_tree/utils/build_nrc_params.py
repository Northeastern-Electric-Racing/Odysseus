#!/usr/bin/python

import sys
import re

'''
First arg --> STA (0) or AP (1)
Second arg --> path/to/cmdline.txt

'''


##################################################################################
# Firmware Conf.
model = 7292      # 7292/7393/7394
fw_download = 1         # 0(FW Download off) or 1(FW Download on)
fw_name = 'uni_s1g.bin'
##################################################################################
# DEBUG Conf.
# NRC Driver log
driver_debug = 0         # NRC Driver debug option : 0(off) or 1(on)
dbg_flow_control = 0         # Print TRX slot and credit status in real-time
# --------------------------------------------------------------------------------#
#################################################################################
# RF Conf.
bd_name = ''       # board data name (bd defines max TX Power per CH/MCS/CC)
# specify your bd name here. If not, follow naming rules in strBDName()
##################################################################################

##################################################################################
# MAC Conf.
# S1G Short Beacon (AP & MESH Only)
#  If disabled, AP sends only S1G long beacon every BI
#  Recommend using S1G short beacon for network efficiency (Default: enabled)
short_bcn_enable = 1        # 0 (disable) or 1 (enable)
# --------------------------------------------------------------------------------#
# Legacy ACK enable (AP & STA)
#  If disabled, AP/STA sends only NDP ack frame
#  Recommend using NDP ack mode  (Default: disable)
legacy_ack_enable = 0        # 0 (NDP ack mode) or 1 (legacy ack mode)
# --------------------------------------------------------------------------------#
# Beacon Bypass enable (STA only)
#  If enabled, STA receives beacon frame from other APs even connected
#  Recommend that STA only receives beacon frame from AP connected while connecting  (Default: disable)
# 0 (Receive beacon frame from only AP connected while connecting)
beacon_bypass_enable = 0
# 1 (Receive beacon frame from all APs even while connecting)
# --------------------------------------------------------------------------------#
# AMPDU (Aggregated MPDU)
#  Enable AMPDU for full channel utilization and throughput enhancement (Default: auto)
#  disable(0): AMPDU is deactivated
#   manual(1): AMPDU is activated and BA(Block ACK) session is made by manual
#     auto(2): AMPDU is activated and BA(Block ACK) session is made automatically
ampdu_enable = 2        # 0 (disable) 1 (manual) 2 (auto)
# --------------------------------------------------------------------------------#
# 1M NDP (Block) ACK
#  Enable 1M NDP ACK on 2/4MHz BW instead of 2M NDP ACK
#  Note: if enabled, throughput can be decreased on high MCS
ndp_ack_1m = 0        # 0 (disable) or 1 (enable)
# --------------------------------------------------------------------------------#
# NDP Probe Request
#  For STA, "scan_ssid=1" in wpa_supplicant's conf should be set to use
ndp_preq = 0        # 0 (Legacy Probe Req) 1 (NDP Probe Req)
# --------------------------------------------------------------------------------#
# CQM (Channel Quality Manager) (STA Only)
#  STA can disconnect according to Channel Quality (Beacon Loss or Poor Signal)
#  Note: if disabled, STA keeps connection regardless of Channel Quality
cqm_enable = 1        # 0 (disable) or 1 (enable)
# --------------------------------------------------------------------------------#
# --------------------------------------------------------------------------------#
# Power Save (STA Only)
#  3-types PS: (0)Always on (2)Deep_Sleep(TIM) (3)Deep_Sleep(nonTIM)
#     TIM Mode : check beacons during PS to receive BU from AP
#  nonTIM Mode : Not check beacons during PS (just wake up by TX or EXT INT)
power_save = 0        # STA (power save type 0~3)
# STA (sleep duration only for nonTIM deepsleep) (min:1000ms)
sleep_duration = '3s'
listen_interval = 1000     # STA (listen interval in BI unit) (max:65535)
# Listen Interval time should be less than bss_max_idle time to avoid association reject
# --------------------------------------------------------------------------------#
# BSS MAX IDLE PERIOD (aka. keep alive) (AP Only)
#  STA should follow (i.e STA should send any frame before period),if enabled on AP
#  Period is in unit of 1000TU(1024ms, 1TU=1024us)
#  Note: if disabled, AP removes STAs' info only with explicit disconnection like deauth
bss_max_idle_enable = 1      # 0 (disable) or 1 (enable)
bss_max_idle = 1800   # time interval (e.g. 1800: 1843.2 sec) (1 ~ 163,830,000)
# --------------------------------------------------------------------------------#
#  SW encryption/decryption (default HW offload)
sw_enc = 0     # 0 (HW), 1 (SW), 2 (HYBRID: SW GTK HW PTK)
# --------------------------------------------------------------------------------#
# --------------------------------------------------------------------------------#
# --------------------------------------------------------------------------------#
# Filter tx deauth frame for Multi Connection Test (STA Only) (Test only)
discard_deauth = 0         # 1: discard TX deauth frame on STA
# --------------------------------------------------------------------------------#
# Use bitmap encoding for NDP (block) ack operation (NRC7292 only)
bitmap_encoding = 1         # 0 (disable) or 1 (enable)
# --------------------------------------------------------------------------------#
# User scrambler reversely (NRC7292 only)
reverse_scrambler = 1         # 0 (disable) or 1 (enable)
# --------------------------------------------------------------------------------#
# --------------------------------------------------------------------------------#
# Supported CH Width (STA Only)
support_ch_width = 1         # 0 (1/2MHz Support) or 1 (1/2/4MHz Support)
# --------------------------------------------------------------------------------#
# Rate control configuration
# Types of RC: (0) System default, (1)Disable,Use default_mcs (2)Feedback RC. (3)Consistent RC.
ap_rc_mode = 2
sta_rc_mode = 2
#  Default MCS: (0 ~ 7)
ap_rc_default_mcs = 2
sta_rc_default_mcs = 2
# --------------------------------------------------------------------------------#
# Use Power save pretend operation for no response STA
power_save_pretend = 0      # 0 (disable) or 1 (enable)
##################################################################################


def strSTA():
    if int(sys.argv[1]) == 0:
        return 'STA'
    elif int(sys.argv[1]) == 1:
        return 'AP'


def strBDName():
    if str(bd_name):
        return str(bd_name)
    else:
        return 'nrc' + str(model) + '_bd.dat'


def setAPParam():
    # Re-define parameters for AP mode
    global ndp_preq
    ndp_preq = 1


def checkParamValidity():
    if strSTA() == 'STA' and int(power_save) > 0 and int(listen_interval) > 65535:
        print("Max listen_interval is 65535!")
        exit()


def setModuleParam():
    # Set module parameters based on configuration

    # Initialize arguments for module params
    spi_arg = fw_arg = power_save_arg = sleep_duration_arg = \
        bss_max_idle_arg = ndp_preq_arg = ndp_ack_1m_arg = auto_ba_arg =\
        sw_enc_arg = cqm_arg = listen_int_arg = drv_dbg_arg = \
        sbi_arg = discard_deauth_arg = dbg_fc_arg = kr_band_arg = legacy_ack_arg = \
        be_arg = rs_arg = beacon_bypass_arg = ps_gpio_arg = bd_name_arg = \
        support_ch_width_arg = ps_pretend_arg = ""

    # Set parameters for AP (support NDP probing)
    if strSTA() == 'AP':
        setAPParam()

    # module param for FW download from host
    # default: fw_name (NULL: no download)
    if int(fw_download) == 1:
        fw_arg = " fw_name=" + fw_name

    # module param for power_save
    # default: power_save(0: active mode) sleep_duration(0,0)
    if strSTA() == 'STA' and int(power_save) > 0:
        # 7393/7394 STA (host_gpio_out(17) --> target_gpio_in(14))
        if str(model) == "7393" or str(model) == "7394":
            ps_gpio_arg = " power_save_gpio=17,14"
        power_save_arg = " power_save=" + str(power_save)
        if int(power_save) == 3:
            sleep_duration_arg = " sleep_duration=" + \
                re.sub(r'[^0-9]', '', sleep_duration)
            unit = sleep_duration[-1]
            if unit == 'm':
                sleep_duration_arg += ",0"
            else:
                sleep_duration_arg += ",1"

    # module param for bss_max_idle (keep alive)
    # default: bss_max_idle(0: disabled)
    if int(bss_max_idle_enable) == 1:
        if strSTA() == 'AP' or strSTA() == 'RELAY' or strSTA() == 'STA':
            bss_max_idle_arg = " bss_max_idle=" + str(bss_max_idle)

    # module param for NDP Prboe Request (NDP scan)
    # default: ndp_preq(0: disabled)
    if int(ndp_preq) == 1:
        ndp_preq_arg = " ndp_preq=1"

    # module param for 1MBW NDP ACK
    # default: ndp_ack_1m(0: disabled)
    if int(ndp_ack_1m) == 1:
        ndp_ack_1m_arg = " ndp_ack_1m=1"

    # module param for AMPDU
    # default: auto (0: disable 1: manual 2: auto)
    if int(ampdu_enable) != 2:
        auto_ba_arg = " ampdu_mode=" + str(ampdu_enable)

    # module param for SW-based ENC/DEC
    # default: sw_enc(0: HW-based ENC/DEC)
    if int(sw_enc) > 0:
        sw_enc_arg = " sw_enc=" + str(sw_enc)

    # module param for CQM
    # default: disable_cqm(0: CQM enabled)
    if int(cqm_enable) == 0:
        cqm_arg = " disable_cqm=1"

    # module param for short beacon
    # default: enable_short_bi(1: Short Beacon enabled)
    if int(short_bcn_enable) == 0:
        sbi_arg = " enable_short_bi=0"

    # module param for legacy ack mode
    # default: 0(Legacy ACK disabled)
    if int(legacy_ack_enable) == 1:
        legacy_ack_arg = " enable_legacy_ack=1"

    # module param for beacon bypass
    # default: 0(beacon bypass disabled)
    if int(beacon_bypass_enable) == 1:
        beacon_bypass_arg = " enable_beacon_bypass=1"

    # module param for listen interval
    # default: listen_interval(100)
    if int(listen_interval) > 0:
        listen_int_arg = " listen_interval=" + str(listen_interval)

    # module param for deauth-discard on STA (test only)
    # default: discard_deauth(0: disabled)
    if int(discard_deauth) == 1:
        discard_deauth_arg = " discard_deauth=1"

    # module param for driver debug (debug only)
    # default: debug_level_all(0: disabled)
    if int(driver_debug) == 1:
        drv_dbg_arg = " debug_level_all=1"

    # module param for flow control debug (debug only)
    # default: dbg_flow_control(0: disabled)
    if int(dbg_flow_control) == 1:
        dbg_fc_arg = " debug_level_all=1 dbg_flow_control=1"

    # module param for bitmap encoding
    # default: use bitmap encoding (1: enabled)
    if int(bitmap_encoding) == 0:
        be_arg = " bitmap_encoding=0"

    # module param for reverse scrambler
    # default: use reverse scrambler (1: enabled)
    if int(reverse_scrambler) == 0:
        rs_arg = " reverse_scrambler=0"

    # module param for power save pretend
    # default: use power save pretend (0: disabled)
    if int(power_save_pretend) == 1:
        ps_pretend_arg = " ps_pretend=1"

    # module param for board data file
    # default: bd.dat
    bd_name_arg = " bd_name=" + strBDName()

    # module param for rate control mode
    # default:  rc_mode=1(Individual for each STA)
    rc_mode_arg = " ap_rc_mode=" + \
        str(ap_rc_mode) + " sta_rc_mode=" + str(sta_rc_mode)
    # default:  rc_default_mcs=2(mcs2)
    rc_default_mcs_arg = " ap_rc_default_mcs=" + str(ap_rc_default_mcs) + \
        " sta_rc_default_mcs=" + str(sta_rc_default_mcs)

    # module parameter setting while loading NRC driver
    # Default value is used if arg is not defined
    module_param = ""

    # module param for supported channel width
    # default : support 1/2/4MHz (1: 1/2/4Mhz)
    if strSTA() == 'STA' and int(support_ch_width) == 0:
        support_ch_width_arg = " support_ch_width=0"

    module_param += fw_arg + \
        power_save_arg + sleep_duration_arg + bss_max_idle_arg + \
        ndp_preq_arg + ndp_ack_1m_arg + auto_ba_arg + sw_enc_arg + \
        cqm_arg + listen_int_arg + drv_dbg_arg + \
        sbi_arg + discard_deauth_arg + dbg_fc_arg + kr_band_arg + legacy_ack_arg + \
        be_arg + rs_arg + beacon_bypass_arg + ps_gpio_arg + bd_name_arg + support_ch_width_arg + \
        rc_mode_arg + rc_default_mcs_arg + ps_pretend_arg \

    return module_param


def run_common():

    checkParamValidity()

    print("Copy and Set Module Parameters")
    insmod_arg = setModuleParam()

    insmod_arg = insmod_arg.replace(" ", " nrc.")

    # print("Adding", insmod_arg)

    file_txt = ""
    with open(sys.argv[2], "w") as mod_file:
        # file_txt = mod_file.read()
        # file_txt = re.sub(pattern=r"\snrc.[^\s]+", string=file_txt, repl="")
        file_txt = "options nrc" + insmod_arg
        file_txt = file_txt.strip("\n")
        mod_file.write(file_txt)


if __name__ == '__main__':

    run_common()
