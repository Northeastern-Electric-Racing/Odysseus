#!/usr/bin/python3

import sys
import re
import configparser
import argparse

'''
Args: (in order first to last)
#1 -> 0 (STA) or 1 (AP) (required)
#2 -> path/to/this/ini/file (optional, otherwise default: /etc/nrc_opts_<ap|sta>.ini)
#3 -> path/to/modprobe.d/directive.conf (optional, otherwise default: /etc/modprobe.d/nrc.conf)

'''

parser = argparse.ArgumentParser()

parser.add_argument('option', type=int, choices=[0, 1], help="0 returns STA, 1 returns AP")
parser.add_argument('--ip', '-op', help="path/to/this/ini/file (optional, otherwise default: /etc/nrc_opts_<ap|sta>.ini)")
parser.add_argument('--mp', '-op', help="path/to/modprobe.d/directive.conf (optional, otherwise default: /etc/modprobe.d/nrc.conf)")

args = parser.parse_args()

def strSTA():
    option = args.option
    if int(option) == 0:
        return 'STA'
    elif int(option) == 1:
        return 'AP'


def strBDName(bd_name, model):
    # if empty, use passed in bd_name
    if not str(bd_name):
        return str(bd_name)
    else:
        return 'nrc' + str(model) + '_bd.dat'


def checkParamValidity(power_save, listen_interval):
    if strSTA() == 'STA' and int(power_save) > 0 and int(listen_interval) > 65535:
        print("Max listen_interval is 65535!")
        exit()


