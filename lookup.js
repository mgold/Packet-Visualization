/*
 * lookup.js - a very hacky first-block IPv4 lookup table
 * Information from Wikipedia
 * Code by Max Goldstein
 */

function lookup_IP(ip){
    if (ip >= 224 && ip <= 239){
        return "Multicast";
    }else if (ip >= 240 && ip <= 255){
        return "Future Use";
    }else{
        return lookup_dict[ip];
    }
}

var lookup_dict = {
    0: "IANA",
    1: "APNIC",
    2: "RIPE NCC",
    3: "General Electric",
    4: "Level 3 Communications",
    5: "RIPE NCC",
    6: "US DoD",
    7: "ARIN",
    8: "Level 3 Communications",
    9: "IBM",
    10: "Private (RFC 1918)",
    11: "US DoD",
    12: "AT&T Bell Labs",
    13: "Xerox",
    14: "APNIC",
    15: "Hewlett-Packard",
    16: "Digital Equipment Corporation",
    17: "Apple Inc.",
    18: "MIT",
    19: "Ford Motor Company",
    20: "Computer Sciences Corporation",
    21: "US DoD",
    22: "US DoD",
    23: "ARIN",
    24: "ARIN",
    25: "UK Ministry of Defence",
    26: "US DoD",
    27: "APNIC",
    28: "US DoD",
    29: "US DoD",
    30: "US DoD",
    31: "RIPE NCC",
    32: "AT&T",
    33: "US DoD",
    34: "Halliburton",
    35: "Merit Network",
    36: "APNIC",
    37: "RIPE NCC",
    38: "PSINet",
    39: "APNIC",
    40: "Eli Lilly",
    41: "AfriNIC",
    42: "AfriNIC",
    43: "APNIC",
    44: "Amateur Radio Digital Communications",
    45: "ARIN",
    46: "RIPE NCC",
    47: "Bell-Northern Research",
    48: "Prudential Financial",
    49: "APNIC",
    50: "ARIN",
    51: "UK Department for Work and Pensions",
    52: "DuPont",
    53: "Cap Debis CCS",
    54: "Merck",
    55: "US DoD",
    56: "US DoD",
    57: "SITA",
    107: "ARIN",
    127: "Loopback",
    128: "RIPE",
    169: "ARIN",
    172: "ARIN",
    192: "ARIN & Private (RFC 1918)",
    198: "ARIN",
    203: "APNIC",
    214: "US DoD",
    215: "US DoD"
}
