/**
 * Deploy /system/regions document to Firestore.
 *
 * Usage:
 *   1) Make sure you're in the Firebase project root (where firebase.json is).
 *   2) Install deps: npm i firebase-admin
 *   3) Authenticate:
 *        - Option A (recommended): set GOOGLE_APPLICATION_CREDENTIALS to a service account JSON
 *        - Option B: run this inside your functions folder after `firebase login` is set up (may still need creds)
 *   4) Run: node deploy_system_regions.js
 */
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp(); // uses Application Default Credentials
}
const db = admin.firestore();

const regionsDoc = {
  "base_currency": "eur",
  "countries": {
    "AW": {
      "currency_code": "awg",
      "currency_symbol": "Afl"
    },
    "AF": {
      "currency_code": "afn",
      "currency_symbol": "؋"
    },
    "AO": {
      "currency_code": "aoa",
      "currency_symbol": "Kz"
    },
    "AI": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "AX": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "AL": {
      "currency_code": "all",
      "currency_symbol": "Lekë"
    },
    "AD": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "AE": {
      "currency_code": "aed",
      "currency_symbol": "د.إ"
    },
    "AR": {
      "currency_code": "ars",
      "currency_symbol": "$"
    },
    "AM": {
      "currency_code": "amd",
      "currency_symbol": "֏"
    },
    "AS": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "AQ": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "TF": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "AG": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "AU": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "AT": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "AZ": {
      "currency_code": "azn",
      "currency_symbol": "₼"
    },
    "BI": {
      "currency_code": "bif",
      "currency_symbol": "FBu"
    },
    "BE": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "BJ": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "BQ": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "BF": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "BD": {
      "currency_code": "bdt",
      "currency_symbol": "৳"
    },
    "BG": {
      "currency_code": "bgn",
      "currency_symbol": "лв"
    },
    "BH": {
      "currency_code": "bhd",
      "currency_symbol": "د.ب"
    },
    "BS": {
      "currency_code": "bsd",
      "currency_symbol": "$"
    },
    "BA": {
      "currency_code": "bam",
      "currency_symbol": "KM"
    },
    "BL": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "BY": {
      "currency_code": "byn",
      "currency_symbol": "Br"
    },
    "BZ": {
      "currency_code": "bzd",
      "currency_symbol": "$"
    },
    "BM": {
      "currency_code": "bmd",
      "currency_symbol": "$"
    },
    "BO": {
      "currency_code": "bob",
      "currency_symbol": "Bs"
    },
    "BR": {
      "currency_code": "brl",
      "currency_symbol": "R$"
    },
    "BB": {
      "currency_code": "bbd",
      "currency_symbol": "$"
    },
    "BN": {
      "currency_code": "bnd",
      "currency_symbol": "$"
    },
    "BT": {
      "currency_code": "inr",
      "currency_symbol": "₹"
    },
    "BV": {
      "currency_code": "nok",
      "currency_symbol": "kr"
    },
    "BW": {
      "currency_code": "bwp",
      "currency_symbol": "P"
    },
    "CF": {
      "currency_code": "xaf",
      "currency_symbol": "FCFA"
    },
    "CA": {
      "currency_code": "cad",
      "currency_symbol": "CA$"
    },
    "CC": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "CH": {
      "currency_code": "chf",
      "currency_symbol": "CHF"
    },
    "CL": {
      "currency_code": "clp",
      "currency_symbol": "$"
    },
    "CN": {
      "currency_code": "cny",
      "currency_symbol": "¥"
    },
    "CI": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "CM": {
      "currency_code": "xaf",
      "currency_symbol": "FCFA"
    },
    "CD": {
      "currency_code": "cdf",
      "currency_symbol": "FC"
    },
    "CG": {
      "currency_code": "xaf",
      "currency_symbol": "FCFA"
    },
    "CK": {
      "currency_code": "nzd",
      "currency_symbol": "$"
    },
    "CO": {
      "currency_code": "cop",
      "currency_symbol": "$"
    },
    "KM": {
      "currency_code": "kmf",
      "currency_symbol": "CF"
    },
    "CV": {
      "currency_code": "cve",
      "currency_symbol": ""
    },
    "CR": {
      "currency_code": "crc",
      "currency_symbol": "₡"
    },
    "CU": {
      "currency_code": "cup",
      "currency_symbol": "$"
    },
    "CW": {
      "currency_code": "xcg",
      "currency_symbol": "Cg"
    },
    "CX": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "KY": {
      "currency_code": "kyd",
      "currency_symbol": "$"
    },
    "CY": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "CZ": {
      "currency_code": "czk",
      "currency_symbol": "Kč"
    },
    "DE": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "DJ": {
      "currency_code": "djf",
      "currency_symbol": "Fdj"
    },
    "DM": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "DK": {
      "currency_code": "dkk",
      "currency_symbol": "kr"
    },
    "DO": {
      "currency_code": "dop",
      "currency_symbol": "RD$"
    },
    "DZ": {
      "currency_code": "dzd",
      "currency_symbol": "DA"
    },
    "EC": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "EG": {
      "currency_code": "egp",
      "currency_symbol": "ج.م"
    },
    "ER": {
      "currency_code": "ern",
      "currency_symbol": "Nfk"
    },
    "EH": {
      "currency_code": "mad",
      "currency_symbol": "د.م"
    },
    "ES": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "EE": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "ET": {
      "currency_code": "etb",
      "currency_symbol": "Br"
    },
    "FI": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "FJ": {
      "currency_code": "fjd",
      "currency_symbol": "$"
    },
    "FK": {
      "currency_code": "fkp",
      "currency_symbol": "£"
    },
    "FR": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "FO": {
      "currency_code": "dkk",
      "currency_symbol": "kr"
    },
    "FM": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "GA": {
      "currency_code": "xaf",
      "currency_symbol": "FCFA"
    },
    "GB": {
      "currency_code": "gbp",
      "currency_symbol": "£"
    },
    "GE": {
      "currency_code": "gel",
      "currency_symbol": "₾"
    },
    "GG": {
      "currency_code": "gbp",
      "currency_symbol": "£"
    },
    "GH": {
      "currency_code": "ghs",
      "currency_symbol": "GH₵"
    },
    "GI": {
      "currency_code": "gip",
      "currency_symbol": "£"
    },
    "GN": {
      "currency_code": "gnf",
      "currency_symbol": "FG"
    },
    "GP": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "GM": {
      "currency_code": "gmd",
      "currency_symbol": "D"
    },
    "GW": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "GQ": {
      "currency_code": "xaf",
      "currency_symbol": "FCFA"
    },
    "GR": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "GD": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "GL": {
      "currency_code": "dkk",
      "currency_symbol": "kr"
    },
    "GT": {
      "currency_code": "gtq",
      "currency_symbol": "Q"
    },
    "GF": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "GU": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "GY": {
      "currency_code": "gyd",
      "currency_symbol": "$"
    },
    "HK": {
      "currency_code": "hkd",
      "currency_symbol": "HK$"
    },
    "HM": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "HN": {
      "currency_code": "hnl",
      "currency_symbol": "L"
    },
    "HR": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "HT": {
      "currency_code": "htg",
      "currency_symbol": "G"
    },
    "HU": {
      "currency_code": "huf",
      "currency_symbol": "Ft"
    },
    "ID": {
      "currency_code": "idr",
      "currency_symbol": "Rp"
    },
    "IM": {
      "currency_code": "gbp",
      "currency_symbol": "£"
    },
    "IN": {
      "currency_code": "inr",
      "currency_symbol": "₹"
    },
    "IO": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "IE": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "IR": {
      "currency_code": "irr",
      "currency_symbol": "ریال"
    },
    "IQ": {
      "currency_code": "iqd",
      "currency_symbol": "د.ع"
    },
    "IS": {
      "currency_code": "isk",
      "currency_symbol": "kr"
    },
    "IL": {
      "currency_code": "ils",
      "currency_symbol": "₪"
    },
    "IT": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "JM": {
      "currency_code": "jmd",
      "currency_symbol": "$"
    },
    "JE": {
      "currency_code": "gbp",
      "currency_symbol": "£"
    },
    "JO": {
      "currency_code": "jod",
      "currency_symbol": "د.أ"
    },
    "JP": {
      "currency_code": "jpy",
      "currency_symbol": "￥"
    },
    "KZ": {
      "currency_code": "kzt",
      "currency_symbol": "₸"
    },
    "KE": {
      "currency_code": "kes",
      "currency_symbol": "Ksh"
    },
    "KG": {
      "currency_code": "kgs",
      "currency_symbol": "сом"
    },
    "KH": {
      "currency_code": "khr",
      "currency_symbol": "៛"
    },
    "KI": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "KN": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "KR": {
      "currency_code": "krw",
      "currency_symbol": "₩"
    },
    "KW": {
      "currency_code": "kwd",
      "currency_symbol": "د.ك"
    },
    "LA": {
      "currency_code": "lak",
      "currency_symbol": "₭"
    },
    "LB": {
      "currency_code": "lbp",
      "currency_symbol": "ل.ل"
    },
    "LR": {
      "currency_code": "lrd",
      "currency_symbol": "$"
    },
    "LY": {
      "currency_code": "lyd",
      "currency_symbol": "د.ل"
    },
    "LC": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "LI": {
      "currency_code": "chf",
      "currency_symbol": "CHF"
    },
    "LK": {
      "currency_code": "lkr",
      "currency_symbol": "රු"
    },
    "LS": {
      "currency_code": "zar",
      "currency_symbol": "R"
    },
    "LT": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "LU": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "LV": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "MO": {
      "currency_code": "mop",
      "currency_symbol": "MOP$"
    },
    "MF": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "MA": {
      "currency_code": "mad",
      "currency_symbol": "د.م"
    },
    "MC": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "MD": {
      "currency_code": "mdl",
      "currency_symbol": "L"
    },
    "MG": {
      "currency_code": "mga",
      "currency_symbol": "Ar"
    },
    "MV": {
      "currency_code": "mvr",
      "currency_symbol": "ރ"
    },
    "MX": {
      "currency_code": "mxn",
      "currency_symbol": "$"
    },
    "MH": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "MK": {
      "currency_code": "mkd",
      "currency_symbol": "ден"
    },
    "ML": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "MT": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "MM": {
      "currency_code": "mmk",
      "currency_symbol": "K"
    },
    "ME": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "MN": {
      "currency_code": "mnt",
      "currency_symbol": "₮"
    },
    "MP": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "MZ": {
      "currency_code": "mzn",
      "currency_symbol": "MTn"
    },
    "MR": {
      "currency_code": "mru",
      "currency_symbol": "أ.م"
    },
    "MS": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "MQ": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "MU": {
      "currency_code": "mur",
      "currency_symbol": "Rs"
    },
    "MW": {
      "currency_code": "mwk",
      "currency_symbol": "MWK"
    },
    "MY": {
      "currency_code": "myr",
      "currency_symbol": "RM"
    },
    "YT": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "NA": {
      "currency_code": "zar",
      "currency_symbol": "R"
    },
    "NC": {
      "currency_code": "xpf",
      "currency_symbol": "FCFP"
    },
    "NE": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "NF": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "NG": {
      "currency_code": "ngn",
      "currency_symbol": "₦"
    },
    "NI": {
      "currency_code": "nio",
      "currency_symbol": "C$"
    },
    "NU": {
      "currency_code": "nzd",
      "currency_symbol": "$"
    },
    "NL": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "NO": {
      "currency_code": "nok",
      "currency_symbol": "kr"
    },
    "NP": {
      "currency_code": "npr",
      "currency_symbol": "नेरू"
    },
    "NR": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "NZ": {
      "currency_code": "nzd",
      "currency_symbol": "$"
    },
    "OM": {
      "currency_code": "omr",
      "currency_symbol": "ر.ع"
    },
    "PK": {
      "currency_code": "pkr",
      "currency_symbol": "PKR"
    },
    "PA": {
      "currency_code": "pab",
      "currency_symbol": "B/"
    },
    "PN": {
      "currency_code": "nzd",
      "currency_symbol": "$"
    },
    "PE": {
      "currency_code": "pen",
      "currency_symbol": "S/"
    },
    "PH": {
      "currency_code": "php",
      "currency_symbol": "₱"
    },
    "PW": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "PG": {
      "currency_code": "pgk",
      "currency_symbol": "PGK"
    },
    "PL": {
      "currency_code": "pln",
      "currency_symbol": "zł"
    },
    "PR": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "KP": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "PT": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "PY": {
      "currency_code": "pyg",
      "currency_symbol": "₲"
    },
    "PS": {
      "currency_code": "ils",
      "currency_symbol": "₪"
    },
    "PF": {
      "currency_code": "xpf",
      "currency_symbol": "FCFP"
    },
    "QA": {
      "currency_code": "qar",
      "currency_symbol": "ر.ق"
    },
    "RE": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "RO": {
      "currency_code": "ron",
      "currency_symbol": "RON"
    },
    "RU": {
      "currency_code": "rub",
      "currency_symbol": "₽"
    },
    "RW": {
      "currency_code": "rwf",
      "currency_symbol": "RF"
    },
    "SA": {
      "currency_code": "sar",
      "currency_symbol": "ر.س"
    },
    "SD": {
      "currency_code": "sdg",
      "currency_symbol": "ج.س"
    },
    "SN": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "SG": {
      "currency_code": "sgd",
      "currency_symbol": "$"
    },
    "GS": {
      "currency_code": "gbp",
      "currency_symbol": "£"
    },
    "SH": {
      "currency_code": "shp",
      "currency_symbol": "SHP"
    },
    "SJ": {
      "currency_code": "nok",
      "currency_symbol": "kr"
    },
    "SB": {
      "currency_code": "sbd",
      "currency_symbol": "$"
    },
    "SL": {
      "currency_code": "sle",
      "currency_symbol": "Le"
    },
    "SV": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "SM": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "SO": {
      "currency_code": "sos",
      "currency_symbol": "S"
    },
    "PM": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "RS": {
      "currency_code": "rsd",
      "currency_symbol": "RSD"
    },
    "SS": {
      "currency_code": "ssp",
      "currency_symbol": "£"
    },
    "ST": {
      "currency_code": "stn",
      "currency_symbol": "Db"
    },
    "SR": {
      "currency_code": "srd",
      "currency_symbol": "$"
    },
    "SK": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "SI": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "SE": {
      "currency_code": "sek",
      "currency_symbol": "kr"
    },
    "SZ": {
      "currency_code": "szl",
      "currency_symbol": "E"
    },
    "SX": {
      "currency_code": "xcg",
      "currency_symbol": "Cg"
    },
    "SC": {
      "currency_code": "scr",
      "currency_symbol": "SR"
    },
    "SY": {
      "currency_code": "syp",
      "currency_symbol": "ل.س",
      "force_manual": true
    },
    "TC": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "TD": {
      "currency_code": "xaf",
      "currency_symbol": "FCFA"
    },
    "TG": {
      "currency_code": "xof",
      "currency_symbol": "F CFA"
    },
    "TH": {
      "currency_code": "thb",
      "currency_symbol": "฿"
    },
    "TJ": {
      "currency_code": "tjs",
      "currency_symbol": "TJS"
    },
    "TK": {
      "currency_code": "nzd",
      "currency_symbol": "$"
    },
    "TM": {
      "currency_code": "tmt",
      "currency_symbol": "ТМТ"
    },
    "TL": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "TO": {
      "currency_code": "top",
      "currency_symbol": "T$"
    },
    "TT": {
      "currency_code": "ttd",
      "currency_symbol": "$"
    },
    "TN": {
      "currency_code": "tnd",
      "currency_symbol": "DT"
    },
    "TR": {
      "currency_code": "try",
      "currency_symbol": "₺"
    },
    "TV": {
      "currency_code": "aud",
      "currency_symbol": "A$"
    },
    "TW": {
      "currency_code": "twd",
      "currency_symbol": "NT$"
    },
    "TZ": {
      "currency_code": "tzs",
      "currency_symbol": "TSh"
    },
    "UG": {
      "currency_code": "ugx",
      "currency_symbol": "USh"
    },
    "UA": {
      "currency_code": "uah",
      "currency_symbol": "₴"
    },
    "UM": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "UY": {
      "currency_code": "uyu",
      "currency_symbol": "$"
    },
    "US": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "UZ": {
      "currency_code": "uzs",
      "currency_symbol": "soʻm"
    },
    "VA": {
      "currency_code": "eur",
      "currency_symbol": "€"
    },
    "VC": {
      "currency_code": "xcd",
      "currency_symbol": "$"
    },
    "VE": {
      "currency_code": "ves",
      "currency_symbol": "Bs.S"
    },
    "VG": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "VI": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    },
    "VN": {
      "currency_code": "vnd",
      "currency_symbol": "₫"
    },
    "VU": {
      "currency_code": "vuv",
      "currency_symbol": "VT"
    },
    "WF": {
      "currency_code": "xpf",
      "currency_symbol": "FCFP"
    },
    "WS": {
      "currency_code": "wst",
      "currency_symbol": "WS$"
    },
    "YE": {
      "currency_code": "yer",
      "currency_symbol": "ر.ي"
    },
    "ZA": {
      "currency_code": "zar",
      "currency_symbol": "R"
    },
    "ZM": {
      "currency_code": "zmw",
      "currency_symbol": "K"
    },
    "ZW": {
      "currency_code": "usd",
      "currency_symbol": "US$"
    }
  },
  "currencies": {
    "aed": {
      "currency_code": "aed",
      "currency_symbol": "د.إ",
      "decimals": 2
    },
    "afn": {
      "currency_code": "afn",
      "currency_symbol": "؋",
      "decimals": 0
    },
    "all": {
      "currency_code": "all",
      "currency_symbol": "Lekë",
      "decimals": 0
    },
    "amd": {
      "currency_code": "amd",
      "currency_symbol": "֏",
      "decimals": 2
    },
    "ang": {
      "currency_code": "ang",
      "currency_symbol": "ANG",
      "decimals": 2
    },
    "aoa": {
      "currency_code": "aoa",
      "currency_symbol": "Kz",
      "decimals": 2
    },
    "ars": {
      "currency_code": "ars",
      "currency_symbol": "$",
      "decimals": 2
    },
    "aud": {
      "currency_code": "aud",
      "currency_symbol": "A$",
      "decimals": 2
    },
    "awg": {
      "currency_code": "awg",
      "currency_symbol": "Afl",
      "decimals": 2
    },
    "azn": {
      "currency_code": "azn",
      "currency_symbol": "₼",
      "decimals": 2
    },
    "bam": {
      "currency_code": "bam",
      "currency_symbol": "KM",
      "decimals": 2
    },
    "bbd": {
      "currency_code": "bbd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "bdt": {
      "currency_code": "bdt",
      "currency_symbol": "৳",
      "decimals": 2
    },
    "bgn": {
      "currency_code": "bgn",
      "currency_symbol": "лв",
      "decimals": 2
    },
    "bhd": {
      "currency_code": "bhd",
      "currency_symbol": "د.ب",
      "decimals": 3
    },
    "bif": {
      "currency_code": "bif",
      "currency_symbol": "FBu",
      "decimals": 0
    },
    "bmd": {
      "currency_code": "bmd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "bnd": {
      "currency_code": "bnd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "bob": {
      "currency_code": "bob",
      "currency_symbol": "Bs",
      "decimals": 2
    },
    "brl": {
      "currency_code": "brl",
      "currency_symbol": "R$",
      "decimals": 2
    },
    "bsd": {
      "currency_code": "bsd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "btn": {
      "currency_code": "btn",
      "currency_symbol": "Nu",
      "decimals": 2
    },
    "bwp": {
      "currency_code": "bwp",
      "currency_symbol": "P",
      "decimals": 2
    },
    "byn": {
      "currency_code": "byn",
      "currency_symbol": "Br",
      "decimals": 2
    },
    "bzd": {
      "currency_code": "bzd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "cad": {
      "currency_code": "cad",
      "currency_symbol": "CA$",
      "decimals": 2
    },
    "cdf": {
      "currency_code": "cdf",
      "currency_symbol": "FC",
      "decimals": 2
    },
    "chf": {
      "currency_code": "chf",
      "currency_symbol": "CHF",
      "decimals": 2
    },
    "clf": {
      "currency_code": "clf",
      "currency_symbol": "CLF",
      "decimals": 4
    },
    "clp": {
      "currency_code": "clp",
      "currency_symbol": "$",
      "decimals": 0
    },
    "cnh": {
      "currency_code": "cnh",
      "currency_symbol": "CNH",
      "decimals": 2
    },
    "cny": {
      "currency_code": "cny",
      "currency_symbol": "¥",
      "decimals": 2
    },
    "cop": {
      "currency_code": "cop",
      "currency_symbol": "$",
      "decimals": 2
    },
    "crc": {
      "currency_code": "crc",
      "currency_symbol": "₡",
      "decimals": 2
    },
    "cup": {
      "currency_code": "cup",
      "currency_symbol": "$",
      "decimals": 2
    },
    "cve": {
      "currency_code": "cve",
      "currency_symbol": "",
      "decimals": 2
    },
    "czk": {
      "currency_code": "czk",
      "currency_symbol": "Kč",
      "decimals": 2
    },
    "djf": {
      "currency_code": "djf",
      "currency_symbol": "Fdj",
      "decimals": 0
    },
    "dkk": {
      "currency_code": "dkk",
      "currency_symbol": "kr",
      "decimals": 2
    },
    "dop": {
      "currency_code": "dop",
      "currency_symbol": "RD$",
      "decimals": 2
    },
    "dzd": {
      "currency_code": "dzd",
      "currency_symbol": "DA",
      "decimals": 2
    },
    "egp": {
      "currency_code": "egp",
      "currency_symbol": "ج.م",
      "decimals": 2
    },
    "ern": {
      "currency_code": "ern",
      "currency_symbol": "Nfk",
      "decimals": 2
    },
    "etb": {
      "currency_code": "etb",
      "currency_symbol": "Br",
      "decimals": 2
    },
    "eur": {
      "currency_code": "eur",
      "currency_symbol": "€",
      "decimals": 2
    },
    "fjd": {
      "currency_code": "fjd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "fkp": {
      "currency_code": "fkp",
      "currency_symbol": "£",
      "decimals": 2
    },
    "fok": {
      "currency_code": "fok",
      "currency_symbol": "FOK",
      "decimals": 2
    },
    "gbp": {
      "currency_code": "gbp",
      "currency_symbol": "£",
      "decimals": 2
    },
    "gel": {
      "currency_code": "gel",
      "currency_symbol": "₾",
      "decimals": 2
    },
    "ggp": {
      "currency_code": "ggp",
      "currency_symbol": "GGP",
      "decimals": 2
    },
    "ghs": {
      "currency_code": "ghs",
      "currency_symbol": "GH₵",
      "decimals": 2
    },
    "gip": {
      "currency_code": "gip",
      "currency_symbol": "£",
      "decimals": 2
    },
    "gmd": {
      "currency_code": "gmd",
      "currency_symbol": "D",
      "decimals": 2
    },
    "gnf": {
      "currency_code": "gnf",
      "currency_symbol": "FG",
      "decimals": 0
    },
    "gtq": {
      "currency_code": "gtq",
      "currency_symbol": "Q",
      "decimals": 2
    },
    "gyd": {
      "currency_code": "gyd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "hkd": {
      "currency_code": "hkd",
      "currency_symbol": "HK$",
      "decimals": 2
    },
    "hnl": {
      "currency_code": "hnl",
      "currency_symbol": "L",
      "decimals": 2
    },
    "hrk": {
      "currency_code": "hrk",
      "currency_symbol": "kn",
      "decimals": 2
    },
    "htg": {
      "currency_code": "htg",
      "currency_symbol": "G",
      "decimals": 2
    },
    "huf": {
      "currency_code": "huf",
      "currency_symbol": "Ft",
      "decimals": 2
    },
    "idr": {
      "currency_code": "idr",
      "currency_symbol": "Rp",
      "decimals": 2
    },
    "ils": {
      "currency_code": "ils",
      "currency_symbol": "₪",
      "decimals": 2
    },
    "imp": {
      "currency_code": "imp",
      "currency_symbol": "IMP",
      "decimals": 2
    },
    "inr": {
      "currency_code": "inr",
      "currency_symbol": "₹",
      "decimals": 2
    },
    "iqd": {
      "currency_code": "iqd",
      "currency_symbol": "د.ع",
      "decimals": 0
    },
    "irr": {
      "currency_code": "irr",
      "currency_symbol": "ریال",
      "decimals": 0
    },
    "isk": {
      "currency_code": "isk",
      "currency_symbol": "kr",
      "decimals": 0
    },
    "jep": {
      "currency_code": "jep",
      "currency_symbol": "JEP",
      "decimals": 2
    },
    "jmd": {
      "currency_code": "jmd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "jod": {
      "currency_code": "jod",
      "currency_symbol": "د.أ",
      "decimals": 3
    },
    "jpy": {
      "currency_code": "jpy",
      "currency_symbol": "￥",
      "decimals": 0
    },
    "kes": {
      "currency_code": "kes",
      "currency_symbol": "Ksh",
      "decimals": 2
    },
    "kgs": {
      "currency_code": "kgs",
      "currency_symbol": "сом",
      "decimals": 2
    },
    "khr": {
      "currency_code": "khr",
      "currency_symbol": "៛",
      "decimals": 2
    },
    "kid": {
      "currency_code": "kid",
      "currency_symbol": "KID",
      "decimals": 2
    },
    "kmf": {
      "currency_code": "kmf",
      "currency_symbol": "CF",
      "decimals": 0
    },
    "krw": {
      "currency_code": "krw",
      "currency_symbol": "₩",
      "decimals": 0
    },
    "kwd": {
      "currency_code": "kwd",
      "currency_symbol": "د.ك",
      "decimals": 3
    },
    "kyd": {
      "currency_code": "kyd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "kzt": {
      "currency_code": "kzt",
      "currency_symbol": "₸",
      "decimals": 2
    },
    "lak": {
      "currency_code": "lak",
      "currency_symbol": "₭",
      "decimals": 0
    },
    "lbp": {
      "currency_code": "lbp",
      "currency_symbol": "ل.ل",
      "decimals": 0
    },
    "lkr": {
      "currency_code": "lkr",
      "currency_symbol": "රු",
      "decimals": 2
    },
    "lrd": {
      "currency_code": "lrd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "lsl": {
      "currency_code": "lsl",
      "currency_symbol": "M",
      "decimals": 2
    },
    "lyd": {
      "currency_code": "lyd",
      "currency_symbol": "د.ل",
      "decimals": 3
    },
    "mad": {
      "currency_code": "mad",
      "currency_symbol": "د.م",
      "decimals": 2
    },
    "mdl": {
      "currency_code": "mdl",
      "currency_symbol": "L",
      "decimals": 2
    },
    "mga": {
      "currency_code": "mga",
      "currency_symbol": "Ar",
      "decimals": 0
    },
    "mkd": {
      "currency_code": "mkd",
      "currency_symbol": "ден",
      "decimals": 2
    },
    "mmk": {
      "currency_code": "mmk",
      "currency_symbol": "K",
      "decimals": 0
    },
    "mnt": {
      "currency_code": "mnt",
      "currency_symbol": "₮",
      "decimals": 2
    },
    "mop": {
      "currency_code": "mop",
      "currency_symbol": "MOP$",
      "decimals": 2
    },
    "mru": {
      "currency_code": "mru",
      "currency_symbol": "أ.م",
      "decimals": 2
    },
    "mur": {
      "currency_code": "mur",
      "currency_symbol": "Rs",
      "decimals": 2
    },
    "mvr": {
      "currency_code": "mvr",
      "currency_symbol": "ރ",
      "decimals": 2
    },
    "mwk": {
      "currency_code": "mwk",
      "currency_symbol": "MWK",
      "decimals": 2
    },
    "mxn": {
      "currency_code": "mxn",
      "currency_symbol": "$",
      "decimals": 2
    },
    "myr": {
      "currency_code": "myr",
      "currency_symbol": "RM",
      "decimals": 2
    },
    "mzn": {
      "currency_code": "mzn",
      "currency_symbol": "MTn",
      "decimals": 2
    },
    "nad": {
      "currency_code": "nad",
      "currency_symbol": "$",
      "decimals": 2
    },
    "ngn": {
      "currency_code": "ngn",
      "currency_symbol": "₦",
      "decimals": 2
    },
    "nio": {
      "currency_code": "nio",
      "currency_symbol": "C$",
      "decimals": 2
    },
    "nok": {
      "currency_code": "nok",
      "currency_symbol": "kr",
      "decimals": 2
    },
    "npr": {
      "currency_code": "npr",
      "currency_symbol": "नेरू",
      "decimals": 2
    },
    "nzd": {
      "currency_code": "nzd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "omr": {
      "currency_code": "omr",
      "currency_symbol": "ر.ع",
      "decimals": 3
    },
    "pab": {
      "currency_code": "pab",
      "currency_symbol": "B/",
      "decimals": 2
    },
    "pen": {
      "currency_code": "pen",
      "currency_symbol": "S/",
      "decimals": 2
    },
    "pgk": {
      "currency_code": "pgk",
      "currency_symbol": "PGK",
      "decimals": 2
    },
    "php": {
      "currency_code": "php",
      "currency_symbol": "₱",
      "decimals": 2
    },
    "pkr": {
      "currency_code": "pkr",
      "currency_symbol": "PKR",
      "decimals": 2
    },
    "pln": {
      "currency_code": "pln",
      "currency_symbol": "zł",
      "decimals": 2
    },
    "pyg": {
      "currency_code": "pyg",
      "currency_symbol": "₲",
      "decimals": 0
    },
    "qar": {
      "currency_code": "qar",
      "currency_symbol": "ر.ق",
      "decimals": 2
    },
    "ron": {
      "currency_code": "ron",
      "currency_symbol": "RON",
      "decimals": 2
    },
    "rsd": {
      "currency_code": "rsd",
      "currency_symbol": "RSD",
      "decimals": 0
    },
    "rub": {
      "currency_code": "rub",
      "currency_symbol": "₽",
      "decimals": 2
    },
    "rwf": {
      "currency_code": "rwf",
      "currency_symbol": "RF",
      "decimals": 0
    },
    "sar": {
      "currency_code": "sar",
      "currency_symbol": "ر.س",
      "decimals": 2
    },
    "sbd": {
      "currency_code": "sbd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "scr": {
      "currency_code": "scr",
      "currency_symbol": "SR",
      "decimals": 2
    },
    "sdg": {
      "currency_code": "sdg",
      "currency_symbol": "ج.س",
      "decimals": 2
    },
    "sek": {
      "currency_code": "sek",
      "currency_symbol": "kr",
      "decimals": 2
    },
    "sgd": {
      "currency_code": "sgd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "shp": {
      "currency_code": "shp",
      "currency_symbol": "SHP",
      "decimals": 2
    },
    "sle": {
      "currency_code": "sle",
      "currency_symbol": "Le",
      "decimals": 2
    },
    "sll": {
      "currency_code": "sll",
      "currency_symbol": "SLL",
      "decimals": 0
    },
    "sos": {
      "currency_code": "sos",
      "currency_symbol": "S",
      "decimals": 0
    },
    "srd": {
      "currency_code": "srd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "ssp": {
      "currency_code": "ssp",
      "currency_symbol": "£",
      "decimals": 2
    },
    "stn": {
      "currency_code": "stn",
      "currency_symbol": "Db",
      "decimals": 2
    },
    "syp": {
      "currency_code": "syp",
      "currency_symbol": "ل.س",
      "decimals": 0
    },
    "szl": {
      "currency_code": "szl",
      "currency_symbol": "E",
      "decimals": 2
    },
    "thb": {
      "currency_code": "thb",
      "currency_symbol": "฿",
      "decimals": 2
    },
    "tjs": {
      "currency_code": "tjs",
      "currency_symbol": "TJS",
      "decimals": 2
    },
    "tmt": {
      "currency_code": "tmt",
      "currency_symbol": "ТМТ",
      "decimals": 2
    },
    "tnd": {
      "currency_code": "tnd",
      "currency_symbol": "DT",
      "decimals": 3
    },
    "top": {
      "currency_code": "top",
      "currency_symbol": "T$",
      "decimals": 2
    },
    "try": {
      "currency_code": "try",
      "currency_symbol": "₺",
      "decimals": 2
    },
    "ttd": {
      "currency_code": "ttd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "tvd": {
      "currency_code": "tvd",
      "currency_symbol": "TVD",
      "decimals": 2
    },
    "twd": {
      "currency_code": "twd",
      "currency_symbol": "NT$",
      "decimals": 2
    },
    "tzs": {
      "currency_code": "tzs",
      "currency_symbol": "TSh",
      "decimals": 2
    },
    "uah": {
      "currency_code": "uah",
      "currency_symbol": "₴",
      "decimals": 2
    },
    "ugx": {
      "currency_code": "ugx",
      "currency_symbol": "USh",
      "decimals": 0
    },
    "usd": {
      "currency_code": "usd",
      "currency_symbol": "US$",
      "decimals": 2
    },
    "uyu": {
      "currency_code": "uyu",
      "currency_symbol": "$",
      "decimals": 2
    },
    "uzs": {
      "currency_code": "uzs",
      "currency_symbol": "soʻm",
      "decimals": 2
    },
    "ves": {
      "currency_code": "ves",
      "currency_symbol": "Bs.S",
      "decimals": 2
    },
    "vnd": {
      "currency_code": "vnd",
      "currency_symbol": "₫",
      "decimals": 0
    },
    "vuv": {
      "currency_code": "vuv",
      "currency_symbol": "VT",
      "decimals": 0
    },
    "wst": {
      "currency_code": "wst",
      "currency_symbol": "WS$",
      "decimals": 2
    },
    "xaf": {
      "currency_code": "xaf",
      "currency_symbol": "FCFA",
      "decimals": 0
    },
    "xcd": {
      "currency_code": "xcd",
      "currency_symbol": "$",
      "decimals": 2
    },
    "xcg": {
      "currency_code": "xcg",
      "currency_symbol": "Cg",
      "decimals": 2
    },
    "xdr": {
      "currency_code": "xdr",
      "currency_symbol": "XDR",
      "decimals": 2
    },
    "xof": {
      "currency_code": "xof",
      "currency_symbol": "F CFA",
      "decimals": 0
    },
    "xpf": {
      "currency_code": "xpf",
      "currency_symbol": "FCFP",
      "decimals": 0
    },
    "yer": {
      "currency_code": "yer",
      "currency_symbol": "ر.ي",
      "decimals": 0
    },
    "zar": {
      "currency_code": "zar",
      "currency_symbol": "R",
      "decimals": 2
    },
    "zmw": {
      "currency_code": "zmw",
      "currency_symbol": "K",
      "decimals": 2
    },
    "zwg": {
      "currency_code": "zwg",
      "currency_symbol": "ZWG",
      "decimals": 2
    },
    "zwl": {
      "currency_code": "zwl",
      "currency_symbol": "ZWL",
      "decimals": 2
    }
  },
  "generated_from": "open.er-api.com v6 latest EUR",
  "generated_at_utc": "2026-02-01T20:28:56Z"
};

async function main() {
  const ref = db.doc("system/regions");
  await ref.set({
    ...regionsDoc,
    // Server timestamp written at deploy time:
    deployed_at: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log("✅ /system/regions updated.");
  console.log("Countries:", Object.keys(regionsDoc.countries).length);
  console.log("Currencies:", Object.keys(regionsDoc.currencies).length);
}

main().catch((e) => {
  console.error("❌ Failed:", e);
  process.exit(1);
});