def setModuleParam(config):
    fw_arg = power_save_arg = sleep_duration_arg = \
        bss_max_idle_arg = ndp_preq_arg = ndp_ack_1m_arg = auto_ba_arg =\
        sw_enc_arg = cqm_arg = listen_int_arg = drv_dbg_arg = \
        sbi_arg = discard_deauth_arg = dbg_fc_arg = legacy_ack_arg = \
        be_arg = rs_arg = beacon_bypass_arg = ps_gpio_arg = bd_name_arg = \
        support_ch_width_arg = ps_pretend_arg = ""

    # Set module parameters based on configuration

    # Set parameters for AP (support NDP probing)
    if strSTA() == 'AP':
        ndp_preq = 1
    else:
        ndp_preq = config['ndp_preq']

    # module param for FW download from host
    # default: fw_name (NULL: no download)
    if int(config['fw_download']) == 1:
        fw_arg = " fw_name=" + config['fw_name']

    # module param for power_save
    # default: power_save(0: active mode) sleep_duration(0,0)
    if strSTA() == 'STA' and int(config['power_save']) > 0:
        # 7393/7394 STA (host_gpio_out(17) --> target_gpio_in(14))
        if str(config['model']) == "7393" or str(config['model']) == "7394":
            ps_gpio_arg = " power_save_gpio=17,14"
        power_save_arg = " power_save=" + str(config['power_save'])
        if int(config['power_save']) == 3:
            sleep_duration_arg = " sleep_duration=" + \
                re.sub(r'[^0-9]', '', config['sleep_duration'])
            unit = config['sleep_duration'][-1]
            if unit == 'm':
                sleep_duration_arg += ",0"
            else:
                sleep_duration_arg += ",1"

    # module param for bss_max_idle (keep alive)
    # default: bss_max_idle(0: disabled)
    if int(config['bss_max_idle_enable']) == 1:
        if strSTA() == 'AP' or strSTA() == 'RELAY' or strSTA() == 'STA':
            bss_max_idle_arg = " bss_max_idle=" + str(config['bss_max_idle'])

    # module param for NDP Prboe Request (NDP scan)
    # default: ndp_preq(0: disabled)
    if int(ndp_preq) == 1:
        ndp_preq_arg = " ndp_preq=1"

    # module param for 1MBW NDP ACK
    # default: ndp_ack_1m(0: disabled)
    if int(config['ndp_ack_1m']) == 1:
        ndp_ack_1m_arg = " ndp_ack_1m=1"

    # module param for AMPDU
    # default: auto (0: disable 1: manual 2: auto)
    if int(config['ampdu_enable']) != 2:
        auto_ba_arg = " ampdu_mode=" + str(config['ampdu_enable'])

    # module param for SW-based ENC/DEC
    # default: sw_enc(0: HW-based ENC/DEC)
    if int(config['sw_enc']) > 0:
        sw_enc_arg = " sw_enc=" + str(config['sw_enc'])

    # module param for CQM
    # default: disable_cqm(0: CQM enabled)
    if int(config['cqm_enable']) == 0:
        cqm_arg = " disable_cqm=1"

    # module param for short beacon
    # default: enable_short_bi(1: Short Beacon enabled)
    if int(config['short_bcn_enable']) == 0:
        sbi_arg = " enable_short_bi=0"

    # module param for legacy ack mode
    # default: 0(Legacy ACK disabled)
    if int(config['legacy_ack_enable']) == 1:
        legacy_ack_arg = " enable_legacy_ack=1"

    # module param for beacon bypass
    # default: 0(beacon bypass disabled)
    if int(config['beacon_bypass_enable']) == 1:
        beacon_bypass_arg = " enable_beacon_bypass=1"

    # module param for listen interval
    # default: listen_interval(100)
    if int(config['listen_interval']) > 0:
        listen_int_arg = " listen_interval=" + str(config['listen_interval'])

    # module param for deauth-discard on STA (test only)
    # default: discard_deauth(0: disabled)
    if int(config['discard_deauth']) == 1:
        discard_deauth_arg = " discard_deauth=1"

    # module param for flow control debug (debug only)
    # default: dbg_flow_control(0: disabled)
    if int(config['dbg_flow_control']) == 1:
        dbg_fc_arg = " debug_level_all=1 dbg_flow_control=1"
    else:
        # module param for driver debug (debug only)
        # default: debug_level_all(0: disabled)
        if int(config['driver_debug']) == 1:
            drv_dbg_arg = " debug_level_all=1"

    # module param for bitmap encoding
    # default: use bitmap encoding (1: enabled)
    if int(config['bitmap_encoding']) == 0:
        be_arg = " bitmap_encoding=0"

    # module param for reverse scrambler
    # default: use reverse scrambler (1: enabled)
    if int(config['reverse_scrambler']) == 0:
        rs_arg = " reverse_scrambler=0"

    # module param for power save pretend
    # default: use power save pretend (0: disabled)
    if int(config['power_save_pretend']) == 1:
        ps_pretend_arg = " ps_pretend=1"

    # module param for board data file
    # default: bd.dat
    bd_name_arg = " bd_name=" + strBDName(config['bd_name'], config['model'])

    # module param for rate control mode
    # default:  rc_mode=1(Individual for each STA)
    rc_mode_arg = " ap_rc_mode=" + \
        str(config['ap_rc_mode']) + " sta_rc_mode=" + \
        str(config['sta_rc_mode'])
    # default:  rc_default_mcs=2(mcs2)
    rc_default_mcs_arg = " ap_rc_default_mcs=" + str(config['ap_rc_default_mcs']) + \
        " sta_rc_default_mcs=" + str(config['sta_rc_default_mcs'])

    # module parameter setting while loading NRC driver
    # Default value is used if arg is not defined
    module_param = ""

    # module param for supported channel width
    # default : support 1/2/4MHz (1: 1/2/4Mhz)
    if strSTA() == 'STA' and int(config['support_ch_width']) == 0:
        support_ch_width_arg = " support_ch_width=0"

    module_param += fw_arg + \
        power_save_arg + sleep_duration_arg + bss_max_idle_arg + \
        ndp_preq_arg + ndp_ack_1m_arg + auto_ba_arg + sw_enc_arg + \
        cqm_arg + listen_int_arg + drv_dbg_arg + \
        sbi_arg + discard_deauth_arg + dbg_fc_arg + legacy_ack_arg + \
        be_arg + rs_arg + beacon_bypass_arg + ps_gpio_arg + bd_name_arg + support_ch_width_arg + \
        rc_mode_arg + rc_default_mcs_arg + ps_pretend_arg \

    return module_param


def load_conf(file_path):
    config = configparser.ConfigParser()
    config.read(file_path)
    # use newracom as only section header as we dont need headers
    return config['newracom']


def run_common():

    ini_path = args.ip
    if (ini_path is None) :
        if strSTA() == 'STA':
            ini_path = "/etc/nrc_opts_sta.ini"
        else:
            ini_path = "/etc/nrc_opts_ap.ini"

    items = load_conf(ini_path)

    checkParamValidity(items['power_save'], items['listen_interval'])

    print("Copy and Set Module Parameters")
    insmod_arg = setModuleParam(items)

    file_txt = ""

    mod_path = args.mp
    # if not passed in, use live buildroot default
    if mod_path is None:
        mod_path = "/etc/modprobe.d/nrc.conf"

    with open(mod_path, "w") as mod_file:
        file_txt = "options nrc" + insmod_arg
        file_txt = file_txt.strip("\n")
        mod_file.writelines([file_txt, "\n"])


if __name__ == '__main__':

    run_common()
